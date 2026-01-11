//
//  RoundConfiguration.swift
//  Timer
//
//  Created by Grigory Don on 11.01.2026.
//

import Foundation

/// Конфигурация для отдельного раунда
struct RoundConfiguration: Identifiable, Codable, Equatable {
    let id: UUID
    var roundDuration: TimeInterval
    var restDuration: TimeInterval
    var roundWarningTime: TimeInterval?
    var restWarningTime: TimeInterval?

    init(id: UUID = UUID(), roundDuration: TimeInterval, restDuration: TimeInterval, roundWarningTime: TimeInterval? = nil, restWarningTime: TimeInterval? = nil) {
        self.id = id
        self.roundDuration = roundDuration
        self.restDuration = restDuration
        self.roundWarningTime = roundWarningTime
        self.restWarningTime = restWarningTime
    }
}

/// Режим конфигурации раундов
enum RoundsConfigurationMode: Codable, Equatable {
    /// Все раунды одинаковые (простой режим)
    case uniform(roundDuration: TimeInterval, restDuration: TimeInterval, count: Int)

    /// Индивидуальные настройки для каждого раунда
    case individual(rounds: [RoundConfiguration])

    var numberOfRounds: Int {
        switch self {
        case .uniform(_, _, let count):
            return count
        case .individual(let rounds):
            return rounds.count
        }
    }

    var rounds: [RoundConfiguration] {
        switch self {
        case .uniform(let roundDuration, let restDuration, let count):
            return (0..<count).map { _ in
                RoundConfiguration(roundDuration: roundDuration, restDuration: restDuration)
            }
        case .individual(let rounds):
            return rounds
        }
    }

    /// Получить конфигурацию для конкретного раунда (номер с 1)
    func configuration(forRound roundNumber: Int) -> RoundConfiguration? {
        let index = roundNumber - 1
        guard index >= 0 && index < numberOfRounds else { return nil }
        return rounds[index]
    }

    /// Общая длительность тренировки
    var totalDuration: TimeInterval {
        rounds.reduce(0) { total, round in
            total + round.roundDuration + round.restDuration
        } - (rounds.last?.restDuration ?? 0) // Вычитаем последний отдых
    }
}
