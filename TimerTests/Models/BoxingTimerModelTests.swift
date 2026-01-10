//
//  BoxingTimerModelTests.swift
//  TimerTests
//
//  Created by Grigory Don on 10.01.2026.
//

import XCTest
import SwiftUI
@testable import Timer

@MainActor
final class BoxingTimerModelTests: XCTestCase {
    var sut: BoxingTimerModel!

    override func setUp() async throws {
        sut = BoxingTimerModel()
    }

    override func tearDown() async throws {
        sut.reset()
        sut = nil
    }

    // MARK: - Initial State Tests
    func testInitialState() {
        XCTAssertEqual(sut.timerState, .idle)
        XCTAssertEqual(sut.timeRemaining, 0)
        XCTAssertEqual(sut.currentRound, 1)
        XCTAssertEqual(sut.roundDuration, 180)
        XCTAssertEqual(sut.restDuration, 60)
        XCTAssertEqual(sut.numberOfRounds, 3)
    }

    func testInitialStatusText() {
        XCTAssertEqual(sut.statusText, "Готов к тренировке")
    }

    func testCanStartWhenIdle() {
        XCTAssertTrue(sut.canStart)
        XCTAssertFalse(sut.isRunning)
    }

    // MARK: - Start Timer Tests
    func testStartTimer() {
        sut.start()

        XCTAssertEqual(sut.timerState, .running(phase: .round(number: 1)))
        XCTAssertEqual(sut.timeRemaining, 180)
        XCTAssertTrue(sut.isRunning)
        XCTAssertFalse(sut.canStart)
    }

    func testStartTimerSetsCorrectRound() {
        sut.start()

        if case .running(.round(let number)) = sut.timerState {
            XCTAssertEqual(number, 1)
        } else {
            XCTFail("Timer should be in running round state")
        }
    }

    func testStartTimerWithCustomDuration() {
        sut.roundDuration = 120
        sut.start()

        XCTAssertEqual(sut.timeRemaining, 120)
    }

    // MARK: - Pause Timer Tests
    func testPauseTimer() {
        sut.start()
        sut.pause()

        if case .paused(.round(let number)) = sut.timerState {
            XCTAssertEqual(number, 1)
        } else {
            XCTFail("Timer should be in paused state")
        }

        XCTAssertFalse(sut.isRunning)
        XCTAssertTrue(sut.canStart)
    }

    func testPausePreservesTimeRemaining() {
        sut.start()
        let initialTime = sut.timeRemaining
        sut.pause()

        XCTAssertEqual(sut.timeRemaining, initialTime)
    }

    func testResumeAfterPause() {
        sut.start()
        sut.pause()
        sut.start()

        XCTAssertTrue(sut.isRunning)
        if case .running(.round(let number)) = sut.timerState {
            XCTAssertEqual(number, 1)
        } else {
            XCTFail("Timer should be in running round state")
        }
    }

    // MARK: - Reset Timer Tests
    func testResetTimer() {
        sut.start()
        sut.reset()

        XCTAssertEqual(sut.timerState, .idle)
        XCTAssertEqual(sut.timeRemaining, 0)
        XCTAssertFalse(sut.isRunning)
        XCTAssertTrue(sut.canStart)
    }

    func testResetFromPausedState() {
        sut.start()
        sut.pause()
        sut.reset()

        XCTAssertEqual(sut.timerState, .idle)
        XCTAssertEqual(sut.timeRemaining, 0)
    }

    // MARK: - Current Round Tests
    func testCurrentRoundWhileRunning() {
        sut.start()
        XCTAssertEqual(sut.currentRound, 1)
    }

    func testCurrentRoundWhenIdle() {
        XCTAssertEqual(sut.currentRound, 1)
    }

    // MARK: - Settings Tests
    func testChangeRoundDuration() {
        sut.roundDuration = 240
        XCTAssertEqual(sut.roundDuration, 240)

        sut.start()
        XCTAssertEqual(sut.timeRemaining, 240)
    }

