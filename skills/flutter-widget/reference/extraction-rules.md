# Extraction Rules — When to Split a Widget

A widget should be extracted into its own class when **any** of these are true:

## Strong signals (extract)

1. **You're tempted to write `Widget _buildSomething()`.** Always extract instead.
2. **The piece has its own state.** A toggle, a hover effect, a controller — give it its own `StatefulWidget`.
3. **The piece can be `const` but its parent cannot.** A `const` child of a non-`const` parent is a free performance win.
4. **The piece rebuilds for different reasons than its siblings.** If a counter changes but the header doesn't, they should be separate widgets so the header can skip rebuilding.
5. **The piece appears more than once.** Even twice. Extract it.
6. **The piece is conceptually independent.** "The user avatar", "the price chip", "the empty state" — each is a thing with a name. Things with names get classes.
7. **`build()` is over ~30 lines.** Find the biggest cohesive chunk and extract it. Repeat.

## Weak signals (consider extracting)

- Nesting depth in `build()` exceeds ~5 levels.
- A `children: [...]` list has more than ~4 entries that are each more than one line.
- You want to add a comment like `// the header` above a chunk of widget tree. The comment is a sign the chunk wants a name.

## When NOT to extract

- A single `Padding` around a single child.
- A `SizedBox(height: 8)` spacer. Just write it inline as `const`.
- Trivial one-liners that only appear once and have no state.

The goal is clarity and rebuild scope, not maximum granularity. Extract when it helps; don't extract just to extract.

## Public vs private

- **Public widget** (top of file, no underscore): the API of the file. Used by other files.
- **Private widget** (underscored class name, lower in the file): implementation detail of this file only.

Prefer private widgets for everything that's only used inside the current file. They keep your public API small without sacrificing structure.

## Passing data down

When extracting, pass exactly what the child needs — no more. Don't pass the parent's whole model when the child only reads two fields.

```dart
// Wrong — couples _Header to the entire User type
class _Header extends StatelessWidget {
  const _Header({required this.user});
  final User user;
  @override
  Widget build(BuildContext context) => Text(user.name);
}

// Right — _Header depends only on a String
class _Header extends StatelessWidget {
  const _Header({required this.name});
  final String name;
  @override
  Widget build(BuildContext context) => Text(name);
}
```

The narrower the dependency, the more reusable and testable the widget.
