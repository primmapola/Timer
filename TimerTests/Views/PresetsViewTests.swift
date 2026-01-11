//
//  PresetsViewTests.swift
//  TimerTests
//
//  Created by Grigory Don on 11.01.2026.
//

import XCTest
import SwiftUI
import SwiftData
@testable import Timer

@MainActor
final class PresetsViewTests: XCTestCase {
    var modelContext: ModelContext!
    var model: BoxingTimerModel!

    override func setUp() async throws {
        // Create in-memory model container for testing
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: WorkoutPreset.self, configurations: config)
        modelContext = container.mainContext
        model = BoxingTimerModel()
    }

    override func tearDown() async throws {
        modelContext = nil
        model = nil
    }

    // MARK: - Create New Preset Tests

    func testCreateNewPresetFromModel() throws {
        // Given: Configure model with specific settings
        model.roundDuration = 120
        model.restDuration = 45
        model.numberOfRounds = 5
        model.roundWarningTime = 15
        model.restWarningTime = 10
        model.roundStartSound = .bell
        model.restStartSound = .chime

        // When: Create preset from model
        let presetName = "Test Workout"
        let preset = WorkoutPreset(name: presetName, from: model)

        // Then: Verify preset has correct values
        XCTAssertEqual(preset.name, presetName)
        XCTAssertEqual(preset.roundDuration, 120)
        XCTAssertEqual(preset.restDuration, 45)
        XCTAssertEqual(preset.numberOfRounds, 5)
        XCTAssertEqual(preset.roundWarningTime, 15)
        XCTAssertEqual(preset.restWarningTime, 10)
        XCTAssertEqual(preset.roundStartSound, .bell)
        XCTAssertEqual(preset.restStartSound, .chime)
    }

    func testCreateNewPresetWithUniformConfiguration() throws {
        // Given: Model with uniform configuration
        model.roundsConfiguration = .uniform(roundDuration: 180, restDuration: 60, count: 3)

        // When: Create preset
        let preset = WorkoutPreset(name: "Uniform Workout", from: model)

        // Then: Verify configuration is copied
        if case .uniform(let roundDuration, let restDuration, let count) = preset.roundsConfiguration {
            XCTAssertEqual(roundDuration, 180)
            XCTAssertEqual(restDuration, 60)
            XCTAssertEqual(count, 3)
        } else {
            XCTFail("Expected uniform configuration")
        }
    }

    func testCreateNewPresetWithIndividualConfiguration() throws {
        // Given: Model with individual rounds configuration
        let rounds = [
            RoundConfiguration(roundDuration: 60, restDuration: 30),
            RoundConfiguration(roundDuration: 120, restDuration: 45),
            RoundConfiguration(roundDuration: 180, restDuration: 60)
        ]
        model.roundsConfiguration = .individual(rounds: rounds)

        // When: Create preset
        let preset = WorkoutPreset(name: "Individual Workout", from: model)

        // Then: Verify individual rounds are copied
        if case .individual(let presetRounds) = preset.roundsConfiguration {
            XCTAssertEqual(presetRounds.count, 3)
            XCTAssertEqual(presetRounds[0].roundDuration, 60)
            XCTAssertEqual(presetRounds[0].restDuration, 30)
            XCTAssertEqual(presetRounds[1].roundDuration, 120)
            XCTAssertEqual(presetRounds[1].restDuration, 45)
            XCTAssertEqual(presetRounds[2].roundDuration, 180)
            XCTAssertEqual(presetRounds[2].restDuration, 60)
        } else {
            XCTFail("Expected individual configuration")
        }
    }

    func testCreatePresetAndSaveToContext() throws {
        // Given: A new preset
        let preset = WorkoutPreset(name: "Context Test", from: model)

        // When: Insert and save to context
        modelContext.insert(preset)
        try modelContext.save()

        // Then: Verify preset is persisted
        let fetchDescriptor = FetchDescriptor<WorkoutPreset>()
        let presets = try modelContext.fetch(fetchDescriptor)

        XCTAssertEqual(presets.count, 1)
        XCTAssertEqual(presets.first?.name, "Context Test")
    }

    func testCreatePresetWithEmptyNameShouldStillWork() throws {
        // Given: Empty preset name (UI should prevent this, but model allows it)
        let preset = WorkoutPreset(name: "", from: model)

        // Then: Preset should be created
        XCTAssertNotNil(preset)
        XCTAssertEqual(preset.name, "")
    }

    // MARK: - Duplicate Preset Tests

    func testDuplicatePresetCopiesAllProperties() throws {
        // Given: An existing preset with specific values
        let original = WorkoutPreset(
            name: "Original Workout",
            roundDuration: 150,
            restDuration: 50,
            numberOfRounds: 4,
            roundWarningTime: 12,
            restWarningTime: 8,
            roundStartSound: .fanfare,
            restStartSound: .chime,
            roundWarningSound: .beep,
            restWarningSound: .beep,
            workoutCompleteSound: .complete
        )

        // When: Duplicate the preset
        let duplicateName = String.localizedStringWithFormat(String(localized: "preset.duplicate_name"), original.name)
        let duplicate = WorkoutPreset(
            name: duplicateName,
            roundDuration: original.roundDuration,
            restDuration: original.restDuration,
            numberOfRounds: original.numberOfRounds,
            roundWarningTime: original.roundWarningTime,
            restWarningTime: original.restWarningTime,
            roundStartSound: original.roundStartSound,
            restStartSound: original.restStartSound,
            roundWarningSound: original.roundWarningSound,
            restWarningSound: original.restWarningSound,
            workoutCompleteSound: original.workoutCompleteSound
        )

        // Then: Verify all properties are copied
        XCTAssertTrue(duplicate.name.contains("Original Workout"))
        XCTAssertEqual(duplicate.roundDuration, 150)
        XCTAssertEqual(duplicate.restDuration, 50)
        XCTAssertEqual(duplicate.numberOfRounds, 4)
        XCTAssertEqual(duplicate.roundWarningTime, 12)
        XCTAssertEqual(duplicate.restWarningTime, 8)
        XCTAssertEqual(duplicate.roundStartSound, .fanfare)
        XCTAssertEqual(duplicate.restStartSound, .chime)
        XCTAssertEqual(duplicate.roundWarningSound, .beep)
        XCTAssertEqual(duplicate.restWarningSound, .beep)
        XCTAssertEqual(duplicate.workoutCompleteSound, .complete)
    }

    func testDuplicatePresetHasDifferentID() throws {
        // Given: An existing preset
        let original = WorkoutPreset(name: "Original", from: model)

        // When: Duplicate the preset
        let duplicateName = String.localizedStringWithFormat(String(localized: "preset.duplicate_name"), original.name)
        let duplicate = WorkoutPreset(
            name: duplicateName,
            roundDuration: original.roundDuration,
            restDuration: original.restDuration,
            numberOfRounds: original.numberOfRounds,
            roundWarningTime: original.roundWarningTime,
            restWarningTime: original.restWarningTime,
            roundStartSound: original.roundStartSound,
            restStartSound: original.restStartSound,
            roundWarningSound: original.roundWarningSound,
            restWarningSound: original.restWarningSound,
            workoutCompleteSound: original.workoutCompleteSound
        )

        // Then: IDs should be different
        XCTAssertNotEqual(original.id, duplicate.id)
    }

    func testDuplicatePresetCopiesUniformConfiguration() throws {
        // Given: Preset with uniform configuration
        let original = WorkoutPreset(name: "Uniform Original", from: model)
        original.roundsConfiguration = .uniform(roundDuration: 120, restDuration: 40, count: 5)

        // When: Duplicate the preset
        let duplicateName = String.localizedStringWithFormat(String(localized: "preset.duplicate_name"), original.name)
        let duplicate = WorkoutPreset(
            name: duplicateName,
            roundDuration: original.roundDuration,
            restDuration: original.restDuration,
            numberOfRounds: original.numberOfRounds,
            roundWarningTime: original.roundWarningTime,
            restWarningTime: original.restWarningTime,
            roundStartSound: original.roundStartSound,
            restStartSound: original.restStartSound,
            roundWarningSound: original.roundWarningSound,
            restWarningSound: original.restWarningSound,
            workoutCompleteSound: original.workoutCompleteSound
        )
        duplicate.roundsConfiguration = original.roundsConfiguration

        // Then: Configuration should be copied
        if case .uniform(let roundDuration, let restDuration, let count) = duplicate.roundsConfiguration {
            XCTAssertEqual(roundDuration, 120)
            XCTAssertEqual(restDuration, 40)
            XCTAssertEqual(count, 5)
        } else {
            XCTFail("Expected uniform configuration")
        }
    }

    func testDuplicatePresetCopiesIndividualConfiguration() throws {
        // Given: Preset with individual configuration
        let original = WorkoutPreset(name: "Individual Original", from: model)
        let rounds = [
            RoundConfiguration(roundDuration: 90, restDuration: 30),
            RoundConfiguration(roundDuration: 150, restDuration: 50),
            RoundConfiguration(roundDuration: 180, restDuration: 60)
        ]
        original.roundsConfiguration = .individual(rounds: rounds)

        // When: Duplicate the preset
        let duplicateName = String.localizedStringWithFormat(String(localized: "preset.duplicate_name"), original.name)
        let duplicate = WorkoutPreset(
            name: duplicateName,
            roundDuration: original.roundDuration,
            restDuration: original.restDuration,
            numberOfRounds: original.numberOfRounds,
            roundWarningTime: original.roundWarningTime,
            restWarningTime: original.restWarningTime,
            roundStartSound: original.roundStartSound,
            restStartSound: original.restStartSound,
            roundWarningSound: original.roundWarningSound,
            restWarningSound: original.restWarningSound,
            workoutCompleteSound: original.workoutCompleteSound
        )
        duplicate.roundsConfiguration = original.roundsConfiguration

        // Then: Individual rounds should be copied
        if case .individual(let duplicateRounds) = duplicate.roundsConfiguration {
            XCTAssertEqual(duplicateRounds.count, 3)
            XCTAssertEqual(duplicateRounds[0].roundDuration, 90)
            XCTAssertEqual(duplicateRounds[0].restDuration, 30)
            XCTAssertEqual(duplicateRounds[1].roundDuration, 150)
            XCTAssertEqual(duplicateRounds[1].restDuration, 50)
            XCTAssertEqual(duplicateRounds[2].roundDuration, 180)
            XCTAssertEqual(duplicateRounds[2].restDuration, 60)
        } else {
            XCTFail("Expected individual configuration")
        }
    }

    func testMultipleDuplicatesOfSamePreset() throws {
        // Given: An original preset
        let original = WorkoutPreset(name: "Master", from: model)
        modelContext.insert(original)
        try modelContext.save()

        // When: Create multiple duplicates
        for _ in 1...3 {
            let duplicateName = String.localizedStringWithFormat(String(localized: "preset.duplicate_name"), original.name)
            let duplicate = WorkoutPreset(
                name: duplicateName,
                roundDuration: original.roundDuration,
                restDuration: original.restDuration,
                numberOfRounds: original.numberOfRounds,
                roundWarningTime: original.roundWarningTime,
                restWarningTime: original.restWarningTime,
                roundStartSound: original.roundStartSound,
                restStartSound: original.restStartSound,
                roundWarningSound: original.roundWarningSound,
                restWarningSound: original.restWarningSound,
                workoutCompleteSound: original.workoutCompleteSound
            )
            duplicate.roundsConfiguration = original.roundsConfiguration
            modelContext.insert(duplicate)
        }
        try modelContext.save()

        // Then: Should have 4 total presets (1 original + 3 duplicates)
        let fetchDescriptor = FetchDescriptor<WorkoutPreset>()
        let presets = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(presets.count, 4)
    }

    // MARK: - Preset Name Localization Tests

    func testDuplicateNameIsLocalized() throws {
        // Given: Original preset name
        let originalName = "Test Workout"

        // When: Generate duplicate name
        let duplicateName = String.localizedStringWithFormat(String(localized: "preset.duplicate_name"), originalName)

        // Then: Name should contain original and indicate it's a copy
        XCTAssertTrue(duplicateName.contains(originalName))
        // Should contain either "(Copy)" or "(Копия)" depending on locale
        XCTAssertTrue(duplicateName.contains("Copy") || duplicateName.contains("Копия"))
    }

    // MARK: - Integration Tests

    func testCreateAndLoadPreset() throws {
        // Given: Model with specific settings
        model.roundDuration = 200
        model.restDuration = 70
        model.numberOfRounds = 6

        // When: Create preset, save it, and load it back
        let preset = WorkoutPreset(name: "Integration Test", from: model)
        modelContext.insert(preset)
        try modelContext.save()

        // Reset model
        model = BoxingTimerModel()
        XCTAssertEqual(model.roundDuration, 180) // Default value

        // Load preset
        preset.apply(to: model)

        // Then: Model should have preset values
        XCTAssertEqual(model.roundDuration, 200)
        XCTAssertEqual(model.restDuration, 70)
        XCTAssertEqual(model.numberOfRounds, 6)
        XCTAssertEqual(model.currentPresetName, "Integration Test")
    }

    func testDuplicatePresetCanBeLoadedIndependently() throws {
        // Given: Original preset
        model.roundDuration = 100
        let original = WorkoutPreset(name: "Original", from: model)
        modelContext.insert(original)

        // When: Duplicate and modify duplicate's values
        let duplicateName = String.localizedStringWithFormat(String(localized: "preset.duplicate_name"), original.name)
        let duplicate = WorkoutPreset(
            name: duplicateName,
            roundDuration: 200, // Different from original
            restDuration: original.restDuration,
            numberOfRounds: original.numberOfRounds,
            roundWarningTime: original.roundWarningTime,
            restWarningTime: original.restWarningTime,
            roundStartSound: original.roundStartSound,
            restStartSound: original.restStartSound,
            roundWarningSound: original.roundWarningSound,
            restWarningSound: original.restWarningSound,
            workoutCompleteSound: original.workoutCompleteSound
        )
        modelContext.insert(duplicate)
        try modelContext.save()

        // Then: Loading each preset should give different values
        original.apply(to: model)
        XCTAssertEqual(model.roundDuration, 100)

        duplicate.apply(to: model)
        XCTAssertEqual(model.roundDuration, 200)
    }

    // MARK: - Edge Cases

    func testCreatePresetWithVeryLongName() throws {
        // Given: Very long name
        let longName = String(repeating: "a", count: 1000)

        // When: Create preset
        let preset = WorkoutPreset(name: longName, from: model)

        // Then: Should handle gracefully
        XCTAssertEqual(preset.name.count, 1000)
    }

    func testCreatePresetWithSpecialCharacters() throws {
        // Given: Name with special characters
        let specialName = "🥊 Boxing! @#$%^&*() 漢字"

        // When: Create preset
        let preset = WorkoutPreset(name: specialName, from: model)
        modelContext.insert(preset)
        try modelContext.save()

        // Then: Should persist correctly
        let fetchDescriptor = FetchDescriptor<WorkoutPreset>()
        let presets = try modelContext.fetch(fetchDescriptor)
        XCTAssertEqual(presets.first?.name, specialName)
    }
}
