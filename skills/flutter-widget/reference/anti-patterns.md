# Flutter Widget Anti-Patterns (Blocked)

Read this every time before writing widget code. These are the patterns that produce slow, fragile, untestable Flutter UIs — and they are exactly the patterns LLMs tend to emit by default. They are blocked in this skill.

---

## 1. ❌ `Widget _buildX()` methods inside a widget class

This is the single most common LLM Flutter mistake. Do not do it.

**Wrong:**

```dart
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildStats(),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader() => const Text('Profile');
  Widget _buildStats() => const Row(children: [Text('0'), Text('0')]);
  Widget _buildActions(BuildContext context) => Row(children: [
        ElevatedButton(onPressed: () {}, child: const Text('Edit')),
      ]);
}
```

**Why it's bad:**

- The "sub-widget" rebuilds every time the parent rebuilds. There is no boundary the framework can use to skip it.
- It cannot be `const`. The method runs on every call.
- It does not appear as its own node in the Flutter Inspector — harder to debug.
- It cannot be tested in isolation. To exercise `_buildStats`, you have to build the whole `ProfilePage`.
- It encourages closing over `this`, which silently couples the sub-widget to every field of the parent.

**Right:**

```dart
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          _Header(),
          _Stats(count: 0, followers: 0),
          _Actions(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => const Text('Profile');
}

class _Stats extends StatelessWidget {
  const _Stats({required this.count, required this.followers});
  final int count;
  final int followers;
  @override
  Widget build(BuildContext context) =>
      Row(children: [Text('$count'), Text('$followers')]);
}

class _Actions extends StatelessWidget {
  const _Actions();
  @override
  Widget build(BuildContext context) => Row(children: [
        ElevatedButton(onPressed: () {}, child: const Text('Edit')),
      ]);
}
```

Now `_Header` and `_Actions` are `const` — they never rebuild. `_Stats` only rebuilds when its inputs change. Each one is a real node in the inspector, each one is independently testable, and the parent's `build()` reads like a table of contents.

**The rule:** A widget is a class. Always. If you wrote `Widget _buildAnything()`, delete the method and write a class.

---

## 2. ❌ Missing `const` on constructors and instances

**Wrong:**

```dart
class Tag extends StatelessWidget {
  Tag({super.key, required this.label});       // not const
  final String label;
  @override
  Widget build(BuildContext context) =>
      Container(padding: EdgeInsets.all(4), child: Text(label));
  //  ^ not const            ^ not const         ^ unavoidable, but Text could be Text(label) only because label isn't const
}

// usage
Tag(label: 'new')                              // not const
```

**Right:**

```dart
class Tag extends StatelessWidget {
  const Tag({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        child: Text(label),
      );
}

// usage
const Tag(label: 'new')   // if label is a literal
Tag(label: someVariable)  // when label is dynamic — still benefits from const constructor
```

**Why it matters:** `const` widgets are canonicalized — Flutter reuses the same instance across rebuilds. The framework can short-circuit reconciliation. For widgets used in lists or rebuilt frequently, this is a measurable performance win and it's free.

**Rule of thumb:** if every field of a class is `final`, the constructor should be `const`. If every argument to a widget call site is a literal or another `const` expression, the call should start with `const`.

---

## 3. ❌ Long `build()` methods

If your `build()` body is more than ~30 lines of widget tree, you are missing extractions.

**Wrong:** a `build()` that scrolls for two screens, with nested `Column` → `Row` → `Column` → `Padding` → `Column` ...