    func testChangeRestDuration() {
        sut.restDuration = 90
        XCTAssertEqual(sut.restDuration, 90)
    }

    func testChangeNumberOfRounds() {
        sut.numberOfRounds = 5
        XCTAssertEqual(sut.numberOfRounds, 5)
    }

    // MARK: - Edge Cases Tests
    func testStartWhenAlreadyRunning() {
        sut.start()
        let stateBefore = sut.timerState
        sut.start()

        XCTAssertEqual(sut.timerState, stateBefore)
    }

    func testPauseWhenNotRunning() {
        sut.pause()
        XCTAssertEqual(sut.timerState, .idle)
    }

    func testResetMultipleTimes() {
        sut.reset()
        sut.reset()
        sut.reset()

        XCTAssertEqual(sut.timerState, .idle)
        XCTAssertEqual(sut.timeRemaining, 0)
    }

    // MARK: - Multiple Rounds Tests
    func testMultipleRoundsConfiguration() {
        sut.numberOfRounds = 10
        XCTAssertEqual(sut.numberOfRounds, 10)

        sut.start()
        XCTAssertEqual(sut.currentRound, 1)
    }

    // MARK: - Sound Settings Tests
    func testDefaultSoundSettings() {
        XCTAssertEqual(sut.roundStartSound, .bell)
        XCTAssertEqual(sut.restStartSound, .beep)
        XCTAssertEqual(sut.roundWarningSound, .beep)
        XCTAssertEqual(sut.restWarningSound, .beep)
        XCTAssertEqual(sut.workoutCompleteSound, .complete)
    }

    func testChangeRoundStartSound() {
        sut.roundStartSound = .chime
        XCTAssertEqual(sut.roundStartSound, .chime)
    }

    func testChangeRestStartSound() {
        sut.restStartSound = .bloom
        XCTAssertEqual(sut.restStartSound, .bloom)
    }

    func testChangeRoundWarningSound() {
        sut.roundWarningSound = .anticipate
        XCTAssertEqual(sut.roundWarningSound, .anticipate)
    }

    func testChangeRestWarningSound() {
        sut.restWarningSound = .fanfare
        XCTAssertEqual(sut.restWarningSound, .fanfare)
    }

    func testChangeWorkoutCompleteSound() {
        sut.workoutCompleteSound = .spell
        XCTAssertEqual(sut.workoutCompleteSound, .spell)
    }

    func testChangingAllSoundsAtOnce() {
        sut.roundStartSound = .chime
        sut.restStartSound = .bloom
        sut.roundWarningSound = .anticipate
        sut.restWarningSound = .fanfare
        sut.workoutCompleteSound = .spell

        XCTAssertEqual(sut.roundStartSound, .chime)
        XCTAssertEqual(sut.restStartSound, .bloom)
        XCTAssertEqual(sut.roundWarningSound, .anticipate)
        XCTAssertEqual(sut.restWarningSound, .fanfare)
        XCTAssertEqual(sut.workoutCompleteSound, .spell)
    }

    func testSoundSettingsDoNotAffectTimerState() {
        sut.start()
        let stateBefore = sut.timerState

        sut.roundStartSound = .chime
        sut.restStartSound = .bloom

        XCTAssertEqual(sut.timerState, stateBefore)
    }

    // MARK: - Warning Time Tests
    func testDefaultWarningTimes() {
        XCTAssertEqual(sut.roundWarningTime, 10)
        XCTAssertEqual(sut.restWarningTime, 10)
    }

    func testChangeRoundWarningTime() {
        sut.roundWarningTime = 15
        XCTAssertEqual(sut.roundWarningTime, 15)
    }

    func testChangeRestWarningTime() {
        sut.restWarningTime = 5
        XCTAssertEqual(sut.restWarningTime, 5)
    }

    func testWarningTimeWithZeroValue() {
        sut.roundWarningTime = 0
        XCTAssertEqual(sut.roundWarningTime, 0)
    }

    func testWarningTimeWithLargeValue() {
        sut.roundWarningTime = 60
        XCTAssertEqual(sut.roundWarningTime, 60)
    }
}
