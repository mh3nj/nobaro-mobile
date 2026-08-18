# Contributing to Nobaro Mobile

Thank you for taking the time to contribute. Nobaro is a small, personal
project that values clear, thoughtful code and a calm user experience. This
guide explains how to set up the project, what the code standards are, and how
to get changes merged.

## Code of conduct

Be respectful and constructive. This is a hobby project maintained by real
people; disagreement about implementation is welcome, personal attacks are
not. Harassment of any kind will result in a ban.

## Getting started

1. Fork the repository and clone your fork.
2. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install)
   (3.38 or newer).
3. Install dependencies and run the analyzer:

   ```bash
   flutter pub get
   flutter analyze
   ```

4. Run the app:

   ```bash
   flutter run
   ```

## Development workflow

1. Create a branch from `main` with a short, descriptive name:

   ```bash
   git checkout -b fix/note-save-overwrite
   ```

2. Make your changes. Keep them small and focused — one logical change per
   branch makes review faster and reverts safer.
3. Run the analyzer and the test suite before committing:

   ```bash
   flutter analyze
   flutter test
   ```

4. Format your code with the official formatter:

   ```bash
   dart format lib test
   ```

5. Commit with a clear message that describes the *why*, not just the *what*
   (see "Commit messages" below).
6. Push and open a pull request against `main`.

## Code style and conventions

- Follow the existing patterns in the codebase. Consistency matters more than
  personal preference here.
- Run `flutter analyze` and resolve every warning in code you touch. Do not
  introduce new analyzer warnings.
- Use the project's existing architecture:
  - **Models** live in `lib/core/models/` and own their JSON serialization.
  - **Persistence** lives in `lib/data/repositories/` and talks to disk only.
  - **Screens** live in `lib/features/<name>/` and stay UI-focused.
  - **Shared state** is handled through `SessionState` in
    `lib/data/session_state.dart`; do not introduce new global singletons
    casually.
- All user-visible strings should be plain and clear. This project deliberately
  avoids emojis in UI copy and in documentation.
- Keep ASCII art assets within the safe width documented in
  `lib/core/constants/ascii_art.dart` so art renders correctly on small
  phones.
- Do not add dependencies without a strong reason. This app is intentionally
  dependency-light and fully offline.

## Testing

- New logic should come with tests. Plain Dart logic (repositories, utilities,
  XP calculations) is the easiest to test and the most valuable.
- Widget tests live in `test/`. The default `widget_test.dart` is a starting
  point; extend it or replace it with meaningful coverage.
- Run `flutter test` and confirm existing tests still pass before opening a
  pull request.

## Commit messages

Write commit messages that read like a sentence describing the change and its
reason:

```text
Persist user-created ASCII art to disk

Custom arts now survive app restarts by being written to ascii_arts.json
in the application documents directory, matching the existing template
storage pattern.
```

- Use the imperative mood ("Persist", not "Persisted").
- Keep the first line under 72 characters.
- Add a body when the change is non-obvious — explain *why*, not *what*.

## Pull requests

- Reference the issue your PR fixes, e.g. `Fixes #12`.
- Describe what changed and how you tested it.
- Keep the diff reviewable. If a PR grows beyond one logical change, split it.
- Maintainers will review, request changes if needed, and merge once CI and
  review pass.

## Reporting bugs and feature ideas

Bugs and feature requests go through the issue tracker. Please follow
[ISSUES.md](ISSUES.md) and use the provided issue templates so maintainers can
reproduce and act on reports quickly.

## Where to ask questions

Prefer issues over private messages. If a question is not a bug report or a
feature request, open a discussion-style issue with a clear title so others
with the same question can find the answer later.
