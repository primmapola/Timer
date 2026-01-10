//
//  TimerApp.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI
import SwiftData

@main
struct TimerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WorkoutPreset.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            BoxingTimerView()
        }
        .modelContainer(sharedModelContainer)
    }
}
