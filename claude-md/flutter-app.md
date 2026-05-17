# [Project Name]

[One-paragraph description of what this app does and who uses it.]

## Stack

- Flutter 3.x / Dart 3
- State management: [setState + ValueNotifier | Riverpod | Bloc | Provider]
- Networking: [dio | http | retrofit]
- Persistence: [shared_preferences | hive | drift | sqflite]
- Routing: [go_router | auto_route | Navigator 1.0]
- Testing: `flutter_test`, `mocktail`, [integration_test | patrol]

## Layout

```
lib/
├── main.dart
├── app/                  # MaterialApp, theming, routing
├── core/                 # cross-feature primitives (errors, result type, theme tokens)
├── data/                 # API clients, DTOs, repositories
├── features/
│   └── <feature>/
│       ├── data/         # feature-scoped repositories/datasources
│       ├── domain/       # entities, use cases
│       └── presentation/
│           ├── screens/
│           └── widgets/
└── shared/               # widgets used by multiple features
```

## Commands

```bash
flutter pub get                          # install deps
flutter run                              # run on connected device
flutter test                             # all tests
flutter test test/path/to/file_test.dart # one file
flutter analyze                          # static analysis (must be clean before commit)
dart format .                            # format
flutter build apk --release              # release build
```

## Conventions

- **Widgets:** the `flutter-widget` skill is the source of truth. Read it before writing widget code. Key rules: no `Widget _buildX()` methods, `const` everywhere it compiles, `build()` is composition only, smallest possible rebuild scope.
- **Files:** one public widget per file, `snake_case` filenames matching the class.
- **State:** push state as far down the tree as it can go. Don't `setState` at the top of a large widget — split it or use `ValueNotifier` + `ValueListenableBuilder`.
- **Async in widgets:** never start async work inside `build`. Use `initState` or a state-management layer.
- **No string literals in UI:** pull from your localization layer.
- **No hard-coded colors/sizes:** use `Theme.of(context)` / design tokens.
- **Lints:** `analysis_options.yaml` enables `flutter_lints` plus `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `prefer_const_declarations`, `avoid_print`, `require_trailing_commas`.

## Testing

- Every widget gets a widget test under `test/`.
- Use `mocktail` for fakes; never hit the network in unit/widget tests.
- Integration tests live under `integration_test/` and run with `flutter test integration_test`.

## Definition of done (for any change)

1. `flutter analyze` is clean.
2. `flutter test` passes.
3. `dart format .` produces no diff.
4. No new TODOs without a tracking issue.
5. Manually verified the feature on at least one platform target ([iOS simulator | Android emulator | Chrome]).

## Things to avoid

- Don't introduce a new state-management library without discussion.
- Don't add a new dependency unless the alternative is hand-rolling something non-trivial.
- Don't put business logic in widgets (HTTP calls, parsing, validation belong in plain Dart classes the widget receives via its constructor).
- Don't use `GlobalKey` unless reaching into another widget's state is genuinely required.
- Don't ignore lints — fix or justify.
