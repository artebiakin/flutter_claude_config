# Testability Patterns

Read this when the user asks for tests, says testability matters, or asks to refactor for testing.

The skill's general philosophy: **if a widget is well-structured, the test is trivial.** Most testability problems are really structure problems.

## The rule that makes everything else easy

> A widget receives all its inputs through its constructor. It does not reach out to fetch anything.

If a widget reads from a global, calls an API, or accesses `SharedPreferences`, you cannot test it without setting up those things. If everything comes from the constructor, the test is just:

```dart
testWidgets('shows the user name', (tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: UserPage(user: User(id: '1', name: 'Ada')),
  ));
  expect(find.text('Ada'), findsOneWidget);
});
```

## Patterns

### Pattern: page = data-fetcher wrapper + presentational widget

Split a screen into:

- A **page** (`HomePage`) that owns the data fetch and a `ValueNotifier<HomeState>`.
- A **view** (`HomeView`) that takes `HomeState` and callbacks via its constructor.

The view is what you test. It needs no mocks because it has no dependencies — just data in, callbacks out.

```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.repository});
  final HomeRepository repository;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final _state = ValueNotifier<HomeState>(HomeState.loading());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _state.value = HomeState.loading();
    try {
      final items = await widget.repository.fetch();
      _state.value = HomeState.data(items);
    } catch (e) {
      _state.value = HomeState.error(e.toString());
    }
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<HomeState>(
      valueListenable: _state,
      builder: (_, state, __) => HomeView(state: state, onRetry: _load),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.state, required this.onRetry});
  final HomeState state;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) { ... }
}
```

Now `HomeView` is testable for every state (loading, data, error) by just passing the state in.

### Pattern: callbacks instead of navigation

A reusable widget should not call `Navigator.push` directly. It should accept an `onTap` callback. The page wires up navigation. This makes the reusable widget independent of the routing setup.

### Pattern: `Key`s for finding things in tests

When a widget appears more than once on a screen (e.g., two "Save" buttons), give them distinct `Key`s so tests can find the right one with `find.byKey(...)`.

### Pattern: pumping the right thing

Always wrap the widget under test in at least `MaterialApp` (or `Directionality` + `MediaQuery` for the minimal case). `Scaffold` is often needed too. Some widgets require an `Overlay`. If you see "No Material widget found" errors, the wrapper is missing.

## What tests should cover

- The widget renders the expected text/icons for given inputs.
- Tapping a button calls the callback (use a captured variable or `mockito`/`mocktail`).
- State transitions render the right UI (loading → spinner, error → error text, data → list).
- For text fields: typing updates the controller and triggers the right callback.

What widget tests should **not** try to cover: business logic. That's for unit tests on plain Dart classes.
