# Marketplace Backend Preparation — Phase 1

## Scope and current state

This repository is a Flutter storefront UI, not a backend-enabled marketplace. Inspection found no Firebase dependencies, Firebase configuration, Firestore/Storage rules, Cloud Functions, or server-side checkout. The product catalog is bundled in Dart source and checkout is explicitly simulated. No application behavior was changed in this phase.

A project copy was prepared before implementation at:

`C:\Users\princ\Downloads\Compressed\flutter_ecommerce_app-backup-20261010-164815`

The source directory is not a Git repository, so there was no Git history or worktree available to use as a rollback point.

## Existing application architecture

- **Startup:** `lib/main.dart` calls `runApp(const MyApp())` synchronously. `MyApp` builds the themed `MaterialApp` and obtains its route map from `lib/src/config/route.dart`.
- **Active storefront route:** `/` builds `StoreMainPage` from `lib/src/pages/store_main_page.dart`.
- **UI composition:** `StoreMainPage` owns the current tab, favorite IDs and cart quantities; it displays the existing home/search/favorites/cart widgets and pushes product-detail and checkout routes. Existing screens, styles, animations and navigation are to remain in place.
- **Catalog:** `lib/src/model/data.dart` holds a static `AppData.productList` and category list. `lib/src/model/product.dart` is a small mutable UI model with integer IDs, optional display fields and UI selection/favorite flags.
- **Local persistence:** `shared_preferences` stores favorites and cart quantities on-device. It is not a secure or account-synchronized marketplace database.
- **Checkout:** `lib/src/pages/store_checkout_page.dart` gathers contact/delivery/payment selections, calculates a display total on-device, shows a generated demo order number, and invokes the `onPlaced` callback. The screen explicitly says details are not stored and payment is simulated. Its callback in `StoreMainPage` clears the local cart. It currently creates no persistent order.
- **Platform setup:** Android uses Kotlin DSL Gradle files, package/application ID `com.thealphamerc.flutter_ecommerce_app`, and the existing Flutter launcher activity. No Firebase Android configuration was found. The project also has an iOS directory, but the requested Firebase connection phase is Android-first.
- **Tests:** `test/widget_test.dart` checks that the existing storefront home content, navigation bar and search inputs render.

## Existing UI integration points

Keep the existing widget tree and visual design. The lowest-risk eventual integration seams are:

1. Initialize Firebase before `runApp` while preserving the current `MyApp` startup, theme and route construction.
2. Replace the static catalog data source behind `StoreHomePage`/`StoreMainPage` with a repository or stream adapter that maps backend product documents into the existing `Product` presentation model.
3. Replace local-only cart persistence behind `StoreMainPage` with a user-scoped cart repository, keeping current cart widgets and quantity callbacks.
4. Keep `StoreCheckoutPage` as the presentation flow, but delegate order creation to a trusted callable/server API; do not treat its client-side totals, demo payment choice or `onPlaced` as authoritative.
5. Connect profile and order presentation through data/auth services rather than changing the current storefront layout. The profile sheet is currently informational only; seller and administrator workflows do not exist in the active UI.

## Likely implementation files by phase

Exact files depend on Firebase project configuration and the later security/data design. This is an initial impact map, not permission to make all changes at once.

