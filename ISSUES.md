# Issues

This document explains how to report bugs and request features for Nobaro
Mobile. A well-written issue gets fixed faster — and a poorly written one
usually just gets closed.

Before opening anything, please:

1. Search the existing issues. Your problem or idea may already be tracked.
2. Check the latest release. The bug may already be fixed.
3. Confirm you are on the latest APK and a supported Android version (7.0+).

## Bug reports

Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) and
include:

- **Device and OS version.** Manufacturer, model, and Android version (find it
  in Settings > About phone).
- **App version.** The version shown in the app's System Settings screen, or
  the APK filename you installed.
- **Steps to reproduce.** Numbered steps, starting from a fresh app launch.
  Be specific: which screen, which button, what you typed.
- **Expected behavior.** What you expected to happen.
- **Actual behavior.** What actually happened.
- **Screenshots or screen recordings.** A picture is worth a thousand words,
  and a recording is worth a thousand pictures.
- **Anything unusual.** Did it happen after a specific action, like inserting
  an ASCII art piece, sealing a letter, or restoring a backup?

Bugs that cannot be reproduced cannot be fixed. If a crash occurred, capture
the log with:

```bash
adb logcat | grep -i flutter
```

and attach the relevant portion.

## Feature requests

Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md)
and describe:

- **The problem.** What are you trying to do that the app makes difficult?
- **The proposed solution.** Describe the feature as you imagine it, including
  where it would live in the UI.
- **Alternatives.** Anything you currently do as a workaround.
- **Why it fits Nobaro.** This is an offline-first, dependency-light app with
  a retro aesthetic. Features that respect those values are much more likely
  to be accepted.

## Issue labels

Maintainers use labels to triage. A quick guide:

- `bug` — a defect confirmed or awaiting confirmation.
- `enhancement` — a feature request.
- `good first issue` — approachable for new contributors.
- `help wanted` — the maintainer would appreciate help implementing this.

## What happens after you file

Issues are reviewed in batches. There is no SLA — this is a hobby project —
but you will usually get a reply within a few days. If your issue is closed
without comment, it was likely a duplicate or missing too much information;
feel free to reopen it with the missing details.

## Security issues

Please do not open a public issue for security vulnerabilities. Report them
privately to the repository owner so they can be addressed before details are
published.
