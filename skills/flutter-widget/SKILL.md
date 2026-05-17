---
name: flutter-widget
description: Write Flutter widgets (Flutter 3.x / Dart 3) that are simple, testable, and performance-focused. Use this skill whenever the user asks for a Flutter widget, screen, page, component, UI element, or any `.dart` file containing widgets — even if they don't say "skill". Also use when refactoring existing Flutter UI code, fixing rebuild/performance problems, or reviewing widget code. The skill enforces a strict ban on common LLM anti-patterns: `Widget _buildX()` methods, missing `const`, bloated `build()` bodies, and business logic mixed into widgets.
---

# Flutter Widget Skill

A skill for producing Flutter widgets that are **simple, testable, and high-performance** by default — and for refusing to produce widgets that are not.

This skill assumes plain Flutter state management (`setState` + `ValueNotifier` / `ValueListenableBuilder`). It does not use Riverpod, BLoC, or Provider.

---

## How to use this skill

Before writing any widget code, follow this loop:

1. **Read `reference/anti-patterns.md`** — the hard-blocked patterns. Most quality issues come from these.
2. **Read `reference/extraction-rules.md`** — when to split a widget into another widget.
3. If the user asked about performance specifically, read `reference/performance-checklist.md`.
4. If the user asked for tests or said "testable matters here", read `reference/testability-patterns.md`.
5. Draft the code using the templates in `templates/` as starting points.
6. **Run the self-check at the bottom of this file before returning code.** This is non-negotiable.

You do not need to read every reference file every time. But you **must** read `anti-patterns.md` every time — it is short and it is what prevents the most common failure modes.

---

## Core principles (in priority order)

1. **A widget is a class, not a method.** If you find yourself writing `Widget _buildSomething()`, stop and extract a `StatelessWidget`. There is no exception to this rule in this skill.
2. **`const` everywhere it compiles.** Every constructor that can be `const` must be `const`. Every widget instance that can be `const` must be `const`.
3. **`build()` is for composition, not logic.** Put computation, side effects, and decisions outside `build()`. `build()` reads state and returns widgets.
4. **Smallest possible rebuild scope.** Push `ValueListenableBuilder` / `AnimatedBuilder` / `StreamBuilder` as deep as possible. Never rebuild a screen for a checkbox.
5. **Stateless until proven otherwise.** Default to `StatelessWidget`. Promote to `StatefulWidget` only when local mutable state is needed.
6. **Widgets receive data; they don't fetch it.** Constructors take what the widget needs. Pages or controllers handle loading. This is what makes widgets testable.

---

## When to use `StatelessWidget` vs `StatefulWidget` vs `ValueNotifier`

| Situation | Use |
|---|---|
| Pure presentation from constructor args | `StatelessWidget` |
| One-off local state (a toggle, a controller lifecycle) | `StatefulWidget` |
| State that is read in many places or needs scoped rebuilds | `ValueNotifier<T>` + `ValueListenableBuilder<T>` |
| Multiple related fields that change together | Custom `ChangeNotifier` + `AnimatedBuilder` or a dedicated `Listenable` |
| Async data | `FutureBuilder` / `StreamBuilder` at the smallest scope possible |

Avoid `setState` at the top of a large widget. Either split the widget, or lift the changing data into a `ValueNotifier` and rebuild only the leaves that depend on it.

---

## Default file shape

A widget file should look like this, in this order:

```dart
// 1. Imports (dart:, package:flutter, then package: third-party, then relative)

// 2. Public widget(s) — the API the file exposes
class MyThing extends StatelessWidget { ... }

// 3. Private widgets used only inside this file
class _Header extends StatelessWidget { ... }
class _Body extends StatelessWidget { ... }

// 4. Private helpers (pure functions, no widget returns)
String _formatLabel(int n) => ...;
```

Never put private widgets at the bottom as `_buildX()` methods on the main class. Make them real classes — prefixed with `_` to keep them library-private.

---

## Mandatory self-check before returning code

Before you return Flutter code to the user, walk this list. If any item fails, fix it before responding.

1. **No `Widget _build*()` methods.** Search the code. Zero matches. Anything that returned a widget from a method is now a `StatelessWidget` (or `StatefulWidget`) class.
2. **Every possible constructor is `const`.** A constructor can be `const` if all its fields are `final` and all its field initializers are constant expressions. If you can add `const` and the analyzer would accept it, it must be there.
3. **Every possible widget instance is `const`.** `const SizedBox(height: 8)`, not `SizedBox(height: 8)`. Same for `Text`, `Icon`, `Padding` with literal values, etc.
4. **`build()` bodies are short.** Aim for under ~30 lines of widget tree. If `build()` is longer, you almost certainly need to extract a child widget. Long `Column`/`Row` children lists are a strong extraction signal.
5. **No business logic in widget classes.** No HTTP calls, no database access, no `Timer`s started from `build()`, no parsing, no validation logic. Those belong in plain Dart classes the widget receives via its constructor.
6. **No `MediaQuery.of(context)` when a narrower accessor works.** Prefer `MediaQuery.sizeOf(context)`, `MediaQuery.viewInsetsOf(context)`, `MediaQuery.paddingOf(context)`, etc. The narrow versions only rebuild on the relevant slice. Same idea: prefer `Theme.of(context)` only when you actually need the full theme; for colors prefer `Theme.of(context).colorScheme` accessed once and stored locally.
7. **Keys where they matter.** Lists of widgets that can reorder/insert/remove need keys. Conditional widgets that swap between similar types may need keys. Don't sprinkle `Key`s where they don't help, but don't omit them where state would be lost.
8. **`StatefulWidget` lifecycle is correct.** Controllers (`TextEditingController`, `AnimationController`, `ScrollController`, `FocusNode`) created in `initState` must be disposed in `dispose`. Subscriptions opened must be cancelled.
9. **No anonymous closures rebuilt every frame for hot paths.** For callbacks passed to children that are themselves rebuilt often (lists, animations), prefer named methods on the State class so identity is stable. For low-frequency callbacks (a button onPressed on a static screen), inline closures are fine.
10. **The widget would be testable as-is.** Could you instantiate this widget in a `testWidgets` test by passing constructor arguments only, without mocking anything global? If not, push the dependency up into the constructor.

If the user asked specifically for tests, also generate a test file using `templates/widget-test.dart` as a starting point.

---

## What to tell the user

Be brief in your prose. The user wants the widget, not a lecture. After returning the code, optionally call out one or two things if they're notable — e.g., "Extracted `_Header` and `_StatsRow` so the counter rebuild stays scoped" or "Used `ValueListenableBuilder` instead of `setState` so the parent doesn't rebuild." Don't list every rule you followed.

If the user's request would require breaking one of the core principles (for example, "put everything in one method"), explain the problem briefly and offer the right structure instead. Do not produce code you would have to flag in the self-check.

---

## Reference files

- `reference/anti-patterns.md` — **Read every time.** The blocked patterns and why.
- `reference/extraction-rules.md` — When to split a widget into a child widget.
- `reference/performance-checklist.md` — Rebuild scope, `const`, `RepaintBoundary`, etc.
- `reference/testability-patterns.md` — How to structure widgets so a `testWidgets` test is trivial.

## Templates

- `templates/stateless-widget.dart` — Starting point for a presentational widget.
- `templates/stateful-widget.dart` — Starting point with proper controller lifecycle.
- `templates/widget-test.dart` — Starting point for a widget test (use only when asked).
