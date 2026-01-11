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
    var roundConfigurationsData: Data = Data()
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
        workoutCompleteSound: SystemSound,
        roundConfigurations: [RoundConfiguration]? = nil
    ) {
        let configurations = roundConfigurations ?? Self.fallbackRoundConfigurations(
            numberOfRounds: numberOfRounds,
            roundDuration: roundDuration,
            restDuration: restDuration,
            roundWarningTime: roundWarningTime
        )
        let primaryConfiguration = configurations.first ?? .defaultConfiguration

        self.id = UUID()
        self.name = name
        self.roundDuration = primaryConfiguration.roundDuration
        self.restDuration = primaryConfiguration.restDuration
        self.numberOfRounds = configurations.count
        self.roundWarningTime = primaryConfiguration.roundWarningTime
        self.restWarningTime = restWarningTime
        self.createdAt = Date()
        self.roundConfigurationsData = Self.encodeRoundConfigurations(configurations)
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

    var roundConfigurations: [RoundConfiguration] {
        get {
            if let decoded = Self.decodeRoundConfigurations(roundConfigurationsData), !decoded.isEmpty {
                return decoded
            }
            return Self.fallbackRoundConfigurations(
                numberOfRounds: numberOfRounds,
                roundDuration: roundDuration,
                restDuration: restDuration,
                roundWarningTime: roundWarningTime
            )
        }
        set {
            roundConfigurationsData = Self.encodeRoundConfigurations(newValue)
            numberOfRounds = newValue.count
            if let primary = newValue.first {
                roundDuration = primary.roundDuration
                restDuration = primary.restDuration
                roundWarningTime = primary.roundWarningTime
            }
        }
    }

    // Создать пресет из текущих настроек модели
    @MainActor
    convenience init(name: String, from model: BoxingTimerModel) {
        self.init(
            name: name,
            roundDuration: model.roundConfigurations.first?.roundDuration ?? RoundConfiguration.defaultConfiguration.roundDuration,
            restDuration: model.roundConfigurations.first?.restDuration ?? RoundConfiguration.defaultConfiguration.restDuration,
            numberOfRounds: model.numberOfRounds,
            roundWarningTime: model.roundConfigurations.first?.roundWarningTime ?? RoundConfiguration.defaultConfiguration.roundWarningTime,
            restWarningTime: model.restWarningTime,
            roundStartSound: model.roundStartSound,
            restStartSound: model.restStartSound,
            roundWarningSound: model.roundWarningSound,
            restWarningSound: model.restWarningSound,
            workoutCompleteSound: model.workoutCompleteSound,
            roundConfigurations: model.roundConfigurations
        )
    }

    // Применить настройки пресета к модели
    @MainActor
    func apply(to model: BoxingTimerModel) {
        model.currentPresetName = name
        model.updateRoundConfigurations(roundConfigurations)
        model.restWarningTime = restWarningTime
        model.roundStartSound = roundStartSound
        model.restStartSound = restStartSound
        model.roundWarningSound = roundWarningSound
        model.restWarningSound = restWarningSound
        model.workoutCompleteSound = workoutCompleteSound
    }

    private static func encodeRoundConfigurations(_ configurations: [RoundConfiguration]) -> Data {
        let encoder = JSONEncoder()
        return (try? encoder.encode(configurations)) ?? Data()
    }

    private static func decodeRoundConfigurations(_ data: Data) -> [RoundConfiguration]? {
        guard !data.isEmpty else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([RoundConfiguration].self, from: data)
    }

    private static func fallbackRoundConfigurations(
        numberOfRounds: Int,
        roundDuration: TimeInterval,
        restDuration: TimeInterval,
        roundWarningTime: TimeInterval
    ) -> [RoundConfiguration] {
        let count = max(1, numberOfRounds)
        return (0..<count).map { _ in
            RoundConfiguration(
                roundDuration: roundDuration,
                restDuration: restDuration,
                roundWarningTime: roundWarningTime
            )
        }
    }
}