**Right:** a `build()` that reads like an outline:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: const _AppBar(),
    body: Column(
      children: [
        _Hero(item: item),
        const _Divider(),
        Expanded(child: _Details(item: item)),
        _Footer(onConfirm: onConfirm),
      ],
    ),
  );
}
```

The reader can scan the structure in two seconds. Each piece can be modified, replaced, or tested independently.

---

## 4. ❌ Business logic in widget classes

Widgets are presentation. They receive data and callbacks. They do not:

- Call HTTP APIs (`http.get`, `Dio`, etc.)
- Read or write databases / `SharedPreferences` / files
- Parse JSON
- Do non-trivial computation in `build()`
- Start `Timer`s or `Stream` subscriptions from `build()`

**Wrong:**

```dart
class UserPage extends StatefulWidget {
  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    http.get(Uri.parse('https://api.example.com/me')).then((r) {
      setState(() => _user = User.fromJson(jsonDecode(r.body)));
    });
  }

  @override
  Widget build(BuildContext context) { ... }
}
```

**Right:** the widget receives a `User` (or a `ValueListenable<User?>`, or a `Future<User>`). A separate, plain-Dart class fetches it.

```dart
class UserPage extends StatelessWidget {
  const UserPage({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) { ... }
}
```

The widget is now trivial to test: pass a `User` in the constructor, pump the widget, verify the output. No HTTP mocking required.

---

## 5. ❌ `MediaQuery.of(context)` when a narrower accessor works

`MediaQuery.of(context)` subscribes the widget to **every** change in media query data — keyboard appearing, orientation change, text scale change, padding change, ALL of it. If you only need size, ask for size.

**Wrong:**

```dart
final width = MediaQuery.of(context).size.width;
```

**Right:**

```dart
final width = MediaQuery.sizeOf(context).width;
```

Also available: `viewInsetsOf`, `paddingOf`, `viewPaddingOf`, `devicePixelRatioOf`, `textScalerOf`, `platformBrightnessOf`, `orientationOf`. Use the narrowest one.

Same idea for `Theme.of(context)`: cache the value in a local `final` if you read multiple fields off it.

---

## 6. ❌ `setState` at the top of a large widget

If a screen has a counter at the bottom and tapping `+` calls `setState`, the *entire screen* rebuilds. That's wasteful.

**Wrong:**

```dart
class _DashboardState extends State<Dashboard> {
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ExpensiveHeader(),
          const ExpensiveChart(),
          Row(children: [
            Text('$_count'),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => setState(() => _count++),
            ),
          ]),
        ],
      ),
    );
  }
}
```

**Right:** lift `_count` into a `ValueNotifier` and only rebuild the leaf that reads it.

```dart
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _count = ValueNotifier<int>(0);

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ExpensiveHeader(),
          const ExpensiveChart(),
          _Counter(count: _count),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.count});
  final ValueNotifier<int> count;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ValueListenableBuilder<int>(
        valueListenable: count,
        builder: (_, value, __) => Text('$value'),
      ),
      IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => count.value++,
      ),
    ]);
  }
}
```

Now `ExpensiveHeader` and `ExpensiveChart` never rebuild when the counter changes. Only the `Text` inside `ValueListenableBuilder` does.

---

## 7. ❌ Forgetting to `dispose` controllers and subscriptions

Every `TextEditingController`, `ScrollController`, `AnimationController`, `FocusNode`, `ValueNotifier`, `StreamSubscription`, and `Timer` created in `initState` (or as a field) **must** be disposed/cancelled in `dispose`.

If you forget, you leak memory and may keep work running after the widget is gone.

---

## 8. ❌ Anonymous closures in hot paths

For a button on a static screen, `onPressed: () => doThing()` is fine.

For a list with thousands of items, or a callback that gets passed deep into a tree that rebuilds at 60fps, every rebuild creates a new closure with a new identity, which forces children that compare callbacks by identity to rebuild. Prefer a named method on the `State` class:

```dart
void _onItemTap(int id) { ... }

// later
return ItemRow(onTap: _onItemTap);  // identity stable across rebuilds
```

---

## 9. ❌ Missing keys in dynamic lists

When a list of widgets can be reordered, inserted into, or have items removed, the items need `Key`s — usually `ValueKey(item.id)`. Without keys, Flutter matches by position and can attach state to the wrong item (typing in TextField A jumps to TextField B after a reorder).

```dart
ListView(
  children: [
    for (final item in items)
      ItemTile(key: ValueKey(item.id), item: item),
  ],
)
```

---

## 10. ❌ `Expanded`/`Flexible` outside `Row`/`Column`/`Flex`

Common error LLMs make. `Expanded` only works inside a `Flex` widget. Using it in a `Stack` or `ListView` will throw at runtime. If you need flexible sizing in a `Stack`, use `Positioned.fill` or explicit constraints.

---

## Summary

The single sentence version: **make widgets classes, make them `const`, keep `build()` short, keep logic out, and make rebuilds local.**
