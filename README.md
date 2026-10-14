# Little Explorers (iPad)

A calm learning app for UKG and Class 1, built to be useful rather than addictive. Its backend is the HomeBuddy
FastAPI service (`/api/v1/kids`, running on `healthbuddy-vm`), and parents manage it from the HomeBuddy app
(**Today → Kids**).

## Subjects (52 skills, questions generated fresh every time)
- **Numbers**: counting, adding, taking away, bigger/smaller, before/after/between, shapes; Class 1 adds skip counting, number names, tens & ones, story sums
- **English**: capital/small letters, first-letter sounds, starts-with, 3-letter words, missing letter, sight words, rhymes, opposites; Class 1 adds plurals and a/an
- **Our World (EVS)**: animal homes and sounds, body, fruits and vegetables, wild and farm animals, helpers, transport, weather, good habits; Class 1 adds living/non-living, plant parts, food from animals
- **Thinking**: colours, big/small, odd one out, patterns, days; Class 1 adds months
- **Time & Money**: day/night, ₹ coins and notes; Class 1 adds clock reading and counting money
- **Telugu / Hindi** (parent toggles): letter matching, letter sounds, first letter, picture words, number words, all with romanisation shown

## Class levels
The class (UKG or Class 1) is set in HomeBuddy. A UKG child sees only UKG skills (40, including Telugu and Hindi), and
difficulty is capped at level 2: counting to 10, sums and take-aways within 10 using pictures, numbers to 20, and
easy sight words. Class 1 unlocks 12 more skills (clock, money, tens and ones, story sums, plurals, a/an, months,
plants, and more) and level 3.

## Eye comfort
- Soft, low-glare palette: warm paper instead of bright white, soft ink instead of black, muted colours.
- A warm, dim evening palette that turns on automatically from 6 pm to 7 am (parents can fix it to day or evening).
- An eye break at least every 8 minutes of screen time (the 20-20-20 idea: look at something far away), plus movement breaks.
- An "arm's length" posture reminder at the start of the day. Reduce Motion is respected.
- Parents are pointed to iPad Screen Distance and Night Shift in the Grown-ups screen.

## How it stays healthy
- A daily time limit (default 20 min, set in HomeBuddy). When it runs out, the app shows a screen-free "real-world mission" and stays locked until tomorrow, unless a parent adds bonus minutes from HomeBuddy.
- A daily adventure with a finish line (3 short rounds of 5 questions), not an endless feed.
- A movement or eye break every 2 rounds, which doesn't count as screen time.
- No timers, streaks, ads, loot boxes or notifications. Wrong answers get "try again", then a kind explanation.
- Adaptive levels: 4 right in a row makes questions harder, 3 of the last 4 wrong makes them easier, and missed questions come back later.
- Every question is read aloud (Indian English voice), so pre-readers can play.

## Run
Open `LittleExplorers.xcodeproj` in Xcode and run it on an iPad. The project uses synchronized folders, so new
files in `LittleExplorers/` are picked up automatically and there's no XcodeGen step.

Local backend testing (debug builds):
```
SIMCTL_CHILD_HB_BASE_URL=http://127.0.0.1:8001 SIMCTL_CHILD_HB_DEMO_CODE=<code> xcrun simctl launch <sim> com.ashunya.littleexplorers
SIMCTL_CHILD_LE_SKILL=clock SIMCTL_CHILD_LE_LEVEL=3 ...   # open straight into one skill
```