- **Phase 2 (Android Firebase setup):** `pubspec.yaml` and `pubspec.lock`; `lib/main.dart`; `android/settings.gradle.kts`; `android/app/build.gradle.kts`; generated `lib/firebase_options.dart`; and Firebase's Android `google-services.json` under `android/app/`. FlutterFire tooling may adjust platform Gradle configuration. Keep existing routing and startup behavior intact.
- **Phase 3 (authentication/profiles):** new auth/profile repository and model/service files under `lib/src/`; targeted connection to the existing profile entry point in `lib/src/pages/store_main_page.dart`; server-side role/approval logic and Firestore rules.
- **Phase 4 (catalog/shops/inventory):** product/shop/category repository and mapping files under `lib/src/`; connect data into `StoreMainPage`/`StoreHomePage` without replacing their widgets; Storage rules and server-side stock validation as applicable.
- **Phases 5–6 (cart, checkout and orders):** cart/order repository and models under `lib/src/`; a narrow service integration in `StoreMainPage` and `StoreCheckoutPage`; trusted server functions; Firestore rules and tests.
- **Phases 7–8 (payments, commission and payouts):** server-side payment/provider and ledger functions/configuration, auditable data models and targeted order-status UI connections. Provider secrets must stay outside Flutter and client configuration. No automatic payout should be enabled before verification.
- **Security/testing across phases:** restrictive Firestore/Storage rules, emulator or equivalent authorization tests, server-function tests, and updates/additions to `test/` while retaining the existing storefront widget test.

## First safe implementation step (Phase 2; not started)

After you choose or create the Firebase project and confirm it should use Android application ID `com.thealphamerc.flutter_ecommerce_app`, generate Android-specific FlutterFire configuration for that project. Then add Firebase initialization before `runApp` with a guarded/error-reporting startup path, leaving `MyApp`, routes, theme and screens unchanged. Validate the baseline and the change with `flutter pub get`, `flutter analyze`, `flutter test`, and an Android launch/build before adding authentication or marketplace data.

Do not add placeholder Firebase IDs or credentials. No Firebase project ID, `google-services.json`, or account authorization is present in the repository; the Firebase project choice and console access are required before Phase 2 can be performed safely.

## Phase 1 verification notes

- Inspected the existing app startup, route table, storefront state/data paths, checkout flow, Android app configuration and widget test.
- Confirmed no Firebase references or Firebase configuration in the inspected dependency/platform files.
- Confirmed this folder is not a Git repository.
- Created the project backup listed above; generated build/cache directories were intentionally excluded.
- No source code, existing UI, app configuration or dependencies were modified in this phase.


## Supabase connection stage — 2026-10-10
The initial architecture notes above describe the pre-backend inspection. For the current Supabase task, the existing route and storefront structure remains as described, and a minimal Supabase client bootstrap scaffold is now in place:

- `pubspec.yaml` / `pubspec.lock` include the official `supabase_flutter` package (resolved as 2.18.2).
- `lib/src/config/supabase_config.dart` reads `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` from Dart compile-time defines and considers the connection configured only if both are non-empty.
- `lib/main.dart` initializes Flutter bindings and initializes Supabase before `runApp` only when both values are provided. With no project credentials, it preserves the existing storefront startup without attempting a network connection.
- `supabase.env.example.json` documents the expected local configuration format. Copy it to the ignored `supabase.env.json`, replace both placeholders with values from the Supabase dashboard, and run the app with `flutter run --dart-define-from-file=supabase.env.json`. `supabase.env.json` is ignored by `.gitignore`.
- Only the project URL and publishable/legacy anon key belong in the Flutter app. Never put the `service_role` key in this file or in the app.

This is a connection scaffold, not a verified connection to your Supabase project: project-specific credentials were not supplied. Authentication, SQL schema/migrations, RLS, storage buckets/policies, marketplace queries, and payment/server integrations were not implemented. No existing UI widgets, styles, animations, or navigation were changed.

### Dashboard actions needed to activate the connection
1. Open your Supabase project and go to **Project Settings → API** (or **Connect**, depending on the dashboard version).
2. Copy the **Project URL** and the **publishable key** (`sb_publishable_...`). If the dashboard exposes only the legacy anon key, that client-safe key can be used instead. Do not copy the `service_role`/secret key.
3. In the project root, copy `supabase.env.example.json` to `supabase.env.json` and replace the two placeholder values. Do not paste credentials into chat or commit the local file.
4. Launch from the project root with `flutter run --dart-define-from-file=supabase.env.json`.
