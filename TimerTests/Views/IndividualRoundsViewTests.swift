//
//  IndividualRoundsViewTests.swift
//  TimerTests
//
//  Created by Claude on 11.01.2026.
//

import XCTest
import SwiftUI
@testable import Timer

@MainActor
final class IndividualRoundsViewTests: XCTestCase {

    // MARK: - Round Duplication Tests

    func testRoundDuplication_CreatesNewRoundWithSameValues() {
        // Given
        let originalRound = RoundConfiguration(
            roundDuration: 180,
            restDuration: 60,
            roundWarningTime: 10,
            restWarningTime: 5
        )
        var rounds = [originalRound]

        // When
        let duplicatedRound = RoundConfiguration(
            roundDuration: originalRound.roundDuration,
            restDuration: originalRound.restDuration,
            roundWarningTime: originalRound.roundWarningTime,
            restWarningTime: originalRound.restWarningTime
        )
        rounds.insert(duplicatedRound, at: 1)

        // Then
        XCTAssertEqual(rounds.count, 2)
        XCTAssertEqual(rounds[0].roundDuration, rounds[1].roundDuration)
        XCTAssertEqual(rounds[0].restDuration, rounds[1].restDuration)
        XCTAssertEqual(rounds[0].roundWarningTime, rounds[1].roundWarningTime)
        XCTAssertEqual(rounds[0].restWarningTime, rounds[1].restWarningTime)
    }

    func testRoundDuplication_CreatesUniqueID() {
        // Given
        let originalRound = RoundConfiguration(
            roundDuration: 180,
            restDuration: 60
        )
        var rounds = [originalRound]

        // When
        let duplicatedRound = RoundConfiguration(
            roundDuration: originalRound.roundDuration,
            restDuration: originalRound.restDuration
        )
        rounds.insert(duplicatedRound, at: 1)

        // Then
        XCTAssertNotEqual(rounds[0].id, rounds[1].id, "Duplicated round must have a unique ID")
    }

    func testRoundDuplication_InsertsAtCorrectPosition() {
        // Given
        let round1 = RoundConfiguration(roundDuration: 100, restDuration: 50)
        let round2 = RoundConfiguration(roundDuration: 200, restDuration: 60)
        let round3 = RoundConfiguration(roundDuration: 300, restDuration: 70)
        var rounds = [round1, round2, round3]

        // When - duplicate round at index 1
        let duplicatedRound = RoundConfiguration(
            roundDuration: round2.roundDuration,
            restDuration: round2.restDuration
        )
        rounds.insert(duplicatedRound, at: 2)

        // Then
        XCTAssertEqual(rounds.count, 4)
        XCTAssertEqual(rounds[0].roundDuration, 100)
        XCTAssertEqual(rounds[1].roundDuration, 200)
        XCTAssertEqual(rounds[2].roundDuration, 200) // Duplicated
        XCTAssertEqual(rounds[3].roundDuration, 300)
    }

    // MARK: - Round Editing Tests

    func testRoundEditing_UpdatesCorrectRound() {
        // Given
        var rounds = [
            RoundConfiguration(roundDuration: 180, restDuration: 60),
            RoundConfiguration(roundDuration: 180, restDuration: 60),
            RoundConfiguration(roundDuration: 180, restDuration: 60)
        ]
        let targetRoundId = rounds[1].id

        // When
        if let index = rounds.firstIndex(where: { $0.id == targetRoundId }) {
            rounds[index].roundDuration = 240
            rounds[index].restDuration = 90
        }

        // Then
        XCTAssertEqual(rounds[1].roundDuration, 240)
        XCTAssertEqual(rounds[1].restDuration, 90)
        // Other rounds should remain unchanged
        XCTAssertEqual(rounds[0].roundDuration, 180)
        XCTAssertEqual(rounds[2].roundDuration, 180)
    }

    func testRoundEditing_AfterDuplication_UpdatesCorrectRound() {
        // Given - simulate duplication
        let originalRound = RoundConfiguration(roundDuration: 180, restDuration: 60)
        var rounds = [originalRound]

        let duplicatedRound = RoundConfiguration(
            roundDuration: originalRound.roundDuration,
            restDuration: originalRound.restDuration
        )
        rounds.insert(duplicatedRound, at: 1)

        let originalId = rounds[0].id
        let duplicatedId = rounds[1].id

        // When - edit the original round
        if let index = rounds.firstIndex(where: { $0.id == originalId }) {
            rounds[index].roundDuration = 240
        }

        // Then
        XCTAssertEqual(rounds[0].roundDuration, 240, "Original round should be updated")
        XCTAssertEqual(rounds[1].roundDuration, 180, "Duplicated round should remain unchanged")
        XCTAssertNotEqual(rounds[0].id, rounds[1].id, "IDs must remain unique")
    }

