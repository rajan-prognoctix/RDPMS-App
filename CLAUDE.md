# RDPMS App — project instructions

Flutter **mobile app (Android + iOS only)** for the **RDPMS Application** — the Remote Diagnostic and Predictive Maintenance System for Indian Railways signalling. It follows RDSO/SPN/257/2025 v2.0.

## Platform scope
- **Target platforms: Android and iOS only.** Web, Windows, macOS and Linux are out of scope for this project.
- Follow **Annex G (mobile UI)**. Use Annex E (desktop/web UI) only as a reference for fields and behaviour, not for layout.
- Don't add web-only or desktop-only packages, code or `kIsWeb` branches. Choose plugins that support Android and iOS.
- Test and build only for Android and iOS (`flutter run -d <android/ios device>`, `flutter build apk` / `flutter build ios`).

## UI design
All app UI must follow the **RDPMS UI Screens** design canvas: https://claude.ai/artifact/X56dT57ouhDqQdnN5Y8fhY#artboard-3ebcaafec561
- Before building or changing a screen, open its mobile design (M01–M22, plus the shared `MobileTabBar`) and match the layout, colours, typography and components. The web designs (W01–W24) are a reference for fields only.
- Theme: IBM Plex Sans for UI text, IBM Plex Mono for numbers and codes; navy app bar `#13294B`; primary `#1F5FBF`; screen background `#F3F5F8`; text `#1A2233`; white cards with border `#D9DEE6` and radius 12; status colours Normal `#1B7A43`, Predicted `#D98A1C`, Failed `#B3261E`; line icons, no emoji.
- Keep these values in `lib/core/theme/`. Don't hard-code colours in widgets.

### Spacing and form text (use on every new or changed screen)
- **Padding is 15 everywhere**: screen content and card insides use `AppSpacing.screen` / `AppSpacing.card` (`lib/core/theme/app_spacing.dart`), or `AppSpacing.screenPadding` / `AppSpacing.cardPadding`. Don't hard-code screen or card padding.
- **Form label and hint text is 14**: use `AppTextStyles` (`lib/core/theme/app_text_styles.dart`): `fieldLabel` for labels above a field, `inputLabel` / `fieldHint` inside a field. The theme's `InputDecorationTheme` already applies 14 to every field — don't override it per field.
- Use the shared widgets in `lib/core/widgets/`:
  - `ScreenPadding` — standard padding around a screen's content (`horizontalOnly` for left/right only).
  - `AppCard` — themed white card with the standard inner padding (optional `onTap`, `margin`).
  - `LabeledField` — label above a form field.
  - `GradientButton` — the primary action button (Sign in, Submit, Save, Verify, Activate…) with the blue gradient. Use it for every main action instead of `ElevatedButton` / `FilledButton` (options: `icon` after the label, `leadingIcon` before it, `loading`). Secondary actions (Cancel, Clear, date pickers, Logout) stay as `TextButton` / `OutlinedButton`.
- Small spacing (button, chip and badge padding, gaps between items, text-field content padding) isn't covered by these rules.
- To change a size, change it only in `AppSpacing` / `AppTextStyles`.

### App bars
- **Bottom-bar tab pages** (Dashboard, Alerts, Telemetry, Health, Equipment Room) use `RdpmsAppBar` (`lib/core/widgets/rdpms_app_bar.dart`). It shows the Menu button inside a tab and a Back button automatically when the same page is opened full screen.
- **Every other screen** (OTP, Register, Reset password, details, side-menu pages) uses the common themed `AppBar` (navy, white title from `AppTheme`) — don't style app bars per screen. Sign-in flow screens put a Back arrow in `leading` that goes to Login (`context.go(RouteNames.login)`) when there's nothing to pop.
- Screens without an `AppBar` but with a dark area under the status bar (Splash, Login) wrap the `Scaffold` in `AnnotatedRegion<SystemUiOverlayStyle>(value: SystemUiOverlayStyle.light)` so the status-bar icons stay white.

## Navigation (go_router, `lib/core/routes/`)
- **Start-up:** Splash waits `AppConstants.splashMinDuration`, then opens Dashboard if an access token is saved (`TokenStorage.hasToken`), otherwise Login.
- **Sign-in:** Login (user id + password) saves nothing → OTP page → on a correct OTP the access token is saved to SharedPreferences via `TokenStorage` (`lib/core/storage/token_storage.dart`, same key `ApiClient` reads) → Dashboard. Logout clears the token. Auto-login is only allowed after OTP (§11.7).
- **Bottom bar:** shown only on the five tab pages (`HomeShell`, `StatefulShellRoute`). Android Back on any tab other than Dashboard goes to Dashboard; Back on Dashboard shows the "Exit app?" dialog.
- **Details and other screens open full screen, without the bottom bar:** register them with `parentNavigatorKey: _rootKey` and open them with `context.push(...)`, so Back returns to the screen they were opened from. Examples: `/alert-detail/:id` and the side-menu pages. Don't nest detail routes inside a tab branch.
- Use `context.go(...)` only to switch to a tab or to replace the stack (Splash → Login/Dashboard, Login → OTP, Logout → Login).
- Dashboard shortcuts switch tabs with `context.go(...)`: "Latest pending alerts → View all" → Alerts tab (index 1); RDPMS health Sensors / IoT cards → Health tab (index 3). Signalling asset cards are not tappable. A pending alert opens Alert detail full screen.

## Always check the requirements first
Before adding or changing any feature, read the relevant part of **`docs/RDPMS_REQUIREMENTS.md`**. It covers every requirement in the signed spec (`Approved RDPMS SPN 31_12_25 signed.pdf`). Start with section 0, which lists what this app must do.
- Use the standard nomenclature codes exactly as written in the spec: `asset_type_code`, `asset_number_code`, `cause_code`, `alert_type_code` ("Failure"/"Predictive"), `alert_feedback_code` (T/PT/F/M), `alert_status_code` (pending/cleared), zone/division/station codes.
- Screens, filters and table columns follow Annex E (desktop) and Annex G (mobile).
- Roles and permissions follow §11.6. Login is OTP + device binding (§11.7), limited to one mobile and one desktop per user (§11.8).
- If a change conflicts with the spec, say so before implementing it.

## Architecture
Clean Architecture + BLoC, organised by feature:
- `lib/core/` — constants, error (exceptions/failures), network (Dio `ApiClient`, endpoints), routes (go_router), theme, usecase base, utils, shared widgets.
- `lib/features/<feature>/{data,domain,presentation}` — data: datasources, models, repository impl; domain: entities, abstract repositories, use cases; presentation: bloc, pages, widgets.
- Dependency rule: presentation → domain ← data. BLoCs call only use cases. Repositories return `Either<Failure, T>` (fpdart).
- Register every new class in `lib/injection_container.dart` (get_it).

## Tests
- **Don't write, update or run tests.** Focus only on app code in `lib/`. Don't add or change files under `test/`, and don't run `flutter test`, unless the user asks for it.

## Commands
- `flutter analyze` — must report no issues in `lib/`
