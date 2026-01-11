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
    @State private var showingCreatePresetAlert = false
    @State private var newPresetName = ""

    var body: some View {
        NavigationStack {
            Group {
                if presets.isEmpty {
                    emptyState
                } else {
                    presetsList
                }
            }
            .navigationTitle("presets.title")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("button.close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreatePresetAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .symbolEffect(.bounce, value: presets.count)
                }
            }
            .alert("alert.delete_preset.title", isPresented: $showingDeleteAlert, presenting: presetToDelete) { preset in
                Button("alert.delete", role: .destructive) {
                    deletePreset(preset)
                }
                Button("alert.cancel", role: .cancel) {}
            } message: { preset in
                Text(String.localizedStringWithFormat(String(localized: "alert.delete_preset.message"), preset.name))
            }
            .alert("alert.create_preset.title", isPresented: $showingCreatePresetAlert) {
                TextField("alert.create_preset.placeholder", text: $newPresetName)
                Button("alert.save") {
                    createNewPreset()
                }
                Button("alert.cancel", role: .cancel) {
                    newPresetName = ""
                }
            } message: {
                Text("alert.create_preset.message")
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("empty_state.title", systemImage: "timer")
        } description: {
            Text("empty_state.description")
        }
        .transition(.scale.combined(with: .opacity))
    }

    private var presetsList: some View {
        List {
            ForEach(presets) { preset in
                PresetButton(preset: preset, action: {
                    loadPreset(preset)
                })
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .top)),
                    removal: .scale(scale: 0.8).combined(with: .opacity).combined(with: .move(edge: .trailing))
                ))
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        presetToDelete = preset
                        showingDeleteAlert = true
                    } label: {
                        Label("alert.delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            duplicatePreset(preset)
                        }
                    } label: {
                        Label("preset.duplicate", systemImage: "doc.on.doc")
                    }
                    .tint(.blue)

                    // Показываем кнопку обновления только для текущего загруженного пресета
                    if model.currentPresetId == preset.id {
                        Button {
                            updatePreset(preset)
                        } label: {
                            Label("preset.update", systemImage: "arrow.triangle.2.circlepath")
                        }
                        .tint(.green)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: presets.count)
    }

    private func loadPreset(_ preset: WorkoutPreset) {
        preset.apply(to: model)
        dismiss()
    }

    private func deletePreset(_ preset: WorkoutPreset) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
            modelContext.delete(preset)
            try? modelContext.save()
        }
    }

    private func createNewPreset() {
        guard !newPresetName.isEmpty else { return }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            let newPreset = WorkoutPreset(name: newPresetName, from: model)
            modelContext.insert(newPreset)
            try? modelContext.save()
        }

        newPresetName = ""
    }

    private func duplicatePreset(_ preset: WorkoutPreset) {
        let duplicateName = String.localizedStringWithFormat(String(localized: "preset.duplicate_name"), preset.name)

        let duplicatePreset = WorkoutPreset(
            name: duplicateName,
            roundDuration: preset.roundDuration,
            restDuration: preset.restDuration,
            numberOfRounds: preset.numberOfRounds,
            roundWarningTime: preset.roundWarningTime,
            restWarningTime: preset.restWarningTime,
            roundStartSound: preset.roundStartSound,
            restStartSound: preset.restStartSound,
            roundWarningSound: preset.roundWarningSound,
            restWarningSound: preset.restWarningSound,
            workoutCompleteSound: preset.workoutCompleteSound
        )
        // Copy rounds configuration
        duplicatePreset.roundsConfiguration = preset.roundsConfiguration

        modelContext.insert(duplicatePreset)
        try? modelContext.save()
    }

    private func updatePreset(_ preset: WorkoutPreset) {
        preset.update(from: model)
        try? modelContext.save()
    }
}

struct PresetRow: View {
    let preset: WorkoutPreset

    private var totalDuration: TimeInterval {
        preset.roundsConfiguration.totalDuration
    }

