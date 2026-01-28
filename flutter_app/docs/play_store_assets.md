# Play Store Assets Guide

## Descriptions

### Short Description (80 chars max)
```
Nepali Patro, IPO alerts, Nepal constitution, government info & daily tools.
```

### Full Description
```
नागरिक (Nagarik) - Nepal's most complete Patro app with civic features.

📅 NEPALI PATRO
• Beautiful Bikram Sambat calendar
• Daily tithi, nakshatra, yoga, karan
• All holidays & government events
• Auspicious days (विवाह लगन, व्रतबन्ध, पास्नी, नामकरण)
• Sticky notification with today's BS date
• Works completely offline

🔄 DATE CONVERTER
• Instant BS ↔ AD conversion
• Accurate for any date

📈 IPO & STOCKS
• Live IPO listings with open/close dates
• Get alerts before IPO opens
• Stock prices at a glance

📜 NEPAL CONSTITUTION
• Complete constitution in English & नेपाली
• All 308 articles, 35 parts
• Know Your Rights with practical tips
• Search by topic or keyword

🏛️ GOVERNMENT & CIVICS
• Visual guide to government structure
• Executive, Legislative, Judicial branches
• Current cabinet ministers
• Law-making process explained

🗺️ INTERACTIVE MAPS
• All 77 districts with elected officials
• Federal election constituencies
• Leader profiles with photos & bios

💰 DAILY RATES
• Live forex (USD, EUR, GBP, INR, AUD & more)
• Gold & silver prices

🛠️ UTILITIES
• Citizenship photo merger
• Image compressor for forms

🌐 Languages: English, नेपाली, नेपाल भाषा

✓ No ads
✓ No tracking
✓ No account required
✓ Your data stays on your device

Made with ❤️ for Nepal
```

---

## Gemini Prompts for Graphics

### App Icon (512x512, PNG, max 1MB)

```
Create a mobile app icon for a Nepali calendar app called "Nagarik".

Design specifications:
- Size: 512x512 pixels
- Format: PNG with transparency or solid background

Design elements:
- A stylized calendar page showing "१४" (the number 14 in Devanagari script) as the main date
- Small crescent moon icon in corner indicating tithi/lunar day
- Modern, flat design with subtle depth

Colors:
- Primary: Crimson red (#DC143C) - Nepal's national color
- Accent: Deep blue (#003893)
- Date number: White, bold
- Background: Gradient from crimson to slightly darker red

Style:
- Clean, minimalist, modern
- Should be recognizable at small sizes (48px)
- No text other than the Devanagari number
- Rounded corners (Android adaptive icon safe zone)
```

### Feature Graphic (1024x500, PNG/JPG)

```
Create a Google Play Store feature graphic for "Nagarik" - a Nepali calendar and civic information app.

Size: 1024x500 pixels

Layout:
- Left 40%: Phone mockup showing calendar screen with Nepali dates
- Center/Right 60%:
  - Large text "नागरिक" (Nagarik in Nepali)
  - Below it: "Nagarik" in English
  - Tagline: "Your Complete Nepali Patro"

Background:
- Gradient from crimson red (#DC143C) on left to deep blue (#003893) on right
- Subtle, faded outline of Nepal's map in the background
- Maybe subtle mountain silhouette at bottom

Style:
- Professional, clean, trustworthy
- Modern typography
- The phone mockup should show a calendar grid with Nepali numerals

Do not include:
- Any icons or badges
- Too much text
- Cluttered elements
```

---

## Screenshots Guide

### Required Sizes
| Type | Dimensions | Min | Max |
|------|------------|-----|-----|
| Phone | 16:9 or 9:16 | 320px | 3840px |
| 7" Tablet | 16:9 or 9:16 | 320px | 3840px |
| 10" Tablet | 16:9 or 9:16 | 1080px | 7680px |

### Recommended Phone Size
- **1080 x 1920** (portrait) or **1080 x 2400** for taller phones

### Screenshots to Capture (Priority Order)

1. **Calendar** (MAIN) - Full month view with events visible
2. **Calendar Day View** - Show tithi, nakshatra, events for a day
3. **Home Screen** - Shows all features at a glance
4. **Date Converter** - BS to AD conversion
5. **IPO Screen** - List of IPOs with status
6. **Forex Rates** - Currency exchange rates
7. **Gold/Silver Prices** - Bullion rates
8. **Government Structure** - Visual hierarchy

### How to Capture (since Flutter web navigation is limited)

Use scrcpy on your connected Android device:

```bash
# Install
brew install scrcpy

# Run with recording
scrcpy --max-size 1080

# Screenshots: Press Ctrl+S or use device screenshot
```

Or use ADB:
```bash
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png ./screenshot.png
```

---

## Screenshot Overlays (Optional)

If you want to add text overlays to screenshots, keep them:
- Short (3-5 words max)
- At top or bottom of screenshot
- Semi-transparent background for readability
- Same font style across all screenshots

Example overlays:
1. "Complete Nepali Patro"
2. "Convert Dates Instantly"
3. "Live IPO Updates"
4. "Know Your Rights"
5. "Track Gold & Forex"

---

## Checklist

- [ ] App Icon (512x512 PNG)
- [ ] Feature Graphic (1024x500)
- [ ] Phone Screenshots (min 2, max 8)
- [ ] 7" Tablet Screenshots (optional but recommended)
- [ ] 10" Tablet Screenshots (optional but recommended)
- [ ] Short Description
- [ ] Full Description
- [ ] Privacy Policy URL: https://voidash.github.io/civic-nepal/privacy-policy.html
