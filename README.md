# Boxing Timer

Таймер для тренировок по боксу на SwiftUI.

## Функции

- Настраиваемое время раундов и отдыха
- Гибкое количество раундов (1-20)
- Пауза и возобновление
- Звуковые сигналы
- Минималистичный дизайн
- **Live Activity на экране блокировки и Dynamic Island**

## Архитектура

```
Timer/
├── Models/
│   ├── BoxingTimerModel.swift              # Бизнес-логика
│   └── BoxingTimerActivityAttributes.swift # Live Activity модель
├── Views/
│   ├── BoxingTimerView.swift               # Главный экран
│   ├── SettingsView.swift                  # Настройки
│   └── Components/TimePickerRow.swift      # Выбор времени
├── TimerApp.swift
└── TimerWidgetExtension/
    ├── TimerLiveActivity.swift             # Live Activity виджет
    ├── TimerWidgetBundle.swift             # Widget bundle
    └── Info.plist
```

## Тестирование

**42 теста с 100% успешным прохождением**

```
TimerTests/
├── Models/          # 20 тестов - Бизнес-логика
├── ViewModels/      # 7 тестов - Presentation
├── Utils/           # 7 тестов - Форматирование
└── Integration/     # 8 тестов - E2E
```

### Запуск тестов

```bash
# Все unit тесты (~0.1s)
./test-direct.sh unit

# По слоям
./test-direct.sh models
./test-direct.sh viewmodels
./test-direct.sh utils
./test-direct.sh integration

# С code coverage
./test-direct.sh coverage

# Все тесты включая UI (~45s)
./test-direct.sh all
```

## Требования

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

## Запуск

1. Открой `Timer.xcodeproj` в Xcode
2. Выбери симулятор
3. Нажми Cmd+R

## Технологии

- SwiftUI - UI framework
- Combine - Timer management
- @Observable - State management
- XCTest - Testing
- AVFoundation - Sound alerts
- ActivityKit - Live Activities
- WidgetKit - Widget extension

## Настройка Live Activity

### Шаг 1: Добавить Widget Extension в Xcode

1. Откройте проект в Xcode
2. File → New → Target
3. Выберите **Widget Extension**
4. Название: `TimerWidgetExtension`
5. Bundle Identifier: `com.yourcompany.Timer.TimerWidgetExtension`
6. Снимите галочку "Include Configuration Intent"
7. Нажмите Finish

### Шаг 2: Настроить основное приложение

1. Откройте Target приложения Timer
2. Перейдите в Info
3. Добавьте новый ключ: `NSSupportsLiveActivities` = `YES`

### Шаг 3: Настроить файлы Widget Extension

1. В файле `TimerWidgetExtensionBundle.swift` обновите body:
```swift
var body: some Widget {
    TimerLiveActivity()
}
```

2. Добавьте `BoxingTimerActivityAttributes.swift` в оба targets:
   - Выберите файл в Project Navigator
   - В File Inspector справа отметьте галочки для обоих targets: Timer и TimerWidgetExtensionExtension

3. Можете удалить ненужные автоматически созданные файлы (опционально):
   - `TimerWidgetExtension.swift`
   - `TimerWidgetExtensionControl.swift`
   - `TimerWidgetExtensionLiveActivity.swift`
   - `AppIntent.swift`

### Шаг 4: Настроить основное приложение (Info.plist)

1. Откройте Target приложения Timer
2. Перейдите в Info
3. Добавьте новый ключ: `NSSupportsLiveActivities` = `YES`

### Шаг 5: Запустить приложение

1. Выберите схему Timer
2. Запустите на устройстве с iOS 16.1+ или в симуляторе
3. Начните тренировку - Live Activity автоматически появится на экране блокировки

**Примечание:** Dynamic Island работает только на реальных устройствах iPhone 14 Pro и новее

## Live Activity Features

### На экране блокировки:
- Текущая фаза (Раунд/Отдых)
- Номер текущего раунда
- Оставшееся время
- Статус паузы

### В Dynamic Island (iPhone 14 Pro+):
- **Компактный вид**: Иконка фазы + время
- **Минимальный вид**: Только иконка
- **Расширенный вид**:
  - Полное время в крупном шрифте
  - Номер раунда и общее количество
  - Текущая фаза с иконкой
  - Статус паузы
