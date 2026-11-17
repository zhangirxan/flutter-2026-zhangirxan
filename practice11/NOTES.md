# Practice 11 notes

## Level 1 — what the server actually sends

`GET https://jsonplaceholder.typicode.com/users` -> `200 OK`,
`Content-Type: application/json; charset=utf-8`, a list of **10** users.
`GET …/users/1` -> 200, one object.

### User (top level)

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| id | number | int | no |
| name | string | String | no |
| username | string | String | no |
| email | string | String | no |
| address | object | Address | no |
| phone | string | String | no |
| website | string | String? | yes, the only one I treat as optional |
| company | object | ({String name, String catchPhrase}) | no |

### address

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| street | string | String | no |
| suite | string | String | no |
| city | string | String | no |
| zipcode | string | String | no |
| geo | object | Geo | no |

### address.geo (nested twice)

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| lat | string ("-37.3159") | double, via double.parse | no |
| lng | string ("81.1496") | double, via double.parse | no |

### company

| field | JSON type | Dart type | nullable? |
|---|---|---|---|
| name | string | String | no |
| catchPhrase | string | String | no |
| bs | string | not stored | — |

Nothing is actually null in this data, all 10 users have every field. Phone has
different formats ("1-770-736-8031 x56442", "010-692-6593 x09125"), so I keep it
raw and added `phoneDigits`.

### Statuses

- `GET …/users/999` -> **404 Not Found**, body is `{}` (an empty object, still JSON).
- `POST …/users` with `{"name":"Zhangir","username":"zh"}` and
  `Content-Type: application/json` -> **201 Created**, body is what I sent plus
  `"id": 11`. If I send my own `"id": 0` the server replaces it with 11.
- `GET …/users?id=3` -> 200, a **list with one user**, not an object.

## Level 2 — breaking fromJson

User 1 pasted as a raw string in `checks.dart`, run with
`flutter run --dart-define=CHECKS=true`:

```
User(1, Leanne Graham, Gwenborough), phone digits: 1770736803156442
round trip equal: true
```

`lat` read as `json['lat'] as double`:

```
type 'String' is not a subtype of type 'double' in type cast
```

`"id": "1"` in the JSON:

```
type 'String' is not a subtype of type 'int' in type cast
```

Both name the type that was wrong, so it's easy to find the field.

## Level 3 — repository

From main() before runApp:

```
10 users: Leanne Graham, Ervin Howell, Clementine Bauch, Patricia Lebsack, Chelsey Dietrich, Mrs. Dennis Schulist, Kurtis Weissnat, Nicholas Runolfsdottir V, Glenna Reichert, Clementina DuBuque
not found
created with id 11
```

Forgot 404 in `_check` (and my extra `>= 400` line too) and called getById(999):

```
BadResponseException: users/999: type 'Null' is not a subtype of type 'int' in type cast
```

So the {} decoded fine and fromJson blew up on `id`. It's still my exception,
but it says "bad JSON" when the real reason is "no such user". Put 404 back.

`grep -rn "package:http" lib/`:

```
lib/main.dart:2
lib/core/api/api_client.dart:7
```

main.dart is there only because it's the place that says `http.Client()` and
passes it in. My repository doesn't import http at all: ApiClient gives it
`get(uri)` / `post(uri, body)` that return decoded JSON, so the repository only
builds Uri.https and calls fromJson.

## Level 4 — the chain

Removed the `BadResponseException()` arm from the switch:

```
error - The type 'ApiException?' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'BadResponseException()'
```

Doesn't compile, put it back.

Host typo `jsonplaceholder.typicode.co`: host lookup fails ->
SocketException -> NoConnectionException in **360 ms**.

## Level 5 — two kinds of no network

| case | how | Offline view after |
|---|---|---|
| airplane mode | emulator, airplane mode on, Retry | **81 ms**, again 53 ms |
| network that leads nowhere | emulator started with a DNS server that never answers (10.255.255.1), so the requests go out and nothing comes back | **10 136 ms**, 10 021 ms, 10 005 ms |

Times are from a Stopwatch around `load()` that I added for the measurement and
removed after. I couldn't do the hotspot without internet on the emulator, so I
made the "dead" network by giving it a DNS server that doesn't exist. The idea
is the same: packets leave and never come back, so only the 10 s timeout ends it.

DevTools -> Network during the dead network test: the /users row has no status
and stays Pending (screenshot_timeout.png, taken right after the app had
already shown Offline at ~10 s). The timeout only stops *my* waiting. The
request itself kept going and failed at 12.5 s with Error when the DNS lookup
finally gave up.

With the network back, GET /users is 200, about 2.9 s, response body is a list
of 10 maps (screenshot_200.png).

New user form: double tap on Save -> DevTools shows **one** POST /users,
**201**, 708 ms. The user with id 11 shows up at the top of the list.
