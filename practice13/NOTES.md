# Practice 13 notes

Started from a copy of Practice 12 (it already had a few tests from last week,
7 of them, all green before the first move).

## Level 1 — feature-first, one move per commit

```
2b27293 practice13: start from practice 12
7379d60 add tool/check_layers.sh
75ead17 ApiClient creates its own http.Client, main.dart no longer imports http
c228ed9 remove checks.dart, the tests will do its job
7356b8c move settings_model to features/settings
1899a06 move App to app.dart, main.dart only wires things
067a5b3 move WrongPasswordException to its own file
01887e4 split status_views into one file per widget
7fe644a move UserList and UserTile to features/users/widgets
36b1cf3 move the stale data strip to widgets/offline_banner.dart
```

Every commit went through the same check: `dart format`, `flutter analyze`,
`flutter test`, `tool/check_layers.sh`, and only then `git commit`.

The first run of check_layers.sh printed `lib/main.dart`: main imported http
just to say `http.Client()`. Now ApiClient makes its own client
(`client ?? http.Client()`) and tests still pass a MockClient through the
same constructor parameter.

Two exceptions to "one class per file", both on purpose:
- `api_exception.dart` — a sealed class and its subclasses must be in one library,
  that's how Dart knows the list is complete.
- `user.dart` — User, Address, Geo, like the tree in the task.

Broken on purpose: `import 'package:http/http.dart' as http;` in users_screen.dart.
It compiles, the app would run, and the script printed:

```
lib/features/users/users_screen.dart
```

The compiler doesn't care about layers, the script does. Removed.

## Level 2 — interfaces and fakes

`abstract interface class UserRepository` with `getAll`, `getById`, `create`;
`HttpUserRepository` (ApiClient + UsersCache) and `FakeUserRepository`
(two users, `fail`, `delay`). The fake is in `lib/features/users/` so main can use
it for a demo, `test/fakes/fake_user_repository.dart` just re-exports it.

`grep -rn "HttpUserRepository(" lib/`:

```
lib/main.dart:28:  final UserRepository repo = HttpUserRepository(api, const UsersCache());
lib/features/users/user_repository.dart:16:  HttpUserRepository(this._api, this._cache);
```

One call, in main.dart. The second line is the constructor declaration itself.

Demo mode: swapped the comment in main.dart (and added the import), analyze only
complained that `api` and `UsersCache` are now unused, which is the point:
nothing touches the network.

Why the old way can't be tested: if UsersModel did
`final _repo = UserRepository(ApiClient(http.Client()))` inside itself, the
first line I can't write in "NoConnection sets error" is the arrange step,
because there is no way to hand it a repository that fails — it always talks to
the real server.

## Level 3 — tests

```
test/features/users/user_test.dart             fromJson ok, id as string throws, lat as number throws, round trip
test/features/users/users_model_test.dart      load -> items, load -> NoConnection sets error
test/features/users/user_repository_test.dart  404, 500, SocketException, lat as number -> BadResponse, token header, cache x2
test/features/users/users_screen_test.dart     offline view + Retry, loaded list
```

15 tests, about 2 seconds, nothing touches the network or the disk (MockClient,
MemorySecureStore, MemoryUsersCache, in-memory prefs).

Broken on purpose: `catch (e) {}` instead of `on ApiException catch (e) { error = e; }`:

```
00:00 +1 -1: UsersModel.load NoConnection sets error [E]
  Expected: <Instance of 'NoConnectionException'>
    Actual: <null>
     Which: is not an instance of 'NoConnectionException'
  test\features\users\users_model_test.dart 24:7      main.<fn>.<fn>
```

Name of the test, Expected, Actual, the line of the expect. Restored, green.

## Level 4 — widgets

Extracted from users_screen.dart into `features/users/widgets/`: `UsersHeader`
(the AppBar), `CityFilterBar` (new, shows the chosen city with an x),
`EmptyUsersView` (new, when the filter leaves nothing), `UsersErrorView` (the
switch on the sealed error). Plus earlier `UserList`, `UserTile`, `OfflineBanner`.

Why a widget and not a `_buildHeader()` method: a widget can be `const` so Flutter
skips rebuilding it, it has its own BuildContext and rebuild scope, it shows up by
name in the widget tree in DevTools, and it can be pumped in a test on its own.

Longest build() now: user_detail_screen 57 lines, users_screen 27.

I didn't run "Track widget rebuilds" in DevTools this time, everything here was
checked through tests.

Broken on purpose: Retry -> "Try again":

```
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Retry": []>
   Which: means none were found but one was expected
```

(First version of the test went straight to `tap` and failed with a less clear
"no element" error, so I added `expect(find.text('Retry'), findsOneWidget)` before it.)

## Level 5 — the trace

Planted: in FakeUserRepository, Ervin Howell (id 2) got `"lat": -43.9509`, a
number instead of a string. Ran `UsersModel(FakeUserRepository()).load()`:

```
type 'double' is not a subtype of type 'String' in type cast        <- the message
#0      new Geo.fromJson (package:practice13/features/users/user.dart:9:35)   <- my first frame, line 9, column 35
#1      new Address.fromJson (package:practice13/features/users/user.dart:36:14)
#2      new User.fromJson (package:practice13/features/users/user.dart:80:22)
#3      FakeUserRepository.getAll (package:practice13/features/users/fake_user_repository.dart:55:49)
<asynchronous suspension>
#4      UsersModel.load (package:practice13/features/users/users_model.dart:22:17)   <- the path ends in the model
<asynchronous suspension>
#5      main.<anonymous closure> (.../probe_test.dart:9:7)
<asynchronous suspension>
...
```

- the message: a double came where the code said `as String`;
- the first frame: user.dart 9:35 is `json['lat'] as String` in Geo.fromJson;
- the path: Geo <- Address <- User.fromJson <- the repository <- UsersModel.load,
  `<asynchronous suspension>` marks each await between them;
- the data: field `address.geo.lat` of user 2.

UsersModel only catches ApiException, so a TypeError went straight through it:
in the app this is a crash, not an error screen.

#0 is the right place for the exception (the cast is the claim that broke) and
the wrong place for the fix: the model is correct, the server broke the contract,
so the repository is where it gets translated. HttpUserRepository already wraps
fromJson in `_parse`, TypeError -> `BadResponseException('users: ...')`, and the
screen shows the generic error.

Tests: `Geo.fromJson` with a number throws TypeError (user_test), and the same JSON
through MockClient makes `getAll` throw BadResponseException (user_repository_test).

No `print` in lib/, `avoid_print` is on in analysis_options.yaml.
