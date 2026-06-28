# سُفرة (Sufra) — Family Food Scanner, built for Arabic users

**Sufra** (سُفرة) is the Arabic word for the spread/table a family gathers
around to eat — chosen instead of a generic "scanner" name to feel warm and
local. This is an **original app**: own name, own logo, own icon set, own
color palette, own sound effects, own copy. It's inspired by the general
category (scan food → see nutrition & allergens for your family), not a copy
of any specific commercial app's branding, code, or art.

## Get a real, installable APK on your phone — no install needed on your end

I can't compile an APK from inside this chat (no internet/Android SDK in my
sandbox). The easiest fix: let GitHub's free build servers do it for you.
This takes about 10 minutes, once, and needs nothing installed on your
computer or phone except a browser.

1. **Create a free GitHub account** at github.com if you don't have one.
2. **Create a new repository** (top-right "+" → "New repository"), any name,
   e.g. `sufra-app`. Keep it private or public, either is fine.
3. **Upload this project**: on the new repo's page, click "uploading an
   existing file", then drag in the *entire unzipped* `sufra_app` folder
   contents (or use `git push` if you're comfortable with git — see below).
4. Go to the **"Actions" tab** of your repo. You'll see a workflow called
   "Build Sufra Android APK" — it usually starts automatically after upload.
   If not, click it, then "Run workflow".
5. Wait ~5 minutes for it to finish (green check).
6. Click into the finished run, scroll to **"Artifacts"**, download
   **`sufra-release-apk`**. It's a zip containing `app-release.apk`.
7. **Get that .apk onto your phone** — email it to yourself, upload to Google
   Drive and open on your phone, or use a USB cable.
8. **Tap the .apk file on your phone to install.** Android will ask you to
   allow installing from this source once — accept, then install.
9. Open **سُفرة** — done.

<details>
<summary>Prefer using git on the command line instead of the upload button?</summary>

```
git init
git add .
git commit -m "Sufra v1"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/sufra-app.git
git push -u origin main
```
The Actions workflow runs automatically on push.
</details>

## What's included

- **Full Flutter source code** (`lib/`) — one codebase for Android now, iOS
  later with no rewrite.
- **`.github/workflows/build_apk.yml`** — the cloud build pipeline above.
- **`tool/patch_manifest.py`** — adds the camera/internet permissions and
  sets the app's display name to "سُفرة" automatically during that build.
- **Arabic-first UI**, right-to-left layout, Cairo Arabic typeface (via
  `google_fonts`, cached on first run).
- **Real barcode scanning** (device camera, `mobile_scanner`).
- **Real product data** from Open Food Facts (world.openfoodfacts.org) —
  free, open, global food database with Arabic name/ingredient fields for
  many products. No API key, no cost.
- **Per-family-member allergy profiles** with a personalized "Sufra Score" +
  plain-Arabic reasons when something's risky for a specific person.
- **Local-only storage** — nothing leaves the phone, no backend, no account.
- **Logo & icon set** in `assets/icon/`:
  - `app_icon.png` — master 1024x1024 source icon
  - `app_icon_foreground.png` — transparent layer for Android's adaptive icon
  - `play_store_icon_512.png` — Play Store listing icon
  - `feature_graphic_1024x500.png` — Play Store feature banner
  - `logo_mark_transparent.png` — standalone logo mark for docs/marketing
- **Three original synthesized sound effects** in `assets/sounds/`.

## Building locally instead (if you do want Flutter on your computer)

1. Install Flutter: docs.flutter.dev/get-started/install
2. Inside the project folder:
   ```
   flutter create --org com.sufra --project-name sufra --platforms android .
   python3 tool/patch_manifest.py
   flutter pub get
   dart run flutter_launcher_icons
   flutter build apk --release
   ```
3. The APK lands at `build/app/outputs/flutter-apk/app-release.apk` — copy
   that to your phone and tap to install, same as step 7-8 above.
4. Or skip straight to `flutter run` with your phone plugged in via USB
   (enable Developer Options -> USB debugging on the phone first).

## Publishing to the Play Store for real (when you're ready)

The steps above get you a sideloaded APK on *your* phone. To list it on the
Play Store for everyone:

1. Create a Google Play Developer account ($25 one-time) at
   play.google.com/console
2. Set up app signing (one-time, Flutter's docs walk through it).
3. Build the **app bundle** instead of the APK: `flutter build appbundle --release`
   (the GitHub Actions workflow can be extended to do this too — ask and I'll add it).
4. Create the store listing — I can draft the Arabic description, and you
   already have the feature graphic and icon above. You'll also need a
   privacy policy URL (I can draft the text; you'll need to host it
   somewhere, e.g. a free GitHub Pages page).

## Project structure

```
sufra_app/
  .github/workflows/build_apk.yml   # cloud APK build, no local install needed
  tool/patch_manifest.py            # auto-adds permissions + Arabic app name
  pubspec.yaml
  assets/
    icon/      # logo, app icon, adaptive icon layers, store graphics
    sounds/    # original scan/success/alert tones
  lib/
    main.dart, app.dart             # entry point, RTL + Arabic locale setup
    theme/                          # colors.dart, app_theme.dart
    models/                         # FamilyMember, ScannedProduct
    services/                       # Open Food Facts API, scoring, storage, sound
    screens/                        # splash, onboarding, home, scan, result,
                                       history, family management
```
