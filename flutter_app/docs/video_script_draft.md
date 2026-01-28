# Nagarik App - Promotional Video Script (2 min)

## Overview
**App Name:** Nagarik (नागरिक)
**Tagline:** "Your civic companion for Nepal"
**Target:** Internal testers, early adopters
**Duration:** ~2 minutes
**Goal:** Get testers, collect feedback

---

## Video Structure

### INTRO (0:00 - 0:10) - 10 sec
**Visual:** App logo animation / Nepal flag colors
**Audio:** Upbeat Nepali-inspired music
**Text overlay:**
```
नागरिक
Your Civic Companion
```

**Voiceover (optional):**
> "Everything you need to know about Nepal - in your pocket."

---

### SECTION 1: Home & Date (0:10 - 0:25) - 15 sec

**Screen flow:**
1. Open app → Home screen
2. Show today's date widget (BS & AD)
3. Tap date → Calendar with events & auspicious days

**Key points to show:**
- Nepali date prominently displayed
- Bilingual interface (English + नेपाली)
- Calendar with holidays, tithi, events

**Text overlay:** "Nepali Calendar with Events & Auspicious Days"

---

### SECTION 2: Government & Constitution (0:25 - 0:50) - 25 sec

**Screen flow:**
1. Tap "Government" card
2. Show government structure diagram
3. Scroll through branches (Executive, Legislative, Judicial)
4. Tap "Know Your Rights"
5. Show rights categories
6. Open one right → Show practical tips

**Key points:**
- Visual hierarchy of Nepal's government
- Constitutional rights explained simply
- Practical situations & what to do

**Text overlay:** "Understand Your Government & Rights"

---

### SECTION 3: Maps & Leaders (0:50 - 1:15) - 25 sec

**Screen flow:**
1. Tap "Map" → Select Federal Constituencies
2. Interactive map → Zoom, tap a constituency
3. Show candidates for that constituency
4. Tap a leader → Full profile with bio
5. Quick show district map with local officials

**Key points:**
- Interactive SVG maps
- Federal constituencies & candidates
- 77 districts with local officials
- Leader profiles with party info

**Text overlay:** "Explore Districts, Constituencies & Leaders"

---

### SECTION 4: Utilities (1:15 - 1:40) - 25 sec

**Screen flow (quick montage):**
1. Date Converter → Convert BS ↔ AD
2. Forex → Live exchange rates
3. Gold/Silver → Current prices
4. Citizenship Merger → Merge front/back photos
5. Image Compressor → Compress for forms

**Key points:**
- Daily useful tools
- Live rates from reliable sources
- Photo tools for government forms

**Text overlay:** "Daily Utilities at Your Fingertips"

---

### SECTION 5: CTA & Testing (1:40 - 2:00) - 20 sec

**Visual:** App icon + QR code / link
**Text overlay:**
```
🧪 Help Us Improve!

Join Internal Testing:
[QR Code or Short Link]

Your feedback shapes the app.
```

**Voiceover:**
> "We're looking for testers! Join our internal testing program and help shape the future of civic education in Nepal. Your feedback matters."

**End card:**
```
नागरिक
Available Soon on Play Store

[Social handles / feedback form link]
```

---

## Screen Recording Plan

### Tool: scrcpy (recommended)
```bash
# Install
brew install scrcpy

# Record with phone connected via USB
scrcpy --record nagarik_demo.mp4

# Or with specific size for consistent framing
scrcpy --max-size 1080 --record nagarik_demo.mp4
```

### Alternative: adb screenrecord
```bash
# Record on device (max 3 min)
adb shell screenrecord /sdcard/demo.mp4

# Pull to computer
adb pull /sdcard/demo.mp4
```

### Recording Tips:
- Use a clean device (hide notifications)
- Enable "Do Not Disturb"
- Use consistent scroll speed
- Pause 1-2 seconds on key screens
- Record each section separately, edit together

---

## Gemini Prompts for Assets

### INTRO Animation Prompt:
```
Create a 5-second intro animation for a mobile app called "Nagarik" (नागरिक).

Style: Modern, clean, slightly governmental/civic feel
Colors: Use Nepal flag colors - crimson red (#DC143C) and blue (#003893)
Elements:
- The Nepali text "नागरिक" morphs into English "Nagarik"
- Subtle outline of Nepal's map in background
- Clean geometric shapes suggesting organization/structure

Output: 1080x1920 vertical video, 5 seconds, transparent or dark background
```

### OUTRO Animation Prompt:
```
Create a 5-second outro card for "Nagarik" app promotional video.

Include:
- App logo/icon centered
- Text: "Join Internal Testing" in both English and Nepali
- Placeholder for QR code (white square)
- Subtle animation: elements fade in sequentially
- Colors: Crimson red (#DC143C), blue (#003893), white

Style: Professional, trustworthy, civic/governmental feel
Output: 1080x1920 vertical, 5 seconds
```

### Background Music Suggestion:
Search for: "Nepali instrumental upbeat" or "South Asian corporate background music"
- Royalty-free sources: Pixabay, Mixkit, YouTube Audio Library
- Keep it subtle, not overpowering

---

## Tester Recruitment Strategy

### Option A: Google Play Internal Testing Link (Recommended)
1. Go to Play Console → Release → Testing → Internal testing
2. Create release, upload APK
3. Under "Testers" → "How testers join your test"
4. Enable "Anyone with the link" OR create an open Google Group
5. Share the opt-in URL anywhere (no email collection needed)

**Pros:**
- No email collection hassle
- People self-opt-in
- Easy to share on social media

### Option B: Google Form → Google Group
1. Create Google Form: "Join Nagarik Testing"
   - Collect: Email, device model, why interested
2. Create Google Group: nagarik-testers@googlegroups.com
3. Add form respondents to group
4. Add group to Play Console testers

**Form fields:**
- Email (required)
- Device model (optional)
- "What features interest you most?" (checkbox)
- "How did you hear about us?" (optional)

### Option C: Firebase App Distribution
- No Play Console needed
- Direct APK distribution
- Testers sign in with Google
- Good for rapid iteration before Play Store

### Sharing the Link:
- Twitter/X with demo video
- Facebook groups (Nepal tech, civic groups)
- Reddit r/Nepal
- LinkedIn
- Personal networks

---

## Feedback Collection

### In-App Feedback (add later):
- Settings → "Send Feedback" button
- Links to Google Form or email

### External:
- Google Form for detailed feedback
- GitHub Issues for bug reports
- Discord/Telegram group for community

---

## Checklist Before Recording

- [ ] Device charged, notifications off
- [ ] App has latest data
- [ ] Test all screens work smoothly
- [ ] Prepare sample data (know which constituency to tap, etc.)
- [ ] Clean home screen (no debug info)
- [ ] Set language to show bilingual nicely
- [ ] Have scrcpy installed and tested

---

## Post-Production Notes

- Add text overlays in video editor (CapCut, DaVinci Resolve, etc.)
- Keep transitions simple (cuts or quick fades)
- Add subtle zoom on important UI elements
- Ensure text is readable on mobile
- Export at 1080x1920 (9:16) for social media
- Also export 1920x1080 (16:9) for YouTube
