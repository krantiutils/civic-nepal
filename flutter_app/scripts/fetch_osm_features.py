#!/usr/bin/env python3
"""
Fetch geographic features from OpenStreetMap for Nepal constituency map.
Fetches: major cities, mountain peaks, rivers
"""

import json
import requests
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
OUTPUT_DIR = SCRIPT_DIR.parent / "assets" / "data" / "election"

# Overpass API endpoint
OVERPASS_URL = "https://overpass-api.de/api/interpreter"

# Nepal bounding box (tighter to exclude India)
NEPAL_BBOX = "26.35,80.05,30.45,88.2"  # south,west,north,east

# Nepal country boundary for filtering (rough polygon check)
# Points that are clearly inside Nepal only
NEPAL_MIN_LON = 80.05
NEPAL_MAX_LON = 88.2
NEPAL_MIN_LAT = 26.35
NEPAL_MAX_LAT = 30.45


def fetch_overpass(query: str) -> dict:
    """Execute Overpass API query."""
    response = requests.post(OVERPASS_URL, data={"data": query}, timeout=60)
    response.raise_for_status()
    return response.json()


def fetch_cities() -> list[dict]:
    """Fetch all cities and towns in Nepal."""
    # Use area filter to restrict to Nepal - get cities, towns, and villages
    query = """
    [out:json][timeout:60];
    area["ISO3166-1"="NP"]->.nepal;
    (
      node["place"="city"](area.nepal);
      node["place"="town"](area.nepal);
      node["place"="village"]["population"](area.nepal);
    );
    out body;
    """
    print("Fetching cities...")
    data = fetch_overpass(query)

    cities = []
    for elem in data.get("elements", []):
        name = elem.get("tags", {}).get("name:en") or elem.get("tags", {}).get("name", "")
        if not name:
            continue

        population = elem.get("tags", {}).get("population", "0")
        try:
            pop = int(population)
        except ValueError:
            pop = 0

        cities.append({
            "id": elem["id"],
            "name": name,
            "nameNp": elem.get("tags", {}).get("name:ne", ""),
            "lat": elem["lat"],
            "lon": elem["lon"],
            "population": pop,
            "type": elem.get("tags", {}).get("place", "city"),
            "capital": elem.get("tags", {}).get("capital", ""),
        })

    # Sort by population descending
    cities.sort(key=lambda x: x["population"], reverse=True)
    print(f"  Found {len(cities)} cities/towns/villages")
    return cities


def fetch_peaks() -> list[dict]:
    """Fetch all mountain peaks in Nepal."""
    # Use area filter to restrict to Nepal
    query = """
    [out:json][timeout:60];
    area["ISO3166-1"="NP"]->.nepal;
    (
      node["natural"="peak"](area.nepal);
    );
    out body;
    """
    print("Fetching peaks...")
    data = fetch_overpass(query)

    peaks = []
    for elem in data.get("elements", []):
        name = elem.get("tags", {}).get("name:en") or elem.get("tags", {}).get("name", "")
        if not name:
            continue

        ele = elem.get("tags", {}).get("ele", "0")
        try:
            elevation = int(float(ele))
        except ValueError:
            elevation = 0

        peaks.append({
            "id": elem["id"],
            "name": name,
            "nameNp": elem.get("tags", {}).get("name:ne", ""),
            "lat": elem["lat"],
            "lon": elem["lon"],
            "elevation": elevation,
        })

    # Sort by elevation descending
    peaks.sort(key=lambda x: x["elevation"], reverse=True)
    print(f"  Found {len(peaks)} peaks")
    return peaks


def fetch_rivers() -> list[dict]:
    """Fetch major rivers in Nepal."""
    # Major rivers to filter for (others will be grouped by first word of name)
    major_rivers = ["Koshi", "Gandaki", "Karnali", "Bagmati", "Rapti", "Narayani", "Trisuli", "Seti", "Bheri", "Mahakali"]

    # Use area filter and fetch major rivers with geometry
    query = """
    [out:json][timeout:120];
    area["ISO3166-1"="NP"]->.nepal;
    (
      way["waterway"="river"]["name"](area.nepal);
    );
    out geom;
    """
    print("Fetching rivers (this may take a while)...")
    data = fetch_overpass(query)

    rivers = {}
    for elem in data.get("elements", []):
        if elem["type"] != "way":
            continue

        name = elem.get("tags", {}).get("name:en") or elem.get("tags", {}).get("name", "")
        if not name:
            continue

        # out geom returns geometry directly in the element
        geometry = elem.get("geometry", [])
        if len(geometry) < 2:
            continue

        # Normalize river name
        river_key = name.split()[0] if name else ""
        for major in major_rivers:
            if major.lower() in name.lower():
                river_key = major
                break

        if river_key not in rivers:
            rivers[river_key] = {
                "name": river_key,
                "nameNp": elem.get("tags", {}).get("name:ne", ""),
                "segments": [],
            }

        # Extract coordinates from geometry
        segment = [[pt["lon"], pt["lat"]] for pt in geometry]
        if len(segment) >= 2:
            rivers[river_key]["segments"].append(segment)

    # Simplify river segments - only keep major rivers with enough data
    result = []
    for river_name, river in rivers.items():
        if not river["segments"]:
            continue
        # Only keep rivers that are in our major_rivers list or have enough segments
        if river_name not in major_rivers and len(river["segments"]) < 10:
            continue
        # Merge and simplify segments
        simplified = simplify_river(river["segments"])
        if simplified and len(simplified) >= 5:
            river["path"] = simplified
            del river["segments"]
            result.append(river)

    # Sort by path length (more points = more significant river)
    result.sort(key=lambda x: len(x.get("path", [])), reverse=True)
    print(f"  Found {len(result)} rivers")
    return result[:15]  # Top 15 rivers


