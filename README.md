# Alarm for Mac ⏰

A simple macOS alarm app that lives in the menu bar and reminds you with cute, colorful popups.

## Features

- **One-shot alarms**: Enter a time + name like `23:00 sleep`; it fires at that time and then disables itself.
- **Custom popup**: Slides in from the bottom-right corner with animation (slide / bounce / fade), pastel gradient themes, emoji support.
- **Per-alarm color**: Pick a color when adding each alarm; the picker resets to the default color (from Settings) after every add.
- **Menu bar + window**: Quick add from the ⏰ icon at the top; "Open Window" for a larger interface.
- **Keyboard-friendly**: Tab / Shift+Tab moves through hour → minute → name → emoji → add button → colors. Typing 2 digits auto-advances to the next field. Esc closes the panel.
- **Global hotkey**: Toggle the menu panel from anywhere with ⌥⌘A (customizable in Settings).
- **Runs 24/7**: Settings > "Launch at login" starts it automatically when the Mac boots. Alarms missed while the Mac was asleep are shown as soon as it wakes.
- **JSON**: Alarms are stored as readable JSON at `~/Library/Application Support/AlarmForMac/alarms.json` (hand-editable). Use "Import JSON" in the window to bulk-load alarms — see `sample_alarms.json` for an example.
- **Customization**: Color theme, animation style, popup duration, sound selection, quit confirmation popup.

## Build and run

No Xcode needed, Command Line Tools are enough:

```bash
./build_app.sh
open AlarmForMac.app
```

The app does not appear in the Dock; use it from the ⏰ icon in the menu bar. To quit, use the "Quit" button in the icon menu.

## JSON import format

```json
[
  { "time": "23:00", "name": "sleep", "emoji": "😴", "theme": "lavender" },
  { "time": "08:30", "name": "workout" }
]
```

`emoji` and `theme` are optional (`peach`, `lavender`, `mint`, `sky`, `sunset`); a `{ "alarms": [...] }` wrapper is also accepted.