    func testRoundEditing_AfterDuplication_UpdatesDuplicatedRound() {
        // Given - simulate duplication
        let originalRound = RoundConfiguration(roundDuration: 180, restDuration: 60)
        var rounds = [originalRound]

        let duplicatedRound = RoundConfiguration(
            roundDuration: originalRound.roundDuration,
            restDuration: originalRound.restDuration
        )
        rounds.insert(duplicatedRound, at: 1)

        let duplicatedId = rounds[1].id

        // When - edit the duplicated round
        if let index = rounds.firstIndex(where: { $0.id == duplicatedId }) {
            rounds[index].roundDuration = 300
            rounds[index].restDuration = 75
        }

        // Then
        XCTAssertEqual(rounds[0].roundDuration, 180, "Original round should remain unchanged")
        XCTAssertEqual(rounds[1].roundDuration, 300, "Duplicated round should be updated")
        XCTAssertEqual(rounds[1].restDuration, 75)
    }

    // MARK: - Round Warning Time Tests

    func testRoundWarningTime_TogglesCorrectly() {
        // Given
        var round = RoundConfiguration(roundDuration: 180, restDuration: 60)
        XCTAssertNil(round.roundWarningTime)

        // When - enable warning
        round.roundWarningTime = 10

        // Then
        XCTAssertEqual(round.roundWarningTime, 10)

        // When - disable warning
        round.roundWarningTime = nil

        // Then
        XCTAssertNil(round.roundWarningTime)
    }

    func testRestWarningTime_TogglesCorrectly() {
        // Given
        var round = RoundConfiguration(roundDuration: 180, restDuration: 60)
        XCTAssertNil(round.restWarningTime)

        // When - enable warning
        round.restWarningTime = 5

        // Then
        XCTAssertEqual(round.restWarningTime, 5)

        // When - disable warning
        round.restWarningTime = nil

        // Then
        XCTAssertNil(round.restWarningTime)
    }

    func testWarningTime_AfterDuplication_IsCopiedCorrectly() {
        // Given
        let originalRound = RoundConfiguration(
            roundDuration: 180,
            restDuration: 60,
            roundWarningTime: 15,
            restWarningTime: 8
        )
        var rounds = [originalRound]

        // When
        let duplicatedRound = RoundConfiguration(
            roundDuration: originalRound.roundDuration,
            restDuration: originalRound.restDuration,
            roundWarningTime: originalRound.roundWarningTime,
            restWarningTime: originalRound.restWarningTime
        )
        rounds.insert(duplicatedRound, at: 1)

        // Then
        XCTAssertEqual(rounds[1].roundWarningTime, 15)
        XCTAssertEqual(rounds[1].restWarningTime, 8)
    }

    // MARK: - ID Stability Tests

    func testRoundID_RemainsStableAfterEditing() {
        // Given
        var round = RoundConfiguration(roundDuration: 180, restDuration: 60)
        let originalId = round.id

        // When
        round.roundDuration = 240
        round.restDuration = 90
        round.roundWarningTime = 10
        round.restWarningTime = 5

        // Then
        XCTAssertEqual(round.id, originalId, "Round ID must remain stable after editing")
    }

