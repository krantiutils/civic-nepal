#!/usr/bin/env python3
"""
Extract protected area boundaries from Wikipedia Nepal Constituency Map SVG.
Converts layer12 paths to simplified JSON format matching constituencies_geo.json.
"""

import re
import json
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
OUTPUT_DIR = SCRIPT_DIR.parent / "assets" / "data" / "election"
SVG_CACHE = Path("/tmp/nepal_constituency.svg")

# Known Nepal protected areas for labeling (approximate centroids for matching)
# Format: (approx_x, approx_y, name, type)
KNOWN_AREAS = [
    (450, 200, "Sagarmatha National Park", "national_park"),
    (380, 280, "Chitwan National Park", "national_park"),
    (120, 220, "Bardia National Park", "national_park"),
    (100, 180, "Shuklaphanta National Park", "national_park"),
    (80, 150, "Khaptad National Park", "national_park"),
    (130, 130, "Rara National Park", "national_park"),
    (150, 140, "Shey Phoksundo National Park", "national_park"),
    (350, 180, "Langtang National Park", "national_park"),
    (430, 170, "Makalu Barun National Park", "national_park"),
    (300, 280, "Parsa National Park", "national_park"),
    (280, 200, "Annapurna Conservation Area", "conservation_area"),
    (320, 180, "Manaslu Conservation Area", "conservation_area"),
    (480, 180, "Kanchenjunga Conservation Area", "conservation_area"),
    (390, 200, "Gaurishankar Conservation Area", "conservation_area"),
    (350, 220, "Api Nampa Conservation Area", "conservation_area"),
    (420, 300, "Koshi Tappu Wildlife Reserve", "wildlife_reserve"),
    (100, 260, "Banke National Park", "national_park"),
    (200, 250, "Dhorpatan Hunting Reserve", "hunting_reserve"),
    (140, 280, "Blackbuck Conservation Area", "conservation_area"),
    (250, 300, "Parsa Wildlife Reserve", "wildlife_reserve"),
    (350, 150, "Shivapuri Nagarjun National Park", "national_park"),
    (90, 200, "Suklaphanta Wildlife Reserve", "wildlife_reserve"),
]


def parse_svg_path(d: str) -> list[tuple[float, float]]:
    """
    Parse SVG path 'd' attribute to list of (x, y) points.
    Handles M, m, L, l, H, h, V, v, Z, z, C, c commands.
    """
    points = []
    current_x, current_y = 0.0, 0.0
    start_x, start_y = 0.0, 0.0

    # Tokenize the path
    tokens = re.findall(r'[MmLlHhVvZzCcSsQqTtAa]|[-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?', d)

    i = 0
    command = 'M'

    while i < len(tokens):
        token = tokens[i]

        if token.isalpha():
            command = token
            i += 1
            continue

        if command in ('M', 'm'):
            x = float(tokens[i])
            y = float(tokens[i + 1])
            if command == 'm':
                current_x += x
                current_y += y
            else:
                current_x = x
                current_y = y
            start_x, start_y = current_x, current_y
            points.append((current_x, current_y))
            i += 2
            # Subsequent coords are treated as lineto
            command = 'l' if command == 'm' else 'L'

        elif command in ('L', 'l'):
            x = float(tokens[i])
            y = float(tokens[i + 1])
            if command == 'l':
                current_x += x
                current_y += y
            else:
                current_x = x
                current_y = y
            points.append((current_x, current_y))
            i += 2

        elif command in ('H', 'h'):
            x = float(tokens[i])
            if command == 'h':
                current_x += x
            else:
                current_x = x
            points.append((current_x, current_y))
            i += 1

        elif command in ('V', 'v'):
            y = float(tokens[i])
            if command == 'v':
                current_y += y
            else:
                current_y = y
            points.append((current_x, current_y))
            i += 1

        elif command in ('Z', 'z'):
            current_x, current_y = start_x, start_y
            i += 1

        elif command in ('C', 'c'):
            # Cubic bezier - we skip control points, just take endpoint
            if i + 5 < len(tokens):
                x = float(tokens[i + 4])
                y = float(tokens[i + 5])
                if command == 'c':
                    current_x += x
                    current_y += y
                else:
                    current_x = x
                    current_y = y
                points.append((current_x, current_y))
            i += 6

        elif command in ('S', 's'):
            # Smooth cubic bezier
            if i + 3 < len(tokens):
                x = float(tokens[i + 2])
                y = float(tokens[i + 3])
                if command == 's':
                    current_x += x
                    current_y += y
                else:
                    current_x = x
                    current_y = y
                points.append((current_x, current_y))
            i += 4

        elif command in ('Q', 'q'):
            # Quadratic bezier
            if i + 3 < len(tokens):
                x = float(tokens[i + 2])
                y = float(tokens[i + 3])
                if command == 'q':
                    current_x += x
                    current_y += y
                else:
                    current_x = x
                    current_y = y
                points.append((current_x, current_y))
            i += 4

        else:
            i += 1

    return points


