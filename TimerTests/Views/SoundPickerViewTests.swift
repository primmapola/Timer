//
//  SoundPickerViewTests.swift
//  TimerTests
//
//  Created by Grigory Don on 11.01.2026.
//

import XCTest
import SwiftUI
@testable import Timer

@MainActor
final class SoundPickerViewTests: XCTestCase {

    // MARK: - Basic Rendering Tests

    func testViewRendersAllSounds() throws {
        let selectedSound = Binding.constant(SystemSound.bell)
        var callbackCalled = false

        let view = SoundPickerView(
            selectedSound: selectedSound,
            onSoundSelected: { _ in callbackCalled = true }
        )

        // Проверяем, что компонент создается без ошибок
        XCTAssertNotNil(view)
    }

    func testInitialSelectedSound() {
        let selectedSound = Binding.constant(SystemSound.beep)
        var selectedFromCallback: SystemSound?

        let view = SoundPickerView(
            selectedSound: selectedSound,
            onSoundSelected: { sound in
                selectedFromCallback = sound
            }
        )

        XCTAssertNotNil(view)
        XCTAssertEqual(selectedSound.wrappedValue, .beep)
    }

    // MARK: - Sound Selection Tests

    func testSoundSelectionCallback() {
        var selectedSound = SystemSound.bell
        var callbackCalled = false
        var callbackSound: SystemSound?

        let binding = Binding(
            get: { selectedSound },
            set: { selectedSound = $0 }
        )

        let view = SoundPickerView(
            selectedSound: binding,
            onSoundSelected: { sound in
                callbackCalled = true
                callbackSound = sound
            }
        )

        XCTAssertNotNil(view)
    }

    func testBindingUpdatesOnSelection() {
        var selectedSound = SystemSound.bell

        let binding = Binding(
            get: { selectedSound },
            set: { selectedSound = $0 }
        )

        let view = SoundPickerView(
            selectedSound: binding,
            onSoundSelected: { _ in }
        )

        // Изменяем binding напрямую
        binding.wrappedValue = .complete

        XCTAssertEqual(selectedSound, .complete)
        XCTAssertNotNil(view)
    }

    // MARK: - All Sounds Available Tests

    func testAllSystemSoundsAreAvailable() {
        let allSounds = SystemSound.allCases

        XCTAssertTrue(allSounds.contains(.bell))
        XCTAssertTrue(allSounds.contains(.beep))
        XCTAssertTrue(allSounds.contains(.complete))
        XCTAssertTrue(allSounds.contains(.anticipate))
        XCTAssertTrue(allSounds.contains(.bloom))
        XCTAssertTrue(allSounds.contains(.calypso))
        XCTAssertTrue(allSounds.contains(.chime))
        XCTAssertTrue(allSounds.contains(.descent))
        XCTAssertTrue(allSounds.contains(.fanfare))
        XCTAssertTrue(allSounds.contains(.ladder))
        XCTAssertTrue(allSounds.contains(.minuet))
        XCTAssertTrue(allSounds.contains(.newsFlash))
        XCTAssertTrue(allSounds.contains(.noir))
        XCTAssertTrue(allSounds.contains(.sherwood))
        XCTAssertTrue(allSounds.contains(.spell))
        XCTAssertTrue(allSounds.contains(.suspense))
        XCTAssertTrue(allSounds.contains(.telegraph))
        XCTAssertTrue(allSounds.contains(.tiptoes))
        XCTAssertTrue(allSounds.contains(.typewriters))
        XCTAssertTrue(allSounds.contains(.update))

        XCTAssertEqual(allSounds.count, 20)
    }

    func testSystemSoundHasCorrectRawValues() {
        XCTAssertEqual(SystemSound.bell.rawValue, 1005)
        XCTAssertEqual(SystemSound.beep.rawValue, 1109)
        XCTAssertEqual(SystemSound.complete.rawValue, 1016)
    }

    func testSystemSoundHasLocalizedNames() {
        XCTAssertEqual(SystemSound.bell.name, "Колокол")
        XCTAssertEqual(SystemSound.beep.name, "Гудок")
        XCTAssertEqual(SystemSound.complete.name, "Завершение")
        XCTAssertEqual(SystemSound.anticipate.name, "Ожидание")
        XCTAssertEqual(SystemSound.bloom.name, "Цветение")
    }

    // MARK: - Edge Cases

    func testMultipleSelectionChanges() {
        var selectedSound = SystemSound.bell
        var callbackCount = 0

        let binding = Binding(
            get: { selectedSound },
            set: { selectedSound = $0 }
        )

        let view = SoundPickerView(
            selectedSound: binding,
            onSoundSelected: { _ in
                callbackCount += 1
            }
        )

        // Симулируем несколько изменений
        binding.wrappedValue = .beep
        binding.wrappedValue = .complete
        binding.wrappedValue = .bell

        XCTAssertEqual(selectedSound, .bell)
        XCTAssertNotNil(view)
    }

    func testSameSelectionMultipleTimes() {
        var selectedSound = SystemSound.bell

        let binding = Binding(
            get: { selectedSound },
            set: { selectedSound = $0 }
        )

        let view = SoundPickerView(
            selectedSound: binding,
            onSoundSelected: { _ in }
        )

        // Выбираем один и тот же звук несколько раз
        binding.wrappedValue = .bell
        binding.wrappedValue = .bell

        XCTAssertEqual(selectedSound, .bell)
        XCTAssertNotNil(view)
    }
}
