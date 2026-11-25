# Practice 13 — Where Things Go

То же приложение пользователей из практик 11–12, на экране ничего нового. Изменилось устройство кода:
- feature-first: `lib/core/` и `lib/features/<name>/`, `test/` повторяет `lib/`, один класс на файл;
- `UserRepository` — интерфейс, есть `HttpUserRepository` и `FakeUserRepository`, всё собирается только в `main.dart`;
- 15 тестов: fromJson, UsersModel на фейке, маппинг статусов через MockClient, виджет-тест экрана без сети;
- `tool/check_layers.sh` проверяет, что http и material не попали не в тот слой.

Ход рефакторинга виден в `git log`, замеры и разобранный стектрейс — в `NOTES.md`.

## Запуск
Android Studio → File → Open → `practice13` → Run. Тесты: `flutter test`.

Демо без сети: в `main.dart` закомментировать строку с `HttpUserRepository` и раскомментировать `FakeUserRepository` (плюс импорт `features/users/fake_user_repository.dart`).

## Quality checklist

```
$ flutter analyze
Analyzing practice13...
No issues found! (ran in 5.2s)

$ dart format .
Formatted 40 files (0 changed) in 0.11 seconds.

$ flutter test
00:01 +15: All tests passed!

$ bash tool/check_layers.sh
(prints nothing)
```
