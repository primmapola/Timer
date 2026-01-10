//
//  TimerTests.swift
//  TimerTests
//
//  Created by Grigory Don on 10.01.2026.
//
//  Main test suite configuration file.
//  Individual test files are organized by layer:
//  - Models/: Business logic tests
//  - ViewModels/: Presentation layer tests
//  - Utils/: Utility function tests
//  - Integration/: End-to-end workflow tests
//

import XCTest
@testable import Timer

final class TimerTestConfiguration: XCTestCase {

    override class func setUp() {
        super.setUp()
        // Global test configuration can go here
    }

    override class func tearDown() {
        super.tearDown()
        // Global test cleanup
    }
}
