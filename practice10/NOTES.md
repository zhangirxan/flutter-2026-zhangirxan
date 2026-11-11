# Practice 10 notes

## Level 1 — order of prints

Code in main() before runApp:

```
print('A');
Future.delayed(2s, () => print('B'));
print('C');
api.fetchStudents().then((l) => print('${l.length} students'));
```

What I expected: A, C, then the app starts, and after 2 seconds B and "6 students".
fetchStudents prints its debugPrint right away, because the code before the first
await runs immediately.

What actually came out:

```
A
C
fetchStudents #1
B
6 students
```

So nothing waited for the timer, main() just went to the end. B and the list
came later as events.

Calling fetchStudents() three times in a row without await: the third one fails and
the console says

```
Unhandled Exception: Instance of 'NoConnectionException'
```

and the app keeps going like nothing happened. Nobody was awaiting it, so nobody
caught it.

## Level 2 — without mounted

Removed both `if (!mounted) return;` from _load, opened the screen and pressed
Back before the 2 seconds ended:

```
setState() called after dispose(): _StudentsScreenState#dffea(lifecycle state: defunct, not mounted)
```

With the guards back: pressed Back the same way, console is clean.

## Level 4 — countdown

Version B (listen + cancel in dispose), Back at 7: console stops, no more ticks,
no errors.

Version B with `_sub.cancel()` commented out, Back at 7:

```
setState() called after dispose(): _CountdownBState#e9623(lifecycle state: defunct, not mounted)
```

and it repeats every second, because the stream keeps going with nobody on screen.
That's the leak.

Version A (StreamBuilder, no cancel anywhere in my code), Back at 7: one more
`tick 6` showed up and then nothing, no error. StreamBuilder cancels the
subscription itself when it's removed.

## Level 5 — Save without await

The "AI version": `onPressed: () { _api.save(n); Navigator.pop(context); }`.
The screen closes right away like it worked, and on the second save the console
says

```
Unhandled Exception: Bad state: server rejected 6
```

The user saw a success, but the server said no.

Fixed version: await inside try / on StateError, mounted after the await, pop only
when it worked, SnackBar with the message when it didn't. The button is disabled
with a spinner while saving, so two fast taps send one request.
