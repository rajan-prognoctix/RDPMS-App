# RDPMS App — project instructions

Flutter **mobile app (Android + iOS only)** for the **RDPMS Application** — the Remote Diagnostic and Predictive Maintenance System for Indian Railways signalling. It follows RDSO/SPN/257/2025 v2.0.

## Platform scope
- **Target platforms: Android and iOS only.** Web, Windows, macOS and Linux are out of scope for this project.
- Follow **Annex G (mobile UI)**. Use Annex E (desktop/web UI) only as a reference for fields and behaviour, not for layout.
- Don't add web-only or desktop-only packages, code or `kIsWeb` branches. Choose plugins that support Android and iOS.
- Test and build only for Android and iOS (`flutter run -d <android/ios device>`, `flutter build apk` / `flutter build ios`).

## UI design
All app UI must follow the **RDPMS UI Screens** design canvas: https://claude.ai/artifact/X56dT57ouhDqQdnN5Y8fhY#artboard-3ebcaafec561
- Before building or changing a screen, open its mobile design (M01–M22, plus the shared `MobileTabBar`) and match the layout, colours, typography and components. The web designs (W01–W24) are a reference for fields only. Admin: M20 (mobile), W21–W22 (web, fields only).
- Screens with no design on the canvas (Forgot User ID, Forgot password) follow the style of M01/M02.
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
- **Start-up:** Splash waits `AppConstants.splashMinDuration`, then opens Dashboard if an access token is saved (`LocalStorage.hasToken`), otherwise Login. `App` also sends `CurrentUserRequested` to `AuthBloc`, which restores the user saved at the last sign-in so their role is known after a restart.
- **Sign-in:** Login (user id + password) → on success the user (`UserData`, no password) is saved under `AppConstants.userKey` → OTP page → on a correct OTP the access token is saved to SharedPreferences via `LocalStorage` (`lib/core/storage/token_storage.dart`, same key `ApiClient` reads), the profile is reloaded → Dashboard. Logout clears the token and the saved user. Auto-login is only allowed after OTP (§11.7).
- **Recovery (no spec clause — app design):** Login has "Forgot User ID?" (registered mobile → OTP → account details → Sign in) and "Forgot password?" (User ID → OTP → new password).
- **Bottom bar:** shown only on the five tab pages (`HomeShell`, `StatefulShellRoute`). Android Back on any tab other than Dashboard goes to Dashboard; Back on Dashboard shows the "Exit app?" dialog.
- **Details and other screens open full screen, without the bottom bar:** register them with `parentNavigatorKey: _rootKey` and open them with `context.push(...)`, so Back returns to the screen they were opened from. Examples: `/alert-detail/:id` and the side-menu pages. Don't nest detail routes inside a tab branch.
- Use `context.go(...)` only to switch to a tab or to replace the stack (Splash → Login/Dashboard, Login → OTP, Logout → Login).
- Dashboard shortcuts switch tabs with `context.go(...)`: "Latest pending alerts → View all" → Alerts tab (index 1); RDPMS health Sensors / IoT cards → Health tab (index 3). Signalling asset cards are not tappable. A pending alert opens Alert detail full screen.

## Always check the requirements first
Before adding or changing any feature, read the relevant part of **`docs/RDPMS_REQUIREMENTS.md`**. It covers every requirement in the signed spec (`Approved RDPMS SPN 31_12_25 signed.pdf`). Start with section 0, which lists what this app must do.
- The signed PDF is the source of truth. If `RDPMS_REQUIREMENTS.md` and the PDF disagree, follow the PDF and fix the doc.
- Use the standard nomenclature codes exactly as written in the spec: `asset_type_code`, `asset_number_code`, `cause_code`, `alert_type_code` ("Failure"/"Predictive"), `alert_feedback_code` (T/PT/F/M), `alert_status_code` (pending/cleared), zone/division/station codes.
  - Copy codes character for character: parameter codes have no underscores (`VIPS 110 DC`, `VPT NWKR`, `ISIG DG`, `ELDCH1`), hyphens are plain ASCII `-`, and spec misspellings stay (`UNKOWN`, `ENERIZATION`, `IPS 110 AC Sig1 VOLT FAIL`).
  - Treat `cause_code` as a string, not a closed enum: vendors may add new cause codes with Zonal Railway approval. Show `cause_detail` (readable text) where the alert gives it.
- Every duration, interval and % in the spec (feedback windows, repeat/escalation times, maintenance-mode reminders, 15-day average, ±2 %, 20 ms…) is a default the Zonal Railway can change (Annex D §17, "No time limit" allowed). Don't hard-code them in logic.
- Screens, filters and table columns follow Annex E (desktop) and Annex G (mobile).
- Login is OTP + device binding (§11.7). One account = one mobile no / email id; one mobile and one desktop per user, Zonal Railway may allow more (§11.8).
- If a change conflicts with the spec, say so before implementing it.

