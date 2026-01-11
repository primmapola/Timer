//
//  WorkoutPreset.swift
//  Timer
//
//  Created by Grigory Don on 11.01.2026.
//

import Foundation
import SwiftData

@Model
final class WorkoutPreset {
    var id: UUID
    var name: String
    var roundDuration: TimeInterval
    var restDuration: TimeInterval
    var numberOfRounds: Int
    var roundWarningTime: TimeInterval
    var restWarningTime: TimeInterval
    var createdAt: Date

    // Rounds configuration (stored as JSON data)
    var roundsConfigurationData: Data?

    // Sound settings (stored as raw values)
    var roundStartSoundValue: UInt32
    var restStartSoundValue: UInt32
    var roundWarningSoundValue: UInt32
    var restWarningSoundValue: UInt32
    var workoutCompleteSoundValue: UInt32

    // Computed property for rounds configuration
    var roundsConfiguration: RoundsConfigurationMode {
        get {
            guard let data = roundsConfigurationData,
                  let config = try? JSONDecoder().decode(RoundsConfigurationMode.self, from: data) else {
                return .uniform(roundDuration: roundDuration, restDuration: restDuration, count: numberOfRounds)
            }
            return config
        }
        set {
            roundsConfigurationData = try? JSONEncoder().encode(newValue)
        }
    }

    init(
        name: String,
        roundDuration: TimeInterval,
        restDuration: TimeInterval,
        numberOfRounds: Int,
        roundWarningTime: TimeInterval,
        restWarningTime: TimeInterval,
        roundStartSound: SystemSound,
        restStartSound: SystemSound,
        roundWarningSound: SystemSound,
        restWarningSound: SystemSound,
        workoutCompleteSound: SystemSound
    ) {
        self.id = UUID()
        self.name = name
        self.roundDuration = roundDuration
        self.restDuration = restDuration
        self.numberOfRounds = numberOfRounds
        self.roundWarningTime = roundWarningTime
        self.restWarningTime = restWarningTime
        self.createdAt = Date()
        self.roundStartSoundValue = roundStartSound.rawValue
        self.restStartSoundValue = restStartSound.rawValue
        self.roundWarningSoundValue = roundWarningSound.rawValue
        self.restWarningSoundValue = restWarningSound.rawValue
        self.workoutCompleteSoundValue = workoutCompleteSound.rawValue
    }

    // Convenience properties for sounds
    var roundStartSound: SystemSound {
        get { SystemSound(rawValue: roundStartSoundValue) ?? .bell }
        set { roundStartSoundValue = newValue.rawValue }
    }

    var restStartSound: SystemSound {
        get { SystemSound(rawValue: restStartSoundValue) ?? .beep }
        set { restStartSoundValue = newValue.rawValue }
    }

    var roundWarningSound: SystemSound {
        get { SystemSound(rawValue: roundWarningSoundValue) ?? .beep }
        set { roundWarningSoundValue = newValue.rawValue }
    }

    var restWarningSound: SystemSound {
        get { SystemSound(rawValue: restWarningSoundValue) ?? .beep }
        set { restWarningSoundValue = newValue.rawValue }
    }

    var workoutCompleteSound: SystemSound {
        get { SystemSound(rawValue: workoutCompleteSoundValue) ?? .complete }
        set { workoutCompleteSoundValue = newValue.rawValue }
    }

    // Создать пресет из текущих настроек модели
    @MainActor
    convenience init(name: String, from model: BoxingTimerModel) {
        self.init(
            name: name,
            roundDuration: model.roundDuration,
            restDuration: model.restDuration,
            numberOfRounds: model.numberOfRounds,
            roundWarningTime: model.roundWarningTime,
            restWarningTime: model.restWarningTime,
            roundStartSound: model.roundStartSound,
            restStartSound: model.restStartSound,
            roundWarningSound: model.roundWarningSound,
            restWarningSound: model.restWarningSound,
            workoutCompleteSound: model.workoutCompleteSound
        )
        // Сохраняем конфигурацию раундов
        self.roundsConfiguration = model.roundsConfiguration
    }

    // Применить настройки пресета к модели
    @MainActor
    func apply(to model: BoxingTimerModel) {
        model.currentPresetName = name
        model.currentPresetId = id
        model.roundsConfiguration = roundsConfiguration
        model.roundWarningTime = roundWarningTime
        model.restWarningTime = restWarningTime
        model.roundStartSound = roundStartSound
        model.restStartSound = restStartSound
        model.roundWarningSound = roundWarningSound
        model.restWarningSound = restWarningSound
        model.workoutCompleteSound = workoutCompleteSound
    }

    // Обновить пресет данными из модели
    @MainActor
    func update(from model: BoxingTimerModel) {
        self.name = model.currentPresetName
        self.roundsConfiguration = model.roundsConfiguration

        // Обновляем базовые значения для обратной совместимости
        self.roundDuration = model.roundDuration
        self.restDuration = model.restDuration
        self.numberOfRounds = model.numberOfRounds

        self.roundWarningTime = model.roundWarningTime
        self.restWarningTime = model.restWarningTime
        self.roundStartSound = model.roundStartSound
        self.restStartSound = model.restStartSound
        self.roundWarningSound = model.roundWarningSound
        self.restWarningSound = model.restWarningSound
        self.workoutCompleteSound = model.workoutCompleteSound
    }
}
