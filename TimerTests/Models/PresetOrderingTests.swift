//
//  PresetOrderingTests.swift
//  TimerTests
//
//  Created by Grigory Don on 11.01.2026.
//

import XCTest
@testable import Timer

final class PresetOrderingTests: XCTestCase {
    func testDuplicateInsertionDateFallsBetweenPresetAndNext() {
        let newest = WorkoutPreset(
            name: "Newest",
            roundDuration: 60,
            restDuration: 30,
            numberOfRounds: 1,
            roundWarningTime: 5,
            restWarningTime: 5,
            roundStartSound: .bell,
            restStartSound: .beep,
            roundWarningSound: .beep,
            restWarningSound: .beep,
            workoutCompleteSound: .complete
        )
        let target = WorkoutPreset(
            name: "Target",
            roundDuration: 60,
            restDuration: 30,
            numberOfRounds: 1,
            roundWarningTime: 5,
            restWarningTime: 5,
            roundStartSound: .bell,
            restStartSound: .beep,
            roundWarningSound: .beep,
            restWarningSound: .beep,
            workoutCompleteSound: .complete
        )
        let next = WorkoutPreset(
            name: "Next",
            roundDuration: 60,
            restDuration: 30,
            numberOfRounds: 1,
            roundWarningTime: 5,
            restWarningTime: 5,
            roundStartSound: .bell,
            restStartSound: .beep,
            roundWarningSound: .beep,
            restWarningSound: .beep,
            workoutCompleteSound: .complete
        )

        newest.createdAt = Date(timeIntervalSince1970: 300)
        target.createdAt = Date(timeIntervalSince1970: 200)
        next.createdAt = Date(timeIntervalSince1970: 100)

        let presets = [newest, target, next]
        let insertionDate = PresetOrdering.duplicateInsertionDate(for: target, in: presets)

        XCTAssertTrue(insertionDate < target.createdAt && insertionDate > next.createdAt)
    }

    func testDuplicateInsertionDateFallsBeforeLastPreset() {
        let oldest = WorkoutPreset(
            name: "Oldest",
            roundDuration: 60,
            restDuration: 30,
            numberOfRounds: 1,
            roundWarningTime: 5,
            restWarningTime: 5,
            roundStartSound: .bell,
            restStartSound: .beep,
            roundWarningSound: .beep,
            restWarningSound: .beep,
            workoutCompleteSound: .complete
        )
        oldest.createdAt = Date(timeIntervalSince1970: 100)

        let presets = [oldest]
        let insertionDate = PresetOrdering.duplicateInsertionDate(for: oldest, in: presets)

        XCTAssertLessThan(insertionDate, oldest.createdAt)
    }
}
