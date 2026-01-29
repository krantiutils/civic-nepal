# Play Store Listing Assets

## App Info
- **Package:** com.nagarik.calendar (or similar)
- **Category:** Education
- **Content Rating:** Everyone

---

## Short Description (80 chars max)
```
Nepali Patro with events, auspicious days, date converter & civic information.
```

## Full Description
```
Nagarik (नागरिक) - The complete Nepali calendar app with civic information.

📅 NEPALI PATRO (CALENDAR)
• Full Bikram Sambat calendar with daily view
• Holidays, events, tithi, nakshatra
• Auspicious days for विवाह, व्रतबन्ध, पास्नी
• Sticky notification showing today's date
• Works offline

🔄 DATE CONVERTER
• Convert between BS and AD instantly
• Accurate conversion for any date

💰 LIVE RATES
• Foreign exchange rates (USD, EUR, GBP, AUD, etc.)
• Gold & silver prices updated daily

📜 KNOW YOUR RIGHTS
• Nepal Constitution in English & Nepali
• Fundamental rights with practical tips

🏛️ CIVIC INFORMATION
• Government structure explained
• 77 districts with local officials
• Federal constituencies & leaders

🛠️ UTILITIES
• Citizenship photo merger (front + back)
• Image compressor for government forms

🌐 MULTILINGUAL
• English, नेपाली, नेपाल भाषा

No ads. No tracking. Your data stays on your device.
```

---

## Graphics Required

### App Icon (512x512px, up to 1MB)
**Gemini Prompt:**
```
Create a mobile app icon, 512x512 pixels, PNG format.

Design: A stylized Nepali calendar page showing "१५" (15 in Devanagari) as the date number, with a small crescent moon symbol indicating tithi.

Colors:
- Background: Gradient from crimson red (#DC143C) to darker red (#8B0000)
- Date number: White, bold, centered
- Optional: Subtle golden border

Style: Modern, flat design with slight shadow for depth. Must be recognizable at small sizes (48x48). No text other than the date number.
```

### Feature Graphic (1024x500px)
**Gemini Prompt:**
```
Create a Play Store feature graphic, 1024x500 pixels, PNG/JPG format.

Layout:
- Left 40%: Phone mockup showing Nepali calendar app with date "१५ माघ"
- Right 60%: Text area with app branding

Text:
- Large: "नागरिक" (Nepali)
- Below: "Nagarik" (English)
- Tagline: "Your Nepali Patro"

Colors:
- Background: Gradient from crimson red (#DC143C) to navy blue (#003893)
- Text: White
- Subtle Nepal map outline watermark in background

Style: Clean, professional, modern. High contrast for readability.
```

---

## Screenshots Required

### Phone Screenshots (1080x1920 or 1080x2400)
Capture these screens:
1. **Calendar** - Month view with events highlighted
2. **Home** - Main dashboard with date widget
3. **Date Converter** - BS to AD conversion
4. **Forex Rates** - Currency exchange rates
5. **Gold/Silver** - Bullion prices
6. **Map** - District or constituency map
7. **Government** - Structure diagram
8. **Settings** - Language/theme options

### 7-inch Tablet (1200x1920)
Same screens as phone, landscape or portrait.

### 10-inch Tablet (1600x2560 or 2048x2732)
Same screens as phone, landscape preferred.

---

## How to Capture Screenshots

### Using scrcpy (Recommended)
```bash
# Install
brew install scrcpy

# Mirror and record
scrcpy

# Screenshot: Press Ctrl+S in scrcpy window
# Files save to current directory
```

### Using adb
```bash
# Single screenshot
adb exec-out screencap -p > screen_home.png

# Or save to device then pull
adb shell screencap /sdcard/screen.png
adb pull /sdcard/screen.png
```

### Screenshot Naming Convention
```
phone_01_calendar.png
phone_02_home.png
phone_03_date_converter.png
phone_04_forex.png
phone_05_gold.png
tablet7_01_calendar.png
tablet10_01_calendar.png
```

---

## Tags (for discoverability)
- nepali calendar
- nepali patro
- bikram sambat
- date converter
- nepal constitution
- nepal government

---

## Privacy Policy URL
```
https://voidash.github.io/civic-nepal/privacy-policy.html
```

## Contact Email
```
thapa_aashish@proton.me
```
