# Practice 12 notes

## Level 1 — six packages, two minutes each

Order: publisher, last release, platforms, pub points, issues vs commits,
dependencies, licence. Checked on pub.dev and GitHub on 19 Nov 2026.

- **shared_preferences** 2.5.6 — verified publisher flutter.dev, released Oct 2026, all six platforms, 160/160 points, lives in the flutter/packages monorepo (303 open issues for the whole repo, last commit yesterday), depends only on its own platform packages, BSD-3-Clause.
- **flutter_secure_storage** 11.2.0 — verified publisher steenbakker.dev (one maintainer, not Google), released Sep 2026, all six platforms, 160/160 points, 24 open issues and a commit yesterday, depends on its own platform packages plus meta, BSD-3-Clause.
- **path_provider** 2.1.6 — verified publisher flutter.dev, released Jun 2026, Android, iOS, Windows, Linux, macOS (no web, there is no file system there), 160/160 points, flutter/packages monorepo, only its own platform packages, BSD-3-Clause.
- **image_picker** 1.2.4 — verified publisher flutter.dev, released Oct 2026, all six platforms, 160/160 points, flutter/packages monorepo, only its own platform packages, Apache-2.0 + BSD-3-Clause.
- **permission_handler** 13.0.2 — verified publisher baseflow.com (a company), released Sep 2026, Android, iOS, Windows, web (no Linux/macOS), 160/160 points, 157 open issues and last commit 6 Nov 2026, depends on its own platform packages plus meta, MIT.
- **url_launcher** 6.3.3 — verified publisher flutter.dev, released Oct 2026, all six platforms, 160/160 points, flutter/packages monorepo, only its own platform packages, BSD-3-Clause.

### Carets and the lock

`flutter pub add` wrote `^2.5.6`, `^11.2.0`, `^2.1.6`, `^1.2.4`, `^13.0.2`, `^6.3.3`.
In pubspec.lock http is resolved to exactly **1.6.0**.

`^1.2.0` means `>=1.2.0 <2.0.0`. It accepts 1.2.0, 1.2.1, 1.6.0, 1.99.0. It refuses
1.1.x (too old) and 2.0.0, because a new major version is allowed to break the API.

pubspec.lock is committed because this is an app, not a library: everyone who
clones it (and CI) gets the same versions I tested with, not "whatever is newest
today".

### pub outdated

`cupertino_icons` is 1.0.9 and 2.0.0 exists. It was not upgraded because the
pubspec says `^1.0.8`, and 2.0.0 is a new major, outside the caret. A few
transitive ones (`meta`, `vector_math`, `shared_preferences_foundation`) are just
locked in pubspec.lock to older versions; `flutter pub upgrade` would move them.

### Breaking it: no caret

`http: 1.2.0` (no caret) -> `flutter pub get` **failed**:

```
Because ... permission_handler_html >=0.1.3 depends on web >=0.5.1 <2.0.0 and
http >=1.1.2 <1.2.1 depends on web >=0.3.0 <0.5.0, permission_handler ^13.0.2
is incompatible with http >=1.1.2 <1.2.1.
So, because practice12 depends on both http 1.2.0 and permission_handler ^13.0.2,
version solving failed.
```

So an exact old pin doesn't just freeze one package, it can make the whole tree
unsolvable. Pinned `http: 1.5.0` instead: the lock went to exactly 1.5.0 and
`pub outdated` showed

```
http   *1.5.0   *1.5.0   1.6.0   1.6.0
```

(Upgradable is stuck at 1.5.0, newer is not allowed.) Put `^1.6.0` back, lock is 1.6.0 again.

## Level 2 — settings

Dark on, city Gwenborough, killed the app (`am force-stop`, not Back), opened
again: dark from the first Flutter frame and only Leanne Graham in the list.

Broken on purpose: `dark: false` in main and `getBool` later in the model.
Printed the theme of every App.build:

```
TEMP frame dark=false t=1795084266542
TEMP frame dark=true  t=1795084267800
```

