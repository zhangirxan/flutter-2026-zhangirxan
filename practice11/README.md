# Practice 11 — A Real Server

Список пользователей с jsonplaceholder.typicode.com: модель с fromJson/toJson, ApiClient с таймаутом 10 с и своими исключениями, репозиторий, ChangeNotifier и экран со switch по sealed-ошибке. Есть pull-to-refresh, экран деталей и форма «New user» (POST). Замеры и ошибки записаны в `NOTES.md`.

## Запуск
Android Studio
1. File -> Open -> папка `practice11`.
2. Выбрать телефон или эмулятор (нужен интернет).
3. Нажать Run.

Проверки уровней 2–3 перед запуском приложения:
```
flutter run --dart-define=CHECKS=true
```

## Структура
```
lib/
  main.dart                 http.Client -> ApiClient -> UserRepository -> UsersModel
  checks.dart               проверки уровней 2-3
  core/api/                 api_exception.dart, api_client.dart
  core/widgets/             загрузка, Offline, ошибки
  features/users/           user.dart, user_repository.dart, users_model.dart, экраны
```
