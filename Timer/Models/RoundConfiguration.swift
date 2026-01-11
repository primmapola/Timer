//
//  RoundConfiguration.swift
//  Timer
//
//  Created by Grigory Don on 12.01.2026.
//

import Foundation

struct RoundConfiguration: Codable, Hashable, Identifiable {
    let id: UUID
    var roundDuration: TimeInterval
    var restDuration: TimeInterval
    var roundWarningTime: TimeInterval

    init(
        id: UUID = UUID(),
        roundDuration: TimeInterval,
        restDuration: TimeInterval,
        roundWarningTime: TimeInterval
    ) {
        self.id = id
        self.roundDuration = roundDuration
        self.restDuration = restDuration
        self.roundWarningTime = roundWarningTime
    }

    static var defaultConfiguration: RoundConfiguration {
        RoundConfiguration(
            roundDuration: 180,
            restDuration: 60,
            roundWarningTime: 10
        )
    }

    static func defaults(count: Int) -> [RoundConfiguration] {
        guard count > 0 else { return [] }
        return (0..<count).map { _ in RoundConfiguration.defaultConfiguration }
    }
}
