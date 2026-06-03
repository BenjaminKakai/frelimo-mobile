# FRELIMO Mobile App

Official mobile app for FRELIMO (Frente de Libertação de Moçambique) — Play
Store and App Store target after the Political Commission demo. Single
codebase, single store listing, role-aware after login.

## Architecture decision: ONE app, role-aware

We deliberately ship **one** mobile app. After `/auth/login` we call
`/profile/me` and branch on flags:

- `profile.isAdmin === true`  → admin / politician shell (Dashboard, Membros,
  Verificação, Notícias, Mais — bottom-nav)
- `profile.isMember === true` → verified member home (digital card, dues,
  vote, news)
- else                        → citizen home (apply for membership, news,
  surveys, report)

The router redirect at `lib/config/router.dart` enforces this — see the
`redirect:` callback for the single source of truth on role routing. The
web app does the same so the two surfaces stay aligned.

## Brand

| Token            | Hex      | Usage                                |
|------------------|----------|--------------------------------------|
| Primary red      | `#CE1126`| CTAs, headings, brand stamp          |
| Brand gold       | `#FCD116`| Accent stripes, badges, highlights   |
| Brand green      | `#009E49`| Accent, success states               |
| Dark surface     | `#0F1A14`| Card gradient endpoint               |
| Flag stripe      | green / gold / red / black | login + card + section headers |

All brand tokens live in `lib/config/theme.dart` under `AppColors`. Surface
backgrounds (scaffold / appBar / card) go through neutral `lightBg / darkBg`
tokens — never raw brand colours — so dark mode stays readable.

## Stack

- Flutter 3.9+ / Dart
- Riverpod (`flutter_riverpod ^2.6`)
- go_router ^14
- dio ^5 with `X-Tenant: frelimo` default header + 401-refresh interceptor
- flutter_secure_storage ^9 (JWT lives in Keychain / Android Keystore — never
  shared_preferences / localStorage)
- google_fonts (Inter)
- qr_flutter — digital card QR
- mobile_scanner — admin QR verifier
- share_plus, url_launcher, permission_handler
- firebase_core + firebase_messaging — guarded by a `_firebaseConfigPresent()`
  check so the app boots cleanly without a `GoogleService-Info.plist`

## Run

```bash
# Android
flutter run -d android

# iOS (Xcode signing already set on Apple Developer team)
flutter run -d ios

# Override API base URL (e.g. demo at the office)
flutter run --dart-define=FRELIMO_API_URL=http://10.0.2.2:3000/api/v1
```

Default API base: `https://api-frelimo.wasaahost.com/api/v1`. Override with
`--dart-define=FRELIMO_API_URL=...`. The tenant header is also overridable
via `--dart-define=FRELIMO_TENANT=...` if a fork ever needs it.

## Folder layout

```
lib/
  config/        env, theme, router
  core/
    network/     dio + envelope parser
    storage/     secure storage wrapper
    services/    push notifications
  shared/
    i18n.dart    pt-MZ default + en toggle
    models/      UserModel
    widgets/     FlagStripe
  features/
    auth/        splash, login, forgot password
    profile/     read+edit profile
    member/      home, digital card, dues
    admin/       shell (5 tabs) + QR scanner
    voting/      (em breve)
    news/        (em breve)
    surveys/     (em breve)
    ussd_offline/(em breve)
```

## Offline guarantees

- `/profile/me` is mirrored into secure storage so the digital card renders
  with zero network.
- The QR is generated locally from the cached member number, so branch staff
  can verify even when the device is offline. The URL the QR encodes still
  needs network to land on the verify page.

## Localisation

pt-MZ is the default; the EN/PT toggle (top-right of every shell) flips a
saved preference in secure storage. Strings live in `lib/shared/i18n.dart`.

## Test mode (demo build)

- APK: `flutter build apk --release --dart-define=FRELIMO_API_URL=...`
- iOS: `flutter build ipa --release --dart-define=FRELIMO_API_URL=...`

The Apple Developer team is already configured. Bundle id is `com.frelimo.app`.