def calculate_centroid(points: list[tuple[float, float]]) -> tuple[float, float]:
    """Calculate centroid of polygon."""
    if not points:
        return (0, 0)
    sum_x = sum(p[0] for p in points)
    sum_y = sum(p[1] for p in points)
    return (sum_x / len(points), sum_y / len(points))


def simplify_points(points: list[tuple[float, float]], tolerance: float = 0.5) -> list[list[float]]:
    """Simplify path using Douglas-Peucker algorithm."""
    if len(points) < 3:
        return [[round(p[0], 2), round(p[1], 2)] for p in points]

    # Find point with max distance from line between first and last
    first = points[0]
    last = points[-1]
    max_dist = 0
    max_idx = 0

    for i in range(1, len(points) - 1):
        # Distance from point to line
        px, py = points[i]
        x1, y1 = first
        x2, y2 = last

        # Line length squared
        line_len_sq = (x2 - x1) ** 2 + (y2 - y1) ** 2
        if line_len_sq == 0:
            dist = ((px - x1) ** 2 + (py - y1) ** 2) ** 0.5
        else:
            t = max(0, min(1, ((px - x1) * (x2 - x1) + (py - y1) * (y2 - y1)) / line_len_sq))
            proj_x = x1 + t * (x2 - x1)
            proj_y = y1 + t * (y2 - y1)
            dist = ((px - proj_x) ** 2 + (py - proj_y) ** 2) ** 0.5

        if dist > max_dist:
            max_dist = dist
            max_idx = i

    if max_dist > tolerance:
        left = simplify_points(points[:max_idx + 1], tolerance)
        right = simplify_points(points[max_idx:], tolerance)
        return left[:-1] + right
    else:
        return [[round(first[0], 2), round(first[1], 2)],
                [round(last[0], 2), round(last[1], 2)]]


def find_closest_known_area(centroid: tuple[float, float],
                            used_names: set) -> tuple[str, str]:
    """Find closest known protected area by centroid."""
    min_dist = float('inf')
    best_match = None

    for kx, ky, name, area_type in KNOWN_AREAS:
        if name in used_names:
            continue
        dist = ((centroid[0] - kx) ** 2 + (centroid[1] - ky) ** 2) ** 0.5
        if dist < min_dist:
            min_dist = dist
            best_match = (name, area_type)

    return best_match or ("Unknown Protected Area", "unknown")


