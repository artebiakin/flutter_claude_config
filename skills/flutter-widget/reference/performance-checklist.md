# Performance Checklist

Read this when the user mentions performance, jank, slow rebuilds, frame drops, or list performance.

## The rebuild model

A widget rebuilds when:
1. Its parent rebuilds and passes new arguments (or the parent isn't `const`).
2. It listens to something (`InheritedWidget`, `Listenable`, `Stream`) that changed.
3. Its `State.setState` was called.

The goal is to make `(1)` cheap (via `const`) and `(2)` and `(3)` narrowly scoped (via `ValueListenableBuilder` at the leaves).

## Checklist

### `const` everywhere it compiles
- Every `final`-only-fields constructor: `const`.
- Every widget instantiation with constant arguments: prefix with `const`.
- `EdgeInsets.all(8)` → `const EdgeInsets.all(8)`.
- `SizedBox(height: 16)` → `const SizedBox(height: 16)`.
- `Text('Hello')` → `const Text('Hello')`.

### Narrow `MediaQuery` accessors
Use `MediaQuery.sizeOf(context)` not `MediaQuery.of(context).size`. Same for `viewInsetsOf`, `paddingOf`, `textScalerOf`, etc.

### Lift state down, not up
Put `ValueNotifier`s as low as possible — ideally owned by a `StatefulWidget` near the leaves that need them. If state must live higher for other reasons, wrap **only** the leaf in a `ValueListenableBuilder` so the rest of the subtree doesn't rebuild.

### `RepaintBoundary` for expensive painters
If you have an animated subtree adjacent to a static expensive one (e.g., a chart next to a ticking clock), wrap the static one in `RepaintBoundary` to isolate paints. Don't sprinkle `RepaintBoundary` randomly — it has overhead. Use it where a profile shows redundant repainting.

### Lists: builders, not `Column` + `for`
For long lists, use `ListView.builder` / `SliverList.builder`. They only build visible items. For known small lists (~10 items), a `Column` with a `for` loop is fine.

### Stable callback identity in hot paths
If you pass a callback to a child that rebuilds at 60fps (animation tick, scrolling list), the callback should be a named method on the `State` so identity is stable. Inline closures rebuild every frame and can defeat child memoization.

### Avoid work in `build()`
`build()` can run many times per second. Don't:
- Sort/filter lists in `build()` — do it when the input changes (in a setter, or in `didUpdateWidget`).
- Construct `RegExp`, `Intl`, or heavy formatters in `build()` — cache them in `State` fields.
- Parse strings or do math you can do once.

### `AnimatedBuilder` for animations
For animation-driven UI, use `AnimatedBuilder` with `child:` for the static subtree. The static `child` is passed through unchanged on every tick — only the part inside the `builder` rebuilds:

```dart
AnimatedBuilder(
  animation: controller,
  child: const ExpensiveStaticThing(),
  builder: (context, child) => Transform.rotate(
    angle: controller.value * pi,
    child: child, // built once, reused every frame
  ),
)
```

### Images
- Use `cacheWidth` / `cacheHeight` on `Image.network` / `Image.asset` to decode at display size, not full resolution.
- Use `Image.memory` only when you actually have bytes; otherwise prefer the provider that matches your source.

### Profile before optimizing further
The above covers 95% of cases. Beyond that, use DevTools Performance overlay and the Timeline. Don't guess.
