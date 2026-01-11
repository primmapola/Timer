//
//  StatusDisplayTests.swift
//  TimerTests
//
//  Created by Grigory Don on 10.01.2026.
//

import XCTest
import SwiftUI
@testable import Timer

@MainActor
final class StatusDisplayTests: XCTestCase {
    var sut: BoxingTimerModel!

    override func setUp() async throws {
        sut = BoxingTimerModel()
    }

    override func tearDown() async throws {
        sut = nil
    }

    // MARK: - Status Text Tests
    func testStatusTextWhenIdle() {
        XCTAssertEqual(sut.statusText, String(localized: "status.text.idle"))
    }

    func testStatusTextWhileRunningRound() {
        sut.start()
        XCTAssertEqual(sut.statusText, String.localizedStringWithFormat(String(localized: "status.text.round"), 1))
    }

    func testStatusTextWhenFinished() {
        sut.start()
        sut.reset()
        XCTAssertEqual(sut.statusText, String(localized: "status.text.idle"))
    }

    func testStatusTextWhilePaused() {
        sut.start()
        sut.pause()
        XCTAssertEqual(sut.statusText, String.localizedStringWithFormat(String(localized: "status.text.round"), 1))
    }

    // MARK: - Status Color Tests
    func testStatusColorWhenIdle() {
        XCTAssertEqual(sut.statusColor, .primary)
    }

    func testStatusColorForRound() {
        sut.start()
        XCTAssertEqual(sut.statusColor, .red)
    }

    func testStatusColorForRoundWhilePaused() {
        sut.start()
        sut.pause()
        XCTAssertEqual(sut.statusColor, .orange)
    }
}
