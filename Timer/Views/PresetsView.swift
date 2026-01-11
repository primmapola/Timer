//
//  PresetsView.swift
//  Timer
//
//  Created by Grigory Don on 11.01.2026.
//

import SwiftUI
import SwiftData

struct PresetsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutPreset.createdAt, order: .reverse) private var presets: [WorkoutPreset]

    @Bindable var model: BoxingTimerModel
    @State private var showingDeleteAlert = false
    @State private var presetToDelete: WorkoutPreset?

    var body: some View {
        NavigationStack {
            Group {
                if presets.isEmpty {
                    emptyState
                } else {
                    presetsList
                }
            }
            .navigationTitle("Мои тренировки")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .alert("Удалить тренировку?", isPresented: $showingDeleteAlert, presenting: presetToDelete) { preset in
                Button("Удалить", role: .destructive) {
                    deletePreset(preset)
                }
                Button("Отмена", role: .cancel) {}
            } message: { preset in
                Text("Вы уверены, что хотите удалить тренировку \"\(preset.name)\"?")
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Нет сохраненных тренировок", systemImage: "timer")
        } description: {
            Text("Создайте первую тренировку в настройках")
        }
    }

    private var presetsList: some View {
        List {
            ForEach(presets) { preset in
                Button {
                    loadPreset(preset)
                } label: {
                    PresetRow(preset: preset)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        presetToDelete = preset
                        showingDeleteAlert = true
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func loadPreset(_ preset: WorkoutPreset) {
        preset.apply(to: model)
        dismiss()
    }

    private func deletePreset(_ preset: WorkoutPreset) {
        modelContext.delete(preset)
        try? modelContext.save()
    }
}

struct PresetRow: View {
    let preset: WorkoutPreset

    private var totalDuration: TimeInterval {
        Double(preset.numberOfRounds) * preset.roundDuration +
        Double(max(0, preset.numberOfRounds - 1)) * preset.restDuration
    }

    private var gradientColors: [Color] {
        [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Заголовок с градиентом
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)

                    Text("Всего: \(formatTotalTime(totalDuration))")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }

                Spacer()

                // Бейдж с количеством раундов
                VStack(spacing: 2) {
                    Text("\(preset.numberOfRounds)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("раундов")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.2))
                )
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Детали тренировки
            HStack(spacing: 0) {
                // Раунд
                VStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.title3)
                        .foregroundStyle(.green)
                    Text("Раунд")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatTime(preset.roundDuration))
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 40)

                // Отдых
                VStack(spacing: 6) {
                    Image(systemName: "pause.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                    Text("Отдых")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatTime(preset.restDuration))
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if minutes > 0 {
            return "\(minutes):\(twoDigitString(secs))"
        }
        return "\(secs) сек"
    }

    private func formatTotalTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        if minutes > 0 {
            return "\(minutes) мин \(secs) сек"
        }
        return "\(secs) сек"
    }

    private func twoDigitString(_ value: Int) -> String {
        value.formatted(.number.precision(.integerLength(2)).grouping(.never))
    }
}

#Preview("With Presets") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = ModelContainer.previewContainer(configurations: config)

    let model = BoxingTimerModel()

    // Add sample presets
    let preset1 = WorkoutPreset(
        name: "Легкая тренировка",
        roundDuration: 120,
        restDuration: 60,
        numberOfRounds: 3,
        roundWarningTime: 10,
        restWarningTime: 5,
        roundStartSound: .bell,
        restStartSound: .beep,
        roundWarningSound: .beep,
        restWarningSound: .beep,
        workoutCompleteSound: .complete
    )
    let preset2 = WorkoutPreset(
        name: "Интенсивная тренировка",
        roundDuration: 180,
        restDuration: 45,
        numberOfRounds: 5,
        roundWarningTime: 15,
        restWarningTime: 10,
        roundStartSound: .fanfare,
        restStartSound: .chime,
        roundWarningSound: .beep,
        restWarningSound: .beep,
        workoutCompleteSound: .complete
    )

    container.mainContext.insert(preset1)
    container.mainContext.insert(preset2)

    return PresetsView(model: model)
        .modelContainer(container)
}

#Preview("Empty") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = ModelContainer.previewContainer(configurations: config)
    let model = BoxingTimerModel()

    return PresetsView(model: model)
        .modelContainer(container)
}
