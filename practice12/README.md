# Practice 12 — Survive a Restart

Продолжение практики 11 (список пользователей с jsonplaceholder). Что добавилось:
- тёмная тема и фильтр по городу в shared_preferences, читаются в `main()` до `runApp`;
- фейковый вход, токен в flutter_secure_storage, `ApiClient` сам добавляет `Authorization: Bearer …`;
- последний удачный список сохраняется в `Documents/users.json`, без сети показывается он с плашкой «Saved data»;
- аватар с камеры или из галереи, вся цепочка разрешений, включая «запретить навсегда» → свой диалог → `openAppSettings()`;
- ссылки mailto:, tel:, https: через url_launcher.

Замеры и ответы на вопросы — в `NOTES.md`.

## Запуск
Android Studio
1. File -> Open -> папка `practice12`.
2. Выбрать телефон или эмулятор.
3. Нажать Run. Вход: любой email и пароль от 8 символов.

## Структура
```
lib/
  main.dart                    чтение настроек и токена до runApp, MultiProvider
  core/api/                    ApiClient (+ заголовок с токеном), исключения
  core/storage/secure_store.dart
  core/settings/settings_model.dart
  core/widgets/                загрузка, Offline, ошибки
  features/auth/               AuthModel, экран входа
  features/users/              модель, репозиторий, кэш, экраны
  features/settings/           экран настроек
  features/profile/            фото профиля
```
