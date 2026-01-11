//
//  PresetOrdering.swift
//  Timer
//
//  Created by Grigory Don on 11.01.2026.
//

import Foundation

struct PresetOrdering {
    static func duplicateInsertionDate(for preset: WorkoutPreset, in presets: [WorkoutPreset]) -> Date {
        guard let index = presets.firstIndex(where: { $0.id == preset.id }) else {
            return preset.createdAt.addingTimeInterval(-1)
        }

        let nextIndex = presets.index(after: index)
        guard nextIndex < presets.endIndex else {
            return preset.createdAt.addingTimeInterval(-1)
        }

        let nextPreset = presets[nextIndex]
        let interval = preset.createdAt.timeIntervalSince(nextPreset.createdAt)
        guard interval > 0 else {
            return preset.createdAt.addingTimeInterval(-1)
        }

        return preset.createdAt.addingTimeInterval(-interval / 2)
    }
}
