<h1 align="center">Alarm for Mac ⏰</h1>

<p align="center">
  A lightweight menu bar alarm app for macOS that reminds you with cute, colorful pop-ups.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-blue" alt="Platform: macOS 14+">
  <img src="https://img.shields.io/badge/Swift-5.10-orange" alt="Swift 5.10">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License: MIT">
</p>

---

Click the ⏰ icon in the menu bar to add an alarm in seconds — type a time, give it a name, pick a color, and hit **Add**.

<p align="center">
  <img src="docs/menu.png" alt="Alarm for Mac menu bar panel" width="420">
</p>
<p align="center"><sub><em>Quick-add panel from the menu bar</em></sub></p>

Need more room? Open the full window to manage everything at once — see your whole list, toggle alarms on and off, or import them from a JSON file.

<p align="center">
  <img src="docs/screenshot.png" alt="Alarm for Mac main window" width="480">
</p>
<p align="center"><sub><em>Main window with your full alarm list</em></sub></p>

## Features

- **One-shot alarms** — enter a time and name like `23:00 sleep`; it fires once at that time, then disables itself.
- **Custom pop-up** — slides into the bottom-right corner with your choice of animation (slide / bounce / fade), a pastel gradient theme, and an emoji.
- **Per-alarm color** — pick a color for each alarm; the picker resets to your default (set in Settings) after every add.
- **Menu bar + window** — a quick-add panel from the ⏰ icon, plus a full window for detailed management.
- **Keyboard-friendly** — Tab through every field and control; typing two digits auto-advances to the next box.
- **Global hotkey** — toggle the menu panel from anywhere with `⌥⌘A` (customizable).
- **Runs 24/7** — optionally launches at login; alarms missed while the Mac was asleep are shown as soon as it wakes.
- **Readable JSON storage** — alarms live in a plain, hand-editable JSON file, with bulk import support.

## Requirements

- macOS 14 (Sonoma) or later
- Xcode Command Line Tools (`xcode-select --install`) — no full Xcode required

## Build and run

```bash
./build_app.sh
open AlarmForMac.app
```

`build_app.sh` compiles the Swift package, wraps the binary into an `AlarmForMac.app` bundle, and ad-hoc signs it. The app has no Dock icon — it lives in the menu bar. Use the **Quit** button in its panel to exit.

## Usage

**Add an alarm** — set the hour and minute, type a name and (optional) emoji, choose a color, and press **Add** (or `Return`).

**Keyboard shortcuts**

| Action | Shortcut |
| --- | --- |
| Toggle the menu panel (from anywhere) | `⌥⌘A` |
| Move between fields and controls | `Tab` / `Shift+Tab` |
| Add the alarm | `Return` |
| Close the panel | `Esc` |

**Import from JSON** — open the window and click **Import JSON** to bulk-load alarms. See [`sample_alarms.json`](sample_alarms.json) for an example.

## JSON format

```json
[
  { "time": "23:00", "name": "sleep", "emoji": "😴", "theme": "lavender" },
  { "time": "08:30", "name": "workout" }
]
```

`emoji` and `theme` are optional (`peach`, `lavender`, `mint`, `sky`, `sunset`). A `{ "alarms": [...] }` wrapper is also accepted.

## Where your data lives

Alarms and settings are stored as readable JSON — safe to edit by hand:

```
~/Library/Application Support/AlarmForMac/alarms.json
~/Library/Application Support/AlarmForMac/settings.json
```

## License

Released under the [MIT License](LICENSE).
