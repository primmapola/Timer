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

    // Sound settings (stored as raw values)
    var roundStartSoundValue: UInt32
    var restStartSoundValue: UInt32
    var roundWarningSoundValue: UInt32
    var restWarningSoundValue: UInt32
    var workoutCompleteSoundValue: UInt32

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
    }

    // Применить настройки пресета к модели
    @MainActor
    func apply(to model: BoxingTimerModel) {
        model.currentPresetName = name
        model.roundDuration = roundDuration
        model.restDuration = restDuration
        model.numberOfRounds = numberOfRounds
        model.roundWarningTime = roundWarningTime
        model.restWarningTime = restWarningTime
        model.roundStartSound = roundStartSound
        model.restStartSound = restStartSound
        model.roundWarningSound = roundWarningSound
        model.restWarningSound = restWarningSound
        model.workoutCompleteSound = workoutCompleteSound
    }
}
