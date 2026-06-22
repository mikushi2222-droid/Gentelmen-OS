# 15. CI, сборка APK и раннеры

## 1. Диагноз текущей проблемы

Workflow `CI` имеет статус **active**, но каждый прогон падает за 3–4 секунды
**без единого шага**, с `runner_id: 0` и `runner_name: ""`, а логи отдаются `404`.

> Это означает, что **ни один раннер не взял задачу в работу**. Проблема не в
> коде и не в `ci.yml`, а в том, что GitHub не выделяет исполнителя.

Типичные причины (на стороне репозитория/аккаунта, правит только владелец):

1. **Исчерпаны минуты GitHub Actions** для приватного репозитория
   (или не привязан способ оплаты). Free-tier минуты закончились → задачи
   падают мгновенно.
2. **Hosted-раннеры недоступны** для аккаунта/организации (политика, спенд-лимит).
3. Репозиторий приватный и без квоты. Публичные репозитории получают
   стандартные раннеры бесплатно и без лимита.

## 2. Как починить (GitHub-hosted раннеры)

Выберите любой из вариантов:

### Вариант A — включить оплату/минуты
1. **Settings → Billing and plans → Actions** — проверьте остаток минут.
2. Поднимите spending limit или добавьте способ оплаты.
3. **Settings → Actions → General → Allow all actions and reusable workflows**.
4. Перезапустите прогон: вкладка **Actions → CI → Run workflow** (теперь доступно
   благодаря `workflow_dispatch`).

### Вариант B — сделать репозиторий публичным
Публичные репозитории используют стандартные раннеры **бесплатно и без лимита**.
**Settings → General → Danger Zone → Change visibility → Public**, затем
перезапустите workflow.

После любого из вариантов `ci.yml` соберёт `app-debug.apk` и положит его в
артефакты прогона (вкладка Actions → конкретный run → Artifacts).

## 3. Вариант C — self-hosted runner (раннер на своей машине)

Если hosted-раннеры недоступны, зарегистрируйте собственный. Нужна машина с
Linux/macOS/Windows, Flutter 3.44+ и Android SDK.

### Регистрация
1. **Settings → Actions → Runners → New self-hosted runner**, выберите ОС.
2. Выполните команды, которые покажет GitHub (пример для Linux):

```bash
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64.tar.gz -L \
  https://github.com/actions/runner/releases/latest/download/actions-runner-linux-x64.tar.gz
tar xzf actions-runner-linux-x64.tar.gz
./config.sh --url https://github.com/mikushi2222-droid/gentelmen-os \
            --token <TOKEN_ИЗ_НАСТРОЕК> --labels self-hosted,android
./run.sh   # держит раннер активным
```

3. Установите на этой машине Flutter + Android SDK:
```bash
# Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor --android-licenses   # принять лицензии
```

### Использование
В workflow укажите ваш раннер. Для отдельного self-hosted билда есть готовый
файл `.github/workflows/build-selfhosted.yml` (запускается вручную через
`workflow_dispatch`, `runs-on: [self-hosted]`).

## 4. Локальная сборка (всегда работает)

Не требует CI вообще:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --debug
# Артефакт: build/app/outputs/flutter-apk/app-debug.apk
```

Релизный (неподписанный) APK:
```bash
flutter build apk --release
```

## 5. Что уже сделано в репозитории для сборки

- `ci.yml`: analyze → test, **независимый** build-debug (не блокируется analyze),
  `workflow_dispatch` для ручного запуска, least-privilege `permissions`.
- Android-ресурсы (`res/`: темы, splash, адаптивная иконка) — без них
  `flutter build apk` падал на этапе aapt2.
- Версии пакетов под Flutter 3.44 (см. [13-packages-spec.md](13-packages-spec.md)).
- Gradle wrapper подтягивается `flutter build` автоматически.

## 6. Почему нельзя «настроить раннер из кода»

Раннер выделяет платформа GitHub по факту наличия квоты/способа оплаты или
наличия зарегистрированного self-hosted исполнителя. Это настройки уровня
репозитория/аккаунта — их нельзя включить пушем в `ci.yml`. Поэтому единственные
рабочие пути: исправить биллинг/видимость (разделы 2) или поднять self-hosted
раннер (раздел 3). Сам workflow к сборке готов.

## 7. Конфликт зависимостей: custom_lint / riverpod_lint (июнь 2026)

### Симптом

`flutter pub get` падал на этапе разрешения зависимостей с ошибкой:

```
Because riverpod_lint >=3.1.4-dev.1 depends on analyzer_plugin ^0.14.0
and custom_lint >=0.7.4 <0.8.0 depends on analyzer_plugin ^0.13.0,
riverpod_lint >=3.1.4-dev.1 is incompatible with custom_lint >=0.7.4 <0.8.0.
```

### Причина

`riverpod_lint >=3.1.4` требует `analyzer_plugin ^0.14.0`, а `custom_lint ^0.8.1`
требует `analyzer_plugin ^0.13.0` — диапазоны несовместимы. Pub не может
найти версию-решение.

### Исправление

Из `pubspec.yaml` (dev_dependencies) удалены:
```yaml
custom_lint: ^0.8.1      # удалено
riverpod_lint: ^3.1.4    # удалено
```

Из `analysis_options.yaml` удалена секция плагина:
```yaml
# было:
analyzer:
  plugins:
    - custom_lint
# стало: секция plugins отсутствует
```

### Последствия

- Riverpod-специфичные линты (напр. `avoid_public_notifier_auto_dispose`,
  `avoid_ref_inside_state_dispose`) больше **не проверяются автоматически**.
- Стандартный набор правил из `flutter_lints` остаётся активным.
- При появлении совместимых версий пакеты можно вернуть: убедитесь, что
  `custom_lint` и `riverpod_lint` требуют одинаковый диапазон `analyzer_plugin`.
