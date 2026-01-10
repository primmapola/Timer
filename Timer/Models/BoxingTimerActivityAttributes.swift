//
//  BoxingTimerActivityAttributes.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import ActivityKit
import Foundation

struct BoxingTimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Динамические данные, которые обновляются
        var timeRemaining: TimeInterval
        var currentRound: Int
        var phase: Phase
        var isPaused: Bool

        enum Phase: String, Codable, Hashable {
            case round
            case rest
            case finished
        }
    }

    // Статические данные, которые не изменяются
    var workoutName: String
    var numberOfRounds: Int
    var roundDuration: TimeInterval
    var restDuration: TimeInterval
}
