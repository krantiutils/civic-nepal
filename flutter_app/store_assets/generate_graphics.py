#!/usr/bin/env python3
"""
Generate Play Store graphics for Nagarik app using Google's Imagen API.

Colors match the app's actual theme:
- Primary: #1976D2 (Material Blue 700)
- Secondary: #0D47A1 (Deep blue)
- Accent: #FFB300 (Amber/Gold)

Usage:
    python3 generate_graphics.py [API_KEY]

Requires GOOGLE_API_KEY in environment or as argument.
"""

import os
import sys
from pathlib import Path

# Load API key from:
# 1. Command line argument
# 2. GOOGLE_API_KEY environment variable
# 3. .env file in project root
api_key = None

if len(sys.argv) > 1:
    api_key = sys.argv[1]
    print("Using API key from command line argument")

if not api_key:
    api_key = os.environ.get("GOOGLE_API_KEY")
    if api_key:
        print("Using API key from GOOGLE_API_KEY environment variable")

if not api_key:
    env_path = Path(__file__).parent.parent.parent / ".env"
    if env_path.exists():
        with open(env_path) as f:
            for line in f:
                if line.strip() and not line.startswith("#"):
                    key, _, value = line.strip().partition("=")
                    if key == "GOOGLE_API_KEY":
                        api_key = value
                        print(f"Using API key from {env_path}")
                        break

if not api_key:
    print("Error: Google API key not found.")
    print()
    print("Provide it via one of:")
    print("  1. Command line: python3 generate_graphics.py YOUR_API_KEY")
    print("  2. Environment: GOOGLE_API_KEY=xxx python3 generate_graphics.py")
    print("  3. Add GOOGLE_API_KEY=xxx to .env file in project root")
    print()
    print("Get an API key at: https://aistudio.google.com/apikey")
    sys.exit(1)

from google import genai
from google.genai import types

client = genai.Client(api_key=api_key)

# Output directory
OUTPUT_DIR = Path(__file__).parent


def generate_app_icon():
    """Generate 512x512 app icon."""
    prompt = """
Create a mobile app icon, exactly 512x512 pixels.

Design concept: A stylized Nepali calendar page showing "१५" (the number 15 in Devanagari script) as the main date display, with a small crescent moon symbol in the top-right corner to indicate tithi/lunar day.

Color scheme:
- Background: Solid Material Blue (#1976D2) with subtle gradient to darker blue (#0D47A1) at bottom
- Date number "१५": White, bold, centered, large and prominent
- Moon symbol: Amber gold (#FFB300), small, top-right area
- Optional: Very subtle white calendar page fold effect in top-right corner

Style requirements:
- Modern, flat Material Design 3 aesthetic
- Clean edges, no noise or texture
- High contrast for readability at small sizes (must work at 48x48)
- No text other than the Devanagari date number
- No background patterns or decorations
- Professional, minimal, app store quality

The icon should look like a clean calendar date tile, immediately recognizable as a calendar/date app.
"""

    print("Generating app icon (512x512)...")

    try:
        response = client.models.generate_images(
            model="imagen-4.0-generate-001",
            prompt=prompt,
            config=types.GenerateImagesConfig(
                number_of_images=1,
                aspect_ratio="1:1",
                safety_filter_level="BLOCK_LOW_AND_ABOVE",
            ),
        )

        if response.generated_images:
            output_path = OUTPUT_DIR / "app_icon_512.png"
            response.generated_images[0].image.save(str(output_path))
            print(f"Saved: {output_path}")
            return True
        else:
            print("No images generated")
            return False

    except Exception as e:
        print(f"Error: {e}")
        return False


def generate_feature_graphic():
    """Generate 1024x500 feature graphic."""
    prompt = """
Create a Play Store feature graphic banner image.

Layout:
- Left 35%: Subtle phone mockup silhouette showing a calendar app interface with Nepali text, semi-transparent
- Right 65%: Text branding area

Text content (must be exactly as shown):
- Large text: "नागरिक" (Nepali word meaning Citizen)
- Below in smaller text: "Nagarik"
- Tagline below: "Your Nepali Patro"

Color scheme:
- Background: Smooth gradient from Material Blue (#1976D2) on left to Deep Blue (#0D47A1) on right
- All text: Pure white (#FFFFFF)
- Phone mockup: White outline/silhouette, 20% opacity
- Subtle amber gold (#FFB300) accent line or glow around the app name

Style:
- Clean, professional, modern
- No busy backgrounds or patterns
- High contrast for text readability on Play Store
- Minimal, elegant design
- The text should be the focal point
- Devanagari text "नागरिक" should be large and prominent

Quality: Professional marketing graphic suitable for Google Play Store feature placement.
"""

    print("\nGenerating feature graphic (1024x500)...")

    try:
        response = client.models.generate_images(
            model="imagen-4.0-generate-001",
            prompt=prompt,
            config=types.GenerateImagesConfig(
                number_of_images=1,
                aspect_ratio="16:9",  # Play Store feature graphic is ~2:1, but API only supports 16:9
                safety_filter_level="BLOCK_LOW_AND_ABOVE",
            ),
        )

        if response.generated_images:
            output_path = OUTPUT_DIR / "feature_graphic.png"
            response.generated_images[0].image.save(str(output_path))
            print(f"Saved: {output_path}")
            return True
        else:
            print("No images generated")
            return False

    except Exception as e:
        print(f"Error: {e}")
        return False


def main():
    print("=" * 50)
    print("Nagarik Store Graphics Generator")
    print("=" * 50)
    print(f"\nOutput directory: {OUTPUT_DIR}")
    print("\nColor scheme:")
    print("  Primary: #1976D2 (Material Blue)")
    print("  Secondary: #0D47A1 (Deep Blue)")
    print("  Accent: #FFB300 (Amber Gold)")
    print()

    icon_success = generate_app_icon()
    feature_success = generate_feature_graphic()

    print("\n" + "=" * 50)
    print("Results:")
    print(f"  App Icon: {'SUCCESS' if icon_success else 'FAILED'}")
    print(f"  Feature Graphic: {'SUCCESS' if feature_success else 'FAILED'}")
    print("=" * 50)

    if not (icon_success and feature_success):
        print("\nIf generation failed, try Google AI Studio manually:")
        print("https://aistudio.google.com/")
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