    private var gradientColors: [Color] {
        switch preset.roundsConfiguration {
        case .uniform:
            return [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]
        case .individual:
            return [Color.orange.opacity(0.6), Color.pink.opacity(0.6)]
        }
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

                    Text(String.localizedStringWithFormat(String(localized: "preset.row.total"), formatTotalTime(totalDuration)))
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }

                Spacer()

                // Бейдж с количеством раундов
                VStack(spacing: 2) {
                    Text("\(preset.roundsConfiguration.numberOfRounds)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("preset.row.rounds")
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

            // Детали тренировки - разные для uniform и individual
            switch preset.roundsConfiguration {
            case .uniform(let roundDuration, let restDuration, _):
                uniformDetailsView(roundDuration: roundDuration, restDuration: restDuration)
            case .individual(let rounds):
                individualDetailsView(rounds: rounds)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func uniformDetailsView(roundDuration: TimeInterval, restDuration: TimeInterval) -> some View {
        HStack(spacing: 0) {
            // Раунд
            VStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.title3)
                    .foregroundStyle(.green)
                Text("preset.detail.round")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatTime(roundDuration))
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
                Text("preset.detail.rest")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formatTime(restDuration))
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }

    @ViewBuilder
    private func individualDetailsView(rounds: [RoundConfiguration]) -> some View {
        VStack(spacing: 12) {
            // Индикатор индивидуальной конфигурации
            HStack {
                Image(systemName: "list.bullet.circle.fill")
                    .foregroundStyle(.orange)
                Text("preset.detail.individual_rounds")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Показываем диапазоны длительности
            HStack(spacing: 0) {
                // Диапазон раундов
                VStack(spacing: 6) {
                    Image(systemName: "timer")
                        .font(.title3)
                        .foregroundStyle(.green)
                    Text("preset.detail.round")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatDurationRange(rounds.map { $0.roundDuration }))
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 40)

                // Диапазон отдыха
                VStack(spacing: 6) {
                    Image(systemName: "pause.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.blue)
                    Text("preset.detail.rest")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatDurationRange(rounds.map { $0.restDuration }))
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
    }

    private func formatDurationRange(_ durations: [TimeInterval]) -> String {
        guard !durations.isEmpty else { return "-" }

        let minDuration = durations.min() ?? 0
        let maxDuration = durations.max() ?? 0

        if minDuration == maxDuration {
            return formatTime(minDuration)
        } else {
            return "\(formatTime(minDuration)) - \(formatTime(maxDuration))"
        }
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

// Кнопка пресета с анимацией нажатия
struct PresetButton: View {
    let preset: WorkoutPreset
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            PresetRow(preset: preset)
        }
        .buttonStyle(ScaleButtonStyle(isPressed: $isPressed))
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}

// Custom button style для обработки нажатия
struct ScaleButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
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

    // Add preset with individual rounds
    let preset3 = WorkoutPreset(
        name: "Пирамида",
        roundDuration: 120,
        restDuration: 60,
        numberOfRounds: 5,
        roundWarningTime: 10,
        restWarningTime: 5,
        roundStartSound: .bell,
        restStartSound: .beep,
        roundWarningSound: .beep,
        restWarningSound: .beep,
        workoutCompleteSound: .complete
    )
    // Configure individual rounds with increasing durations
    preset3.roundsConfiguration = .individual(rounds: [
        RoundConfiguration(roundDuration: 60, restDuration: 30),
        RoundConfiguration(roundDuration: 120, restDuration: 45),
        RoundConfiguration(roundDuration: 180, restDuration: 60),
        RoundConfiguration(roundDuration: 120, restDuration: 45),
        RoundConfiguration(roundDuration: 60, restDuration: 30)
    ])

    container.mainContext.insert(preset1)
    container.mainContext.insert(preset2)
    container.mainContext.insert(preset3)

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