So one light frame and then dark **1.25 s later** (debug build). With the read
in main() before runApp the first frame is already dark. Put it back.
(The native Android splash before Flutter starts is still light, that's the
LaunchTheme in styles.xml, not Flutter.)

## Level 3 — token

Logged in, killed, reopened: still signed in. DevTools -> Network -> GET /users
-> Request Headers: `authorization: [Bearer tok_443188304]`
(screenshot_auth_header.png). Sign out -> login screen, and after a restart too.

**Where `prefs.setString('token', …)` would have put it.** On this emulator
SharedPreferencesAsync writes a plain DataStore file:
`/data/data/com.example.practice12/files/datastore/FlutterSharedPreferences.preferences_pb`.
I read it with a cable and `adb shell run-as` (debug build), the avatar path is
right there in plain text, a token would be too. (Old SharedPreferences = an XML
file in `shared_prefs/`; iOS = a plist in `Library/Preferences`.) Who can read it:
a device backup, a rooted / jailbroken phone, anyone with a cable and a debug build.

What flutter_secure_storage wrote instead (`shared_prefs/FlutterSecureStorage.xml`):
the value is ciphertext, the key that decrypts it is in the Android Keystore.

Platform surprises:
- **iOS**: Keychain items are not deleted with the app. Uninstall, install again —
  the old token can still be there, so the app may start "signed in" as last time.
- **Android**: if the user removes the lock screen, Keystore keys can be
  invalidated, the stored values can't be decrypted any more, read fails and the
  user has to sign in again.

## Level 4 — offline list

- Online once -> airplane mode -> kill -> open: ten users at once with the
  "Saved data · no connection" strip (screenshot_offline_banner.png).
- Retry in airplane mode: still the list, still the strip.
- Airplane off, Retry: strip gone.
- Uninstall, install, airplane mode, open: the Offline screen with Retry, not
  an empty list (`saved == null` -> rethrow).

Broken on purpose: `getTemporaryDirectory()`. The file was in `cache/users.json`.
Cleared the cache (`adb shell pm trim-caches 999G`, same thing as Storage ->
Clear cache), airplane mode, opened: Offline screen, the list is gone, no error.
The folder is called cache and it was treated like one. Back to Documents
(`app_flutter/users.json`).

## Level 5 — photo and No

Android emulator (API 37), clean app data:

1. Take photo -> system dialog -> Don't allow -> my SnackBar (`denied`).
2. Take photo -> system dialog again -> Don't allow -> Android now reports
   `permanentlyDenied`, so my dialog shows right after this second No.
3. Take photo -> no system dialog, my dialog at once (screenshot_permission_dialog.png).
   "Open settings" opened the system app settings page.

Reset and did it again with the same result. Note: `pm revoke` alone is not a
full reset, permission_handler keeps its own `android.permission.CAMERA.xml`;
clearing app data is.

**iOS**: the system asks only once. One No and the status is `permanentlyDenied`
straight away, after that only Settings can change it. Photos has a fourth state,
**limited** ("Selected Photos" — the user gave access to a few photos only).

Camera allowed -> took a photo -> copied to Documents as avatar.jpg, path in
prefs -> killed the app -> the avatar is still there. Cancel in the picker
returns null and nothing happens.

Links: email -> Gmail opened (`mailto:`), phone -> Dialer (`tel:` with
phoneDigits), website -> Chrome (`https://`).

Broken on purpose: `launchUrl(Uri.parse('kbtu.edu.kz'))`. On Android it did not
return false, it **threw**:

```
PlatformException(ACTIVITY_NOT_FOUND, No Activity found to handle intent { kbtu.edu.kz }, null, null)
```

So `_open` catches PlatformException and treats it the same as false:
"No app can open this". With `https://` in front the browser opens.

## Other

- permission_handler_android needs compileSdk 37, so `compileSdk = 37` in
  android/app/build.gradle.kts (Flutter's default was 36, the build failed).
- `grep -rn "package:http" lib/` is still two files: main.dart and api_client.dart.