def extract_protected_areas():
    """Extract protected areas from SVG and save as JSON."""
    if not SVG_CACHE.exists():
        print(f"Error: SVG cache not found at {SVG_CACHE}")
        print("Run scrape_constituencies.py first or manually download the SVG")
        return

    content = SVG_CACHE.read_text()

    # Get original viewBox: "0 0 584.38 334.60001"
    viewbox_match = re.search(r'viewBox="([^"]+)"', content)
    orig_vb = [float(x) for x in viewbox_match.group(1).split()] if viewbox_match else [0, 0, 584.38, 334.6]

    # Target viewBox from constituencies_geo.json
    target_vb = [0.0, 0.0, 500.0, 500.0]

    # Find layer12 with transform
    layer12_match = re.search(r'<g[^>]*id="layer12"[^>]*>(.*?)</g>', content, re.DOTALL)
    if not layer12_match:
        print("Error: layer12 not found in SVG")
        return

    layer12_content = layer12_match.group(0)

    # Get transform: translate(-82.21,-113.5)
    transform_match = re.search(r'transform="translate\(([^,]+),([^)]+)\)"', layer12_content)
    tx, ty = 0.0, 0.0
    if transform_match:
        tx = float(transform_match.group(1))
        ty = float(transform_match.group(2))

    # Extract paths
    path_pattern = re.compile(r'<path[^>]*\bd="([^"]*)"[^>]*/>')
    paths = path_pattern.findall(layer12_content)

    print(f"Found {len(paths)} protected area paths")
    print(f"Transform: translate({tx}, {ty})")
    print(f"Original viewBox: {orig_vb}")
    print(f"Target viewBox: {target_vb}")

    # Load existing constituencies to get coordinate bounds
    geo_file = OUTPUT_DIR / "constituencies_geo.json"
    with open(geo_file, 'r') as f:
        geo_data = json.load(f)

    # Calculate constituency bounds to derive the correct transformation
    all_cx = []
    all_cy = []
    for c in geo_data['constituencies']:
        for p in c['path']:
            all_cx.append(p[0])
            all_cy.append(p[1])

    c_min_x, c_max_x = min(all_cx), max(all_cx)
    c_min_y, c_max_y = min(all_cy), max(all_cy)
    c_width = c_max_x - c_min_x
    c_height = c_max_y - c_min_y
    print(f"\nConstituency bounds: X [{c_min_x:.1f}, {c_max_x:.1f}], Y [{c_min_y:.1f}, {c_max_y:.1f}]")

    # First, find the range of protected area coordinates after applying the translate
    # We need to map this range to the constituency coordinate range
    pa_coords = []
    for d in paths:
        raw_points = parse_svg_path(d)
        for x, y in raw_points:
            pa_coords.append((x + tx, y + ty))

    if not pa_coords:
        print("Error: No protected area coordinates found")
        return

    pa_min_x = min(p[0] for p in pa_coords)
    pa_max_x = max(p[0] for p in pa_coords)
    pa_min_y = min(p[1] for p in pa_coords)
    pa_max_y = max(p[1] for p in pa_coords)

    print(f"\nProtected area coords (after translate): X [{pa_min_x:.1f}, {pa_max_x:.1f}], Y [{pa_min_y:.1f}, {pa_max_y:.1f}]")

    # Map protected area range to constituency range
    # Linear interpolation: target = (src - src_min) / (src_max - src_min) * (tgt_max - tgt_min) + tgt_min
    pa_width = pa_max_x - pa_min_x
    pa_height = pa_max_y - pa_min_y

    scale_x = c_width / pa_width if pa_width > 0 else 1
    scale_y = c_height / pa_height if pa_height > 0 else 1

    print(f"Scale factors: X={scale_x:.4f}, Y={scale_y:.4f}")
    print(f"Constituency range: X [{c_min_x:.1f}, {c_max_x:.1f}], Y [{c_min_y:.1f}, {c_max_y:.1f}]")

    protected_areas = []
    used_names = set()

    for i, d in enumerate(paths):
        # Parse path
        raw_points = parse_svg_path(d)
        if len(raw_points) < 3:
            continue

        # Apply transform to match constituency coordinate space:
        # 1. Apply layer12 translate transform
        # 2. Linear interpolation from PA range to constituency range
        transformed_points = []
        for x, y in raw_points:
            # Apply translate (layer12 has translate(-82.21, -113.5))
            abs_x = x + tx
            abs_y = y + ty
            # Linear interpolation: map PA coord range to constituency coord range
            target_x = (abs_x - pa_min_x) / pa_width * c_width + c_min_x if pa_width > 0 else abs_x
            target_y = (abs_y - pa_min_y) / pa_height * c_height + c_min_y if pa_height > 0 else abs_y
            transformed_points.append((target_x, target_y))

        # Calculate centroid for labeling
        centroid = calculate_centroid(transformed_points)

        # Simplify path with lower tolerance to preserve shape
        simplified = simplify_points(transformed_points, tolerance=0.3)

        if len(simplified) < 3:
            continue

        # Use generic naming
        area_id = f"protected-area-{i+1}"
        name = f"Protected Area {i+1}"

        protected_areas.append({
            "id": area_id,
            "name": name,
            "type": "protected_area",
            "centroid": [round(centroid[0], 2), round(centroid[1], 2)],
            "path": simplified
        })

        print(f"  {i+1}. centroid ({centroid[0]:.1f}, {centroid[1]:.1f}) - {len(simplified)} points")

    # Update existing geo_data with protected areas
    geo_data["protectedAreas"] = protected_areas
    geo_data["protectedAreasCount"] = len(protected_areas)

    with open(geo_file, 'w') as f:
        json.dump(geo_data, f, separators=(',', ':'))

    # Verify protected area bounds
    all_px = []
    all_py = []
    for pa in protected_areas:
        for p in pa['path']:
            all_px.append(p[0])
            all_py.append(p[1])

    if all_px:
        print(f"\nProtected area bounds: X [{min(all_px):.1f}, {max(all_px):.1f}], Y [{min(all_py):.1f}, {max(all_py):.1f}]")

    print(f"\nAdded {len(protected_areas)} protected areas to {geo_file}")
    print(f"Total file size: {geo_file.stat().st_size / 1024:.1f} KB")


if __name__ == '__main__':
    extract_protected_areas()
