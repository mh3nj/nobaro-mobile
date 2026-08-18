<!--
  README image guide
  ------------------
  Drop the banner artwork into:  docs/banner.png   (recommended 1280 x 640 or wider)
  Drop screenshots into:         docs/screenshots/ (name them 01-today.png, 02-editor.png,
                                                   03-gallery.png, 04-themes.png, ...)
  Drop the demo video into:      docs/videos/demo.mp4 (or replace the link below with a
                                                    YouTube URL once published)
  Keep the filenames used below in sync and the repository stays self-documenting.
-->

<p align="center">
  <img src="docs/banner.png" alt="Nobaro Mobile" width="720"/>
</p>

<h1 align="center">Nobaro — Mobile</h1>

<p align="center">
  Your digital soul, in your pocket.<br/>
  An offline-first journal for Android, built with Flutter.
</p>

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.38+-blue.svg)](https://flutter.dev/)
[![Platform: Android](https://img.shields.io/badge/Platform-Android-3DDC84.svg)](https://www.android.com/)
[![Release: v1.0.0](https://img.shields.io/badge/Release-v1.0.0-green.svg)](https://github.com/mh3nj/nobaro-mobile/releases)

</div>

> **Origin.** This project started life as
> [Lifenote](https://github.com/mh3nj/lifenote), was rebranded and redesigned
> in Python as [Nobaro](https://github.com/mh3nj/nobaro), and is now available
> for Android users as a Flutter application — this repository,
> [nobaro-mobile](https://github.com/mh3nj/nobaro-mobile). The desktop and
> mobile apps share the same design language, the same gamification rules, and
> the same on-disk note format, so a journal written on one reads cleanly on
> the other.

---

## About

Nobaro Mobile is a quiet place to write. It is a journaling application with
no cloud, no accounts, no ads, and no algorithm deciding what you should write
about. Every entry is stored as a plain JSON file on your device and stays
there.

The interface leans into the retro computing aesthetic the project is known
for — a monospace typeface, chiptune-style beeps synthesized on-device, and a
classic blue-screen theme among eight built-in options. The result is a
writing experience that feels personal rather than corporate, and works
completely offline.

## Screenshots

<p align="center">
  <img src="docs/screenshots/load.webp" alt="Loading screen"/>
  <img src="docs/screenshots/main-screen.webp" alt="Note editor"/>
  <img src="docs/screenshots/settings ad about.webp" alt="ASCII art gallery"/>
  <img src="docs/screenshots/history-log.webp" alt="Theme selection"/>
  <img src="docs/screenshots/entry.webp" alt="Theme selection"/>
  <img src="docs/screenshots/ascii arts.webp" alt="Theme selection"/>
</p>

## Video demo

[nobaro-mobile.webm](https://github.com/user-attachments/assets/a21a169a-c57d-41e7-a5a3-25077dea8fd6)


## Features

- **Unlimited notes per day.** Write as much as you like, every single day.
- **Mood tracking.** Tag each entry with a mood and watch it accumulate into a
  personal mood history.
- **Gamification, kept gentle.** Earn experience points, gain levels, build
  streaks, and unlock achievements for showing up consistently.
- **ASCII art gallery.** A built-in collection of retro art to drop into any
  note — plus the ability to **paste your own art**, which is saved forever
  and can be edited or deleted at any time.
- **Note templates.** Daily check-ins, gratitude logs, weekly reflections, and
  letters to yourself, ready in one tap.
- **Sealed letters.** Write a note today and lock it until a future date; it
  stays hidden until that day arrives.
- **Retro screensaver.** A bouncing, mood-lifting screensaver for idle
  moments.
- **Eight themes.** From Classic DOS blue to warm paper and midnight ink.
- **Advanced search.** Filter by include/exclude words, tags, moods, and date
  ranges.
- **Text to speech.** Listen to any entry read aloud.
- **Exports and backups.** Export everything to plain text, or create local
  backups of your journal.
- **Burn notes.** Some memories are ash — burn an entry permanently when you
  are ready to let it go.

## Getting started

### Install the app

Grab the latest APK from the
[Releases](https://github.com/mh3nj/nobaro-mobile/releases) page and install it
on your Android device (Android 7.0 or newer). No account, no permissions
beyond what the app needs, no internet connection required.

### Build from source

You will need the [Flutter SDK](https://docs.flutter.dev/get-started/install)
(3.38 or newer).

```bash
flutter pub get
flutter run
```

To produce a release APK:

```bash
flutter build apk --release
```

The APK lands in `build/app/outputs/flutter-apk/app-release.apk`.

### Adding other platforms

This repository currently ships Android platform files only. To add iOS,
macOS, Linux, Windows, or web support:

```bash
flutter create --platforms=ios .
flutter pub get
```

## Project structure

```
lib/
  core/            constants, data models, utilities (dates, sound, XP/leveling)
  data/            repositories (JSON file storage) and session state
  design/          theme system and reusable widgets (paper, mood graph)
  features/        one folder per screen (today, editor, timeline, settings, ...)
  router/          route name constants
  main.dart        application entry point
assets/
  logo.png         full-color app mark
  logo_mono.png    white silhouette used where the logo is tinted
  fonts/           JetBrains Mono and Literata variable fonts
test/              widget tests
docs/              banner, screenshots, and demo video (see top of file)
```

## Data and privacy

Everything is stored locally as plain JSON files inside the application's
documents directory:

- Notes live in the `Nobaro/Database` folder.
- Backups, exports, and media have their own folders under `Nobaro/`.
- User-created ASCII art and templates are stored as JSON files next to the
  app data.

There is no cloud sync, no telemetry, and no tracking. Uninstalling the app
removes its data, so export or back up before you uninstall if you want to
keep your journal.

## Relationship to the desktop app

Nobaro Mobile is not a one-to-one port. A few things are deliberately
simplified for a touch interface — the editor is plain text, with rich text
scheduled for a later release — while some things go further than the desktop
version, such as a richer multi-filter search screen and eight themes instead
of five.

Where the two apps overlap — XP amounts, achievement conditions, streak
bonuses, and the chiptune melodies — they are kept in exact parity on purpose,
because both apps can read the same note files without any conversion step.

## Contributing

Contributions are welcome. Please read
[CONTRIBUTING.md](CONTRIBUTING.md) first — it covers the development setup,
code style, and the pull request workflow.

## Reporting issues

Found a bug or have an idea? Open an issue. Please check
[ISSUES.md](ISSUES.md) for guidance on what to include so problems can be
reproduced quickly.

## License

MIT — see [LICENSE](LICENSE).
