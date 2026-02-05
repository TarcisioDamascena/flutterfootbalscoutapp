# Football Scout App

Flutter app to browse football teams and matches and calculate match odds locally.

## Current project status

- Team and match data are fetched from API-Football.
- Odds are calculated in-app using local logic (`OddsService`) and cached in local database.
- **External odds API integration is intentionally not implemented yet** (future project).

## Run locally

```bash
flutter pub get
flutter run
```

## Android install troubleshooting

If `flutter run` fails with:

```text
INSTALL_FAILED_USER_RESTRICTED: Install canceled by user
```

this is a **device security/permission** issue (not Dart code). On many Xiaomi/MIUI devices you must additionally enable install permissions for ADB.

### Fix checklist (Xiaomi/MIUI)

1. Keep **Developer options** enabled.
2. Enable **USB debugging**.
3. Enable **USB debugging (Security settings)** (if available).
4. Enable **Install via USB** (if available).
5. When prompted on the phone during install, tap **Allow/Install**.
6. Remove old app build (if present):
   - `adb uninstall com.example.flutterfootbalscoutapp`
7. Retry:
   - `flutter clean`
   - `flutter pub get`
   - `flutter run`

If your phone has **MIUI optimization** settings, temporarily disabling it can also help during development.

## White screen on web troubleshooting

If Chrome shows only a white screen:

1. Run with logs:
   - `flutter run -d chrome -v`
2. Open browser DevTools Console and check runtime errors.
3. Confirm API key/header config is correct in:
   - `lib/core/constants/api_constants.dart`
4. If backend/API is unreachable, UI can appear empty due to missing data.

## Notes

- Android manifest includes internet permission at `android/app/src/main/AndroidManifest.xml`.
- If your API plan/rate limit blocks requests, the app may load with little/no data.
