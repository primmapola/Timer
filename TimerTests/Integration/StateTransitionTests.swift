//
//  StateTransitionTests.swift
//  TimerTests
//
//  Created by Grigory Don on 10.01.2026.
//

import XCTest
@testable import Timer

@MainActor
final class StateTransitionTests: XCTestCase {
    var sut: BoxingTimerModel!

    override func setUp() async throws {
        sut = BoxingTimerModel()
    }

    override func tearDown() async throws {
        sut.reset()
        sut = nil
    }

    // MARK: - State Transition Tests
    func testIdleToRunning() {
        XCTAssertEqual(sut.timerState, .idle)
        sut.start()
        XCTAssertTrue(sut.isRunning)
    }

    func testRunningToPaused() {
        sut.start()
        XCTAssertTrue(sut.isRunning)
        sut.pause()
        XCTAssertFalse(sut.isRunning)
    }

    func testPausedToRunning() {
        sut.start()
        sut.pause()
        XCTAssertFalse(sut.isRunning)
        sut.start()
        XCTAssertTrue(sut.isRunning)
    }

    func testRunningToIdle() {
        sut.start()
        XCTAssertTrue(sut.isRunning)
        sut.reset()
        XCTAssertEqual(sut.timerState, .idle)
    }

    func testPausedToIdle() {
        sut.start()
        sut.pause()
        sut.reset()
        XCTAssertEqual(sut.timerState, .idle)
    }

    func testIdleToIdleTransition() {
        XCTAssertEqual(sut.timerState, .idle)
        sut.reset()
        XCTAssertEqual(sut.timerState, .idle)
    }

    // MARK: - Integration Tests
    func testFullWorkoutCycle() {
        let configuration = RoundConfiguration(
            roundDuration: 5,
            restDuration: 3,
            roundWarningTime: 1
        )
        sut.updateRoundConfigurations([configuration, configuration])

        // Start workout
        sut.start()
        XCTAssertTrue(sut.isRunning)
        XCTAssertEqual(sut.currentRound, 1)
        XCTAssertEqual(sut.timeRemaining, 5)

        // Pause and resume
        sut.pause()
        XCTAssertFalse(sut.isRunning)

        sut.start()
        XCTAssertTrue(sut.isRunning)

        // Reset
        sut.reset()
        XCTAssertEqual(sut.timerState, .idle)
        XCTAssertEqual(sut.timeRemaining, 0)
    }

    func testComplexStateTransitions() {
        // Idle -> Running
        sut.start()
        XCTAssertTrue(sut.isRunning)

        // Running -> Paused
        sut.pause()
        XCTAssertFalse(sut.isRunning)

        // Paused -> Running
        sut.start()
        XCTAssertTrue(sut.isRunning)

        // Running -> Paused
        sut.pause()
        XCTAssertFalse(sut.isRunning)

        // Paused -> Idle
        sut.reset()
        XCTAssertEqual(sut.timerState, .idle)
    }
}
