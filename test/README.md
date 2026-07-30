# TravelMate test suite

The suite is organised by **testing level**, following the development-testing
hierarchy (unit → object class → component) and the levels above it (integration
→ system), plus two cross-cutting suites that are defined by *concern* rather
than by level.

Each level answers a different question. Reading a folder name should already
tell you what kind of failure a test in it reports.

```
test/
├── helpers/       shared harness — fakes, fixtures, widget/app plumbing
├── unit/          one function, in isolation
├── object/        one class, over its whole API and every state
├── component/     one widget or screen, through its own interface
├── integration/   several layers wired together, across their interfaces
├── system/        the whole assembled app, driven like a user would
├── regression/    specific bugs that were fixed and must stay fixed
└── security/      adversarial checks on the data-at-rest guarantees
```

Everything runs headless under `flutter test` — no emulator, no device. That is
possible because the production code depends on abstractions (`ProfileDao`,
`ChatDao`, `AccountDao`, `SecureKeyStore`, `ProfileDataSource`, …) rather than
on `sqflite` / `flutter_secure_storage` directly, so the fakes in
`helpers/fakes.dart` can stand in for the native plugins.

```bash
flutter test
```

```bash
flutter test --coverage
```

---

## The levels

### `unit/` — testing a function

The smallest testable pieces: pure top-level functions and static methods with
no state and no dependencies. Same input, same output, every time.

| File | Under test |
|---|---|
| `search_test.dart` | `filterTrips`, `filterMates` — ranking and multi-term matching |
| `chat_logic_test.dart` | `resolveAutoReply`, `mateLikesTrip` |
| `validation_test.dart` | `AccountValidation`, `TagInput` — every boundary, driven off the published constants |
| `codec_test.dart` | `TripTagCodec` — round trip and tolerance of malformed stored data |
| `crypto_test.dart` | `AesCipher`, `PasswordHasher` as *algorithms* |

### `object/` — testing a class

Where a unit test exercises one function, an object class test exercises one
**class**: every operation it exposes, over every state it can hold —
constructor defaults, derived getters, `copyWith`, JSON round trips, and the
notifications a store emits as its state moves.

| File | Under test |
|---|---|
| `model_classes_test.dart` | `PersonalProfile`, `PrivacySettings`, `ChatMessage`, `SavedTripPreview`, `TripTag`, `TripTileData`, `MateProfile` |
| `catalog_classes_test.dart` | `TripCatalog`, `TripTagCatalog`, `TripMediaCatalog`, `MateCatalog`, `NavigationDefaults`, `NavigationStyle`, `AppSizes` |
| `navigation_controller_test.dart` | `NavigationController`, `NavigationScope` |
| `chat_store_test.dart` | `ChatStore` — messages, online/offline transitions, timers |
| `store_classes_test.dart` | `PersonalProfileStore`, `PrivacySettingsStore`, `SearchResearchModeStore`, `SavedTripPreviewStore`, `TripStore`, `AuthService` |

### `component/` — testing a widget or screen

A component is several classes composed behind one interface. Screens take
their collaborators (a credential validator, a photo picker) as constructor
parameters, so each one is driven through its **own** interface with stubs
behind it — never through the real `AuthService` or the real gallery.

| File | Under test |
|---|---|
| `widgets_test.dart` | the shared widget library |
| `screens_test.dart` | each screen pumped on its own |
| `auth_screens_test.dart` | `LoginScreen`, `CreateAccountScreen` |
| `saved_items_test.dart` | the Saved tab's bookmark-resolution fallbacks |
| `home_screen_test.dart` | Home's tab hand-off and trip shortcuts |
| `chat_invite_test.dart` | attaching a trip to a chat, accept vs decline |
| `profile_photo_test.dart` | `ProfilePhoto` sources, the upload flow |
| `snackbar_test.dart` | `AppSnackBar` |

### `integration/` — testing the interfaces between layers

Each piece is already covered alone; these tests wire the layers together and
check what happens *between* them. Only the bottom edge is faked — the DAO and
the key store, which are the SQLite and keychain plugins.

```
ProfileKeyProvider → AesCipher → ProfileRepository → ProfileDao
                                        ↑
                                SqliteProfileData (+ legacy migration)
```

| File | Under test |
|---|---|
| `profile_persistence_test.dart` | key provider → cipher → repository → DAO, plus migration |
| `chat_persistence_test.dart` | the same stack for chat, plus `ChatStore` on top |
| `auth_persistence_test.dart` | encrypted username *and* hashed password together |
| `trip_persistence_test.dart` | seeding once, ordering, tags and image lists |
| `legacy_storage_test.dart` | the `SharedPreferences` sources still on the read path |
| `profile_image_storage_test.dart` | the real file-system copy into app storage |

### `system/` — testing the assembled app

The real `TravelMateApp` widget, the real screens, the real singleton stores.
Nothing is stubbed except the platform plugins. These tests follow a complete
task the way a person would perform it, entirely through the UI — no store is
poked directly, no screen is constructed by hand.

| File | Under test |
|---|---|
| `app_boot_test.dart` | the app boots *locked*, and only a valid credential unlocks it |
| `app_journeys_test.dart` | tab navigation, bookmark-on-one-tab-shows-on-another, chat history outliving the screen, logout re-locking the app |

> The two journey groups render at different surface sizes on purpose. The
> bottom navigation row needs a landscape surface for all four labels to fit,
> while the schedule screen does not scroll and needs a portrait one for its
> bookmark control to stay on-screen. No single size satisfies both.

---

## The cross-cutting suites

### `regression/`

Not organised by level. Each test names a **specific defect** that was reported
and fixed, and asserts the behaviour that replaced it — so a change that
quietly reintroduces the bug fails with an obvious label instead of somewhere
unrelated. Currently pinned:

- snackbars used to queue up and linger (rapid toggling left a backlog)
- chat message ids used to restart at 1 after a restart
- the bookmark button used to swap icons instead of colours
- legacy data used to be migrated more than once
- profile photos must stay paths, never bytes

### `security/`

The other suites ask *"does it work?"*. These ask *"what does an attacker get
if they read the database file, and what happens if they change it?"* Three
properties are defended:

1. **Confidentiality** — no sensitive value is recoverable from a stored row,
   and the same value never encrypts to the same ciphertext twice.
2. **Integrity** — a modified ciphertext is rejected, not silently accepted.
3. **Irreversibility** — the password is stored so that not even the app can
   turn it back into the secret the user typed.

Plus hostile-input handling: SQL metacharacters and wildcards are treated as
data, never as query fragments.

---

## `helpers/`

| File | Contents |
|---|---|
| `fakes.dart` | in-memory DAOs, data sources and key store; cipher and repository factories |
| `fixtures.dart` | builders for domain objects, so a test states only the fields it asserts on |
| `test_harness.dart` | asset-bundle stub, widget wrappers, store resets, render-surface control, whole-app driving (`pumpApp`, `logIn`, `openTab`) |

`test_harness.dart` re-exports the other two, so a test file needs one helper
import.

### Two things worth knowing

- **`ignoreRenderFlexOverflow()` must be called from the test body**, not from
  `setUp` — the test binding installs its own `FlutterError.onError` when the
  test starts and would overwrite an earlier override. `pumpApp` installs it
  for you.
- **`pumpTransition` settles rather than pumping a fixed duration.** A
  `pushReplacement` only disposes the route it replaced once the animation
  completes, and a route still animating in is wrapped in an `IgnorePointer`,
  so taps on it silently miss.