    func testRoundID_IsUniqueForEachRound() {
        // Given
        let rounds = [
            RoundConfiguration(roundDuration: 180, restDuration: 60),
            RoundConfiguration(roundDuration: 180, restDuration: 60),
            RoundConfiguration(roundDuration: 180, restDuration: 60)
        ]

        // Then
        let ids = rounds.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count, "All round IDs must be unique")
    }

    func testRoundID_FindingByID_ReturnsCorrectRound() {
        // Given
        let round1 = RoundConfiguration(roundDuration: 100, restDuration: 50)
        let round2 = RoundConfiguration(roundDuration: 200, restDuration: 60)
        let round3 = RoundConfiguration(roundDuration: 300, restDuration: 70)
        let rounds = [round1, round2, round3]

        // When
        let targetId = round2.id
        let foundIndex = rounds.firstIndex(where: { $0.id == targetId })

        // Then
        XCTAssertNotNil(foundIndex)
        XCTAssertEqual(foundIndex, 1)
        XCTAssertEqual(rounds[foundIndex!].roundDuration, 200)
    }

    // MARK: - Multiple Duplication Tests

    func testMultipleDuplication_MaintainsCorrectOrder() {
        // Given
        let round1 = RoundConfiguration(roundDuration: 100, restDuration: 50)
        var rounds = [round1]

        // When - duplicate multiple times
        let dup1 = RoundConfiguration(
            roundDuration: round1.roundDuration,
            restDuration: round1.restDuration
        )
        rounds.insert(dup1, at: 1)

        let dup2 = RoundConfiguration(
            roundDuration: round1.roundDuration,
            restDuration: round1.restDuration
        )
        rounds.insert(dup2, at: 2)

        // Then
        XCTAssertEqual(rounds.count, 3)
        XCTAssertEqual(rounds[0].roundDuration, 100)
        XCTAssertEqual(rounds[1].roundDuration, 100)
        XCTAssertEqual(rounds[2].roundDuration, 100)

        // All IDs should be unique
        let ids = rounds.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count)
    }

    func testMultipleDuplication_EditingOneDoesNotAffectOthers() {
        // Given
        let originalRound = RoundConfiguration(roundDuration: 180, restDuration: 60)
        var rounds = [originalRound]

        let dup1 = RoundConfiguration(
            roundDuration: originalRound.roundDuration,
            restDuration: originalRound.restDuration
        )
        rounds.insert(dup1, at: 1)

        let dup2 = RoundConfiguration(
            roundDuration: originalRound.roundDuration,
            restDuration: originalRound.restDuration
        )
        rounds.insert(dup2, at: 2)

        let targetId = rounds[1].id

        // When - edit middle round
        if let index = rounds.firstIndex(where: { $0.id == targetId }) {
            rounds[index].roundDuration = 500
        }

        // Then
        XCTAssertEqual(rounds[0].roundDuration, 180)
        XCTAssertEqual(rounds[1].roundDuration, 500)
        XCTAssertEqual(rounds[2].roundDuration, 180)
    }

    // MARK: - RoundsConfigurationMode Tests

    func testIndividualMode_ReturnsCorrectRounds() {
        // Given
        let rounds = [
            RoundConfiguration(roundDuration: 100, restDuration: 50),
            RoundConfiguration(roundDuration: 200, restDuration: 60),
            RoundConfiguration(roundDuration: 300, restDuration: 70)
        ]
        let config = RoundsConfigurationMode.individual(rounds: rounds)

        // Then
        XCTAssertEqual(config.numberOfRounds, 3)
        XCTAssertEqual(config.rounds.count, 3)
        XCTAssertEqual(config.rounds[0].roundDuration, 100)
        XCTAssertEqual(config.rounds[1].roundDuration, 200)
        XCTAssertEqual(config.rounds[2].roundDuration, 300)
    }

    func testIndividualMode_GetConfigurationForRound() {
        // Given
        let rounds = [
            RoundConfiguration(roundDuration: 100, restDuration: 50),
            RoundConfiguration(roundDuration: 200, restDuration: 60),
            RoundConfiguration(roundDuration: 300, restDuration: 70)
        ]
        let config = RoundsConfigurationMode.individual(rounds: rounds)

        // When
        let round1Config = config.configuration(forRound: 1)
        let round2Config = config.configuration(forRound: 2)
        let round3Config = config.configuration(forRound: 3)

        // Then
        XCTAssertNotNil(round1Config)
        XCTAssertEqual(round1Config?.roundDuration, 100)
        XCTAssertEqual(round2Config?.roundDuration, 200)
        XCTAssertEqual(round3Config?.roundDuration, 300)
    }

    func testIndividualMode_TotalDuration() {
        // Given
        let rounds = [
            RoundConfiguration(roundDuration: 180, restDuration: 60),
            RoundConfiguration(roundDuration: 180, restDuration: 60),
            RoundConfiguration(roundDuration: 180, restDuration: 60)
        ]
        let config = RoundsConfigurationMode.individual(rounds: rounds)

        // When
        let totalDuration = config.totalDuration

        // Then
        // (180 + 60) + (180 + 60) + (180) = 660 (last rest is excluded)
        XCTAssertEqual(totalDuration, 660)
    }

    // MARK: - Edge Cases

    func testEmptyRoundsArray() {
        // Given
        let rounds: [RoundConfiguration] = []
        let config = RoundsConfigurationMode.individual(rounds: rounds)

        // Then
        XCTAssertEqual(config.numberOfRounds, 0)
        XCTAssertEqual(config.totalDuration, 0)
    }

    func testSingleRound() {
        // Given
        let rounds = [RoundConfiguration(roundDuration: 180, restDuration: 60)]
        let config = RoundsConfigurationMode.individual(rounds: rounds)

        // Then
        XCTAssertEqual(config.numberOfRounds, 1)
        XCTAssertEqual(config.totalDuration, 180) // Rest duration excluded for last round
    }

    func testRoundConfiguration_Equatable() {
        // Given
        let round1 = RoundConfiguration(
            id: UUID(),
            roundDuration: 180,
            restDuration: 60,
            roundWarningTime: 10,
            restWarningTime: 5
        )
        let round2 = RoundConfiguration(
            id: round1.id,
            roundDuration: 180,
            restDuration: 60,
            roundWarningTime: 10,
            restWarningTime: 5
        )
        let round3 = RoundConfiguration(
            id: UUID(),
            roundDuration: 180,
            restDuration: 60,
            roundWarningTime: 10,
            restWarningTime: 5
        )

        // Then
        XCTAssertEqual(round1, round2, "Rounds with same ID and values should be equal")
        XCTAssertNotEqual(round1, round3, "Rounds with different IDs should not be equal")
    }
}
