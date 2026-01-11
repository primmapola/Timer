//
//  ModelContainer+Preview.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftData

extension ModelContainer {
    static func previewContainer(configurations: ModelConfiguration) -> ModelContainer {
        do {
            return try ModelContainer(for: WorkoutPreset.self, configurations: configurations)
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
