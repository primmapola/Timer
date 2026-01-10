//
//  TimeFormatterTests.swift
//  TimerTests
//
//  Created by Grigory Don on 10.01.2026.
//

import XCTest
@testable import Timer

@MainActor
final class TimeFormatterTests: XCTestCase {
    var sut: BoxingTimerModel!

    override func setUp() async throws {
        sut = BoxingTimerModel()
    }

    override func tearDown() async throws {
        sut = nil
    }

    // MARK: - Format Time Tests
    func testFormatTimeZeroSeconds() {
        let formatted = sut.formatTime(0)
        XCTAssertEqual(formatted, "00:00")
    }

    func testFormatTimeOneMinute() {
        let formatted = sut.formatTime(60)
        XCTAssertEqual(formatted, "01:00")
    }

    func testFormatTimeTwoMinutesThirtySeconds() {
        let formatted = sut.formatTime(150)
        XCTAssertEqual(formatted, "02:30")
    }

    func testFormatTimeThreeMinutes() {
        let formatted = sut.formatTime(180)
        XCTAssertEqual(formatted, "03:00")
    }

    func testFormatTimeNineMinutesFiftyNineSeconds() {
        let formatted = sut.formatTime(599)
        XCTAssertEqual(formatted, "09:59")
    }

    func testFormatTimeTenMinutes() {
        let formatted = sut.formatTime(600)
        XCTAssertEqual(formatted, "10:00")
    }

    func testFormatTimeOneSecond() {
        let formatted = sut.formatTime(1)
        XCTAssertEqual(formatted, "00:01")
    }
}