## Roles and permissions (§11.6, Annex E §1, Annex D §5–§7)
- `UserRole` and its permission checks live in `lib/core/auth/user_role.dart`. The role comes from the login response (`User.role`, parsed with `UserRole.fromCode`); unknown or signed-out = `guest` (least access).
- In widgets, read the role with `context.watchRole()` / the user with `context.watchUser()` (`features/auth/presentation/bloc/auth_context.dart`). Don't read `MockData.userRole` for access decisions.
- Rules — check the permission getter, not the role name:

  | Permission | Admin | HQ | Division | Station | Guest |
  |---|---|---|---|---|---|
  | Live monitoring (Dashboard, Alert Live, Telemetry/Health/Equipment Live) | ✓ | ✓ | ✓ | ✓ | ✓ |
  | `canViewReports` — History/Summary tabs, Asset, Performance | ✓ | ✓ | ✓ | ✓ | – |
  | `canControl` — Ack, T/PT/F/M feedback, remarks, maintenance mode | – | – | – | ✓ | – |
  | `canOpenAdmin` — Admin page (create / edit / disable users, approve devices) | ✓ | ✓ | ✓ | – | – |
  | `canEnterActualFailures` — Performance → Actual Failure entry | ✓ | ✓ | ✓ | ✓ | – |

- **Admin page** has three tabs — keep all three: **Users** (M20), **Configuration** (all 23 Annex D §17 parameters; "No time limit" allowed; editable by every user with Admin access — Admin, HQ and Division (`AdminScope.canEditConfig` = `UserRole.canOpenAdmin`); every change is written to the audit log) and **Audit log** (Annex D §19; filter Blocked / Warned / Logged).
- **Admin page scope** (`AdminScope`): Admin and HQ see their zone and can create Admin, HQ, Division, Station and Guest users; Division sees its division and can create Division, Station and Guest users. Edit / Disable only users of a role the admin can create, never their own account. Create user fields depend on the role (Admin/HQ: zone · Division: + division · Station: + station · Guest: + division area, organisation, valid-until). Self sign-up never offers Admin (`UserRole.selfSignUp`).

- Hide what a role can't use (Annex E §1: "UI filtered to show only relevant icons"). When only one tab of a page is left, drop the tab bar. Pages a role must not open also guard themselves (see `AdminPage`).
- Spec gaps, decided for this app: the spec mentions "Admin" (Annex D §17, §19, Annex E §13) but defines only HQ / Division / Station / Guest, so the app adds an **Admin** level (zone, no control functions); HQ and Division users can also open Admin because they "assign users" (§11.6). "Control functions" = feedback, remarks, maintenance mode. Not built yet: JE/SSE changing a maintainer's feedback (designation-based).
- **Jurisdiction** (`lib/core/auth/jurisdiction.dart`, Annex G note 2): `App` provides the signed-in user's `Jurisdiction` (Admin/HQ: zone · Division: zone + division · Station: zone + division + station · Guest: zone + division) through `JurisdictionScope`; read it with `Jurisdiction.of(context)`. `FilterBar` shows fixed levels locked, offers only places inside the jurisdiction, and reports the jurisdiction filter on first build. Any other Zone / Division / Station picker or list must filter with `jurisdiction.allowsStation(sc)` — never list `MockData.zones` / `MockData.assets` stations unfiltered.
- **Mock users** (`LoginResponseModel.mockUsers`, password `Test@123`, OTP `123456`): `ADMIN001` Admin · `HQ001` Head Quarter · `DIV001` Division · `EMP001` Station · `GUEST001` Guest. Wrong id/password → "Invalid User ID or password".

## API errors
- `ApiClient` turns every Dio error into a `NetworkException` / `ServerException` with a real cause (wrong host, refused, timeout, 4xx/5xx). Repositories map them to `Failure`s and also catch parse errors, so the UI never hangs.
- Show error text through `ErrorMessages.pick(detail, generic)` (`lib/core/error/error_messages.dart`): technical detail in debug builds, a generic message in release. Messages the server sends on purpose (e.g. "Invalid password") are shown in every build.

## Architecture
Clean Architecture + BLoC, organised by feature:
- `lib/core/` — auth (`UserRole`), constants, error (exceptions/failures/`ErrorMessages`), network (Dio `ApiClient`, endpoints), routes (go_router), storage, theme, usecase base, utils, shared widgets, mock data (`lib/core/mock/` — UI-only data until each API is connected).
- `lib/features/<feature>/{data,domain,presentation}` — data: datasources, models, repository impl; domain: entities, abstract repositories, use cases; presentation: bloc, pages, widgets.
- Dependency rule: presentation → domain ← data. BLoCs call only use cases. Repositories return `Either<Failure, T>` (fpdart).
- Register every new class in `lib/injection_container.dart` (get_it).

## Tests
- **Don't write, update or run tests.** Focus only on app code in `lib/`. Don't add or change files under `test/`, and don't run `flutter test`, unless the user asks for it.

## Commands
- `flutter analyze` — must report no issues in `lib/`