def simplify_river(segments: list[list]) -> list[list[float]]:
    """Simplify river path by merging segments and reducing points."""
    if not segments:
        return []

    # Flatten all points
    all_points = []
    for seg in segments:
        all_points.extend(seg)

    if len(all_points) < 2:
        return []

    # Douglas-Peucker simplification
    def simplify_dp(points, tolerance):
        if len(points) < 3:
            return points

        # Find point with max distance from line
        first, last = points[0], points[-1]
        max_dist = 0
        max_idx = 0

        for i in range(1, len(points) - 1):
            px, py = points[i]
            x1, y1 = first
            x2, y2 = last

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
            left = simplify_dp(points[:max_idx + 1], tolerance)
            right = simplify_dp(points[max_idx:], tolerance)
            return left[:-1] + right
        else:
            return [first, last]

    simplified = simplify_dp(all_points, 0.02)  # ~2km tolerance
    return [[round(p[0], 4), round(p[1], 4)] for p in simplified]


def convert_to_map_coords(features: dict, constituencies_geo: dict) -> dict:
    """Convert lat/lon to map coordinates matching constituency map."""
    # Get the bounds from constituencies
    all_x = []
    all_y = []
    for c in constituencies_geo["constituencies"]:
        for p in c["path"]:
            all_x.append(p[0])
            all_y.append(p[1])

    map_min_x, map_max_x = min(all_x), max(all_x)
    map_min_y, map_max_y = min(all_y), max(all_y)

    # Nepal bounds in lat/lon
    lon_min, lon_max = 80.0, 88.2
    lat_min, lat_max = 26.3, 30.5

    def to_map_x(lon):
        return map_min_x + (lon - lon_min) / (lon_max - lon_min) * (map_max_x - map_min_x)

    def to_map_y(lat):
        # Invert Y axis (lat increases up, but map Y increases down)
        return map_max_y - (lat - lat_min) / (lat_max - lat_min) * (map_max_y - map_min_y)

    # Convert cities
    for city in features.get("cities", []):
        city["x"] = round(to_map_x(city["lon"]), 2)
        city["y"] = round(to_map_y(city["lat"]), 2)

    # Convert peaks
    for peak in features.get("peaks", []):
        peak["x"] = round(to_map_x(peak["lon"]), 2)
        peak["y"] = round(to_map_y(peak["lat"]), 2)

    # Convert rivers
    for river in features.get("rivers", []):
        if "path" in river:
            river["path"] = [[round(to_map_x(p[0]), 2), round(to_map_y(p[1]), 2)] for p in river["path"]]

    return features


def main():
    osm_dir = SCRIPT_DIR.parent / "assets" / "data" / "osm"
    osm_dir.mkdir(parents=True, exist_ok=True)

    # Fetch and save cities
    cities = fetch_cities()
    cities_data = {
        "type": "city",
        "count": len(cities),
        "source": "OpenStreetMap",
        "timestamp": __import__("datetime").datetime.now().isoformat(),
        "items": cities,
    }
    cities_file = osm_dir / "cities.json"
    with open(cities_file, "w") as f:
        json.dump(cities_data, f, separators=(',', ':'), ensure_ascii=False)
    print(f"Saved {len(cities)} cities to {cities_file}")

    # Fetch and save peaks
    peaks = fetch_peaks()
    peaks_data = {
        "type": "peak",
        "count": len(peaks),
        "source": "OpenStreetMap",
        "timestamp": __import__("datetime").datetime.now().isoformat(),
        "items": peaks,
    }
    peaks_file = osm_dir / "peaks.json"
    with open(peaks_file, "w") as f:
        json.dump(peaks_data, f, separators=(',', ':'), ensure_ascii=False)
    print(f"Saved {len(peaks)} peaks to {peaks_file}")


if __name__ == "__main__":
    main()
