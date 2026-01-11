//
//  SettingsView.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI
import SwiftData
import AVFoundation

enum SettingRow: Hashable {
    case numberOfRounds
    case restWarning
    case roundStartSound
    case restStartSound
    case roundWarningSound
    case restWarningSound
    case workoutCompleteSound
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var model: BoxingTimerModel

    @State private var draftRoundConfigurations: [RoundConfiguration]
    @State private var draftNumberOfRounds: Int
    @State private var restWarningSeconds: Int
    @State private var expandedRow: SettingRow?
    @State private var expandedRoundIndex: Int?
    @State private var showingSavePreset = false
    @State private var presetName = ""

    init(model: BoxingTimerModel) {
        self.model = model
        _draftRoundConfigurations = State(initialValue: model.roundConfigurations)
        _draftNumberOfRounds = State(initialValue: model.numberOfRounds)
        _restWarningSeconds = State(initialValue: Int(model.restWarningTime))
    }

    var body: some View {
        NavigationStack {
            List {
                // Визуальный preview общего времени
                Section {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(.blue)
                                .font(.title3)
                            Text("Общее время")
                                .font(.headline)
                            Spacer()
                            Text(formatTotalWorkoutTime())
                                .font(.title3.bold().monospacedDigit())
                                .foregroundStyle(.blue)
                        }

                        // Визуальный timeline
                        HStack(spacing: 4) {
                            ForEach(0..<draftNumberOfRounds, id: \.self) { index in
                                VStack(spacing: 2) {
                                    Rectangle()
                                        .fill(.red.opacity(0.7))
                                        .frame(height: 20)

                                    if index < draftNumberOfRounds - 1 {
                                        Rectangle()
                                            .fill(.green.opacity(0.7))
                                            .frame(height: 10)
                                    }
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                        Text(roundSummaryText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                // Быстрые пресеты
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            QuickPresetButton(
                                title: "3 мин",
                                subtitle: "1 мин отдых",
                                icon: "bolt.fill",
                                color: .orange
                            ) {
                                applyQuickPreset(roundMinutes: 3, restMinutes: 1)
                            }

                            QuickPresetButton(
                                title: "5 мин",
                                subtitle: "1 мин отдых",
                                icon: "flame.fill",
                                color: .red
                            ) {
                                applyQuickPreset(roundMinutes: 5, restMinutes: 1)
                            }

                            QuickPresetButton(
                                title: "12 мин",
                                subtitle: "3 мин отдых",
                                icon: "figure.boxing",
                                color: .purple
                            ) {
                                applyQuickPreset(roundMinutes: 12, restMinutes: 3)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                } header: {
                    Text("Быстрые настройки")
                }

                Section {
                    // Количество раундов
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandedRow = expandedRow == .numberOfRounds ? nil : .numberOfRounds
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "repeat.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.title3)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Раунды")
                                    .foregroundStyle(.primary)
                                    .font(.body.weight(.medium))
                                Text("Количество повторений")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\(draftNumberOfRounds)")
                                .foregroundStyle(.blue)
                                .font(.body.bold().monospacedDigit())
                        }
                    }

                    if expandedRow == .numberOfRounds {
                        Picker("Количество раундов", selection: $draftNumberOfRounds) {
                            ForEach(1...20, id: \.self) { round in
                                Text("\(round)")
                                    .tag(round)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    ForEach($draftRoundConfigurations) { configuration in
                        RoundConfigurationRowView(
                            roundNumber: roundNumber(for: configuration.wrappedValue),
                            configuration: configuration,
                            expandedRoundIndex: $expandedRoundIndex
                        )
                    }

                } header: {
                    Text("Раунды")
                }

                Section {
                    // Предупреждение о конце отдыха
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandedRow = expandedRow == .restWarning ? nil : .restWarning
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "bell.badge.fill")
                                .foregroundStyle(.cyan)
                                .font(.title3)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Сигнал паузы")
                                    .foregroundStyle(.primary)
                                    .font(.body.weight(.medium))
                                Text("За \(restWarningSeconds) сек до конца")
                                    .font(.caption)
                                    .foregroundStyle(isRestWarningValid ? Color.secondary : Color.red)
                            }

                            Spacer()

                            Text("\(restWarningSeconds) сек")
                                .foregroundStyle(isRestWarningValid ? .cyan : .red)
                                .font(.body.bold().monospacedDigit())

                            if !isRestWarningValid {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }
                        }
                    }

                    if expandedRow == .restWarning {
                        Picker("Секунды", selection: $restWarningSeconds) {
                            ForEach([3, 5, 10, 15, 20, 30], id: \.self) { sec in
                                Text("\(sec) сек")
                                    .tag(sec)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                } header: {
                    Text("Предупреждения")
                } footer: {
                    if !isRoundWarningValid || !isRestWarningValid {
                        Text("⚠️ Время сигнала не может быть больше или равно длительности периода")
                            .foregroundStyle(.red)
                    }
                }

                // Секция звуков
                Section {
                    // Начало раунда
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandedRow = expandedRow == .roundStartSound ? nil : .roundStartSound
                        }
                    } label: {
                        HStack {
                            Text("Начало раунда")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(model.roundStartSound.name)
                                .foregroundStyle(.secondary)
                                .font(.body)
                        }
                    }

                    if expandedRow == .roundStartSound {
                        SoundPickerView(
                            selectedSound: $model.roundStartSound,
                            onSoundSelected: { sound in
                                AudioServicesPlaySystemSound(sound.rawValue)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    // Начало паузы
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandedRow = expandedRow == .restStartSound ? nil : .restStartSound
                        }
                    } label: {
                        HStack {
                            Text("Начало паузы")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(model.restStartSound.name)
                                .foregroundStyle(.secondary)
                                .font(.body)
                        }
                    }

                    if expandedRow == .restStartSound {
                        SoundPickerView(
                            selectedSound: $model.restStartSound,
                            onSoundSelected: { sound in
                                AudioServicesPlaySystemSound(sound.rawValue)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    // Предупреждение раунда
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandedRow = expandedRow == .roundWarningSound ? nil : .roundWarningSound
                        }
                    } label: {
                        HStack {
                            Text("Сигнал раунда")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(model.roundWarningSound.name)
                                .foregroundStyle(.secondary)
                                .font(.body)
                        }
                    }

                    if expandedRow == .roundWarningSound {
                        SoundPickerView(
                            selectedSound: $model.roundWarningSound,
                            onSoundSelected: { sound in
                                AudioServicesPlaySystemSound(sound.rawValue)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    // Сигнал паузы
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandedRow = expandedRow == .restWarningSound ? nil : .restWarningSound
                        }
                    } label: {
                        HStack {
                            Text("Сигнал паузы")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(model.restWarningSound.name)
                                .foregroundStyle(.secondary)
                                .font(.body)
                        }
                    }

                    if expandedRow == .restWarningSound {
                        SoundPickerView(
                            selectedSound: $model.restWarningSound,
                            onSoundSelected: { sound in
                                AudioServicesPlaySystemSound(sound.rawValue)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    // Завершение тренировки
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandedRow = expandedRow == .workoutCompleteSound ? nil : .workoutCompleteSound
                        }
                    } label: {
                        HStack {
                            Text("Завершение тренировки")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(model.workoutCompleteSound.name)
                                .foregroundStyle(.secondary)
                                .font(.body)
                        }
                    }

                    if expandedRow == .workoutCompleteSound {
                        SoundPickerView(
                            selectedSound: $model.workoutCompleteSound,
                            onSoundSelected: { sound in
                                AudioServicesPlaySystemSound(sound.rawValue)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                } header: {
                    Text("Звуки")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Параметры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSavePreset = true
                    } label: {
                        Label("Сохранить шаблон", systemImage: "square.and.arrow.down")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveSettings()
                        dismiss()
                    } label: {
                        Label("Сохранить", systemImage: "checkmark")
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Сохранить шаблон", isPresented: $showingSavePreset) {
                TextField("Название шаблона", text: $presetName)
                Button("Сохранить") {
                    saveAsPreset()
                }
                Button("Отмена", role: .cancel) {
                    presetName = ""
                }
            } message: {
                Text("Введите название для сохранения параметров")
            }
        }
        .onChange(of: draftNumberOfRounds) { _, newValue in
            draftRoundConfigurations = normalizedRoundConfigurations(for: newValue)
            if let expandedIndex = expandedRoundIndex, expandedIndex > newValue {
                expandedRoundIndex = nil
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var isValid: Bool {
        guard !draftRoundConfigurations.isEmpty else { return false }
        let hasRoundDuration = draftRoundConfigurations.allSatisfy { $0.roundDuration > 0 }
        let hasRestDuration = draftRoundConfigurations.allSatisfy { $0.restDuration > 0 }
        return hasRoundDuration && hasRestDuration && isRoundWarningValid && isRestWarningValid
    }

    private var isRoundWarningValid: Bool {
        draftRoundConfigurations.allSatisfy { $0.roundWarningTime < $0.roundDuration }
    }

    private var isRestWarningValid: Bool {
        guard draftNumberOfRounds > 1 else { return true }
        let restDurations = draftRoundConfigurations.dropLast().map(\.restDuration)
        guard let minimumRest = restDurations.min() else { return true }
        return TimeInterval(restWarningSeconds) < minimumRest
    }

    private var roundSummaryText: String {
        guard let first = draftRoundConfigurations.first else {
            return "Нет раундов"
        }

        let isUniform = draftRoundConfigurations.allSatisfy {
            $0.roundDuration == first.roundDuration &&
            $0.restDuration == first.restDuration &&
            $0.roundWarningTime == first.roundWarningTime
        }

        if isUniform {
            return "\(draftNumberOfRounds) × (\(formatTime(first.roundDuration)) раунд + \(formatTime(first.restDuration)) отдых)"
        }

        return "Индивидуальные настройки для каждого раунда"
    }

    private func formatTotalWorkoutTime() -> String {
        let totalSeconds = totalWorkoutSeconds()

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours):\(twoDigitString(minutes)):\(twoDigitString(seconds))"
        }
        return "\(minutes):\(twoDigitString(seconds))"
    }

    private func formatTime(_ duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return "\(minutes):\(twoDigitString(seconds))"
    }

    private func twoDigitString(_ value: Int) -> String {
        value.formatted(.number.precision(.integerLength(2)).grouping(.never))
    }

    private func saveSettings() {
        let normalizedConfigurations = normalizedRoundConfigurations(for: draftNumberOfRounds)
        model.updateRoundConfigurations(normalizedConfigurations)
        model.restWarningTime = TimeInterval(restWarningSeconds)
    }

    private func saveAsPreset() {
        guard !presetName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        // Сначала сохраняем текущие настройки в модель
        saveSettings()

        // Создаем новый пресет из текущих настроек модели
        let preset = WorkoutPreset(name: presetName.trimmingCharacters(in: .whitespaces), from: model)
        modelContext.insert(preset)

        do {
            try modelContext.save()
            presetName = ""
        } catch {
            print("Failed to save preset: \(error)")
        }
    }

    private func normalizedRoundConfigurations(for count: Int) -> [RoundConfiguration] {
        let clampedCount = max(1, count)
        if clampedCount == draftRoundConfigurations.count {
            return draftRoundConfigurations
        }

        if clampedCount < draftRoundConfigurations.count {
            return Array(draftRoundConfigurations.prefix(clampedCount))
        }

        let template = draftRoundConfigurations.last ?? .defaultConfiguration
        let additions = (0..<(clampedCount - draftRoundConfigurations.count)).map { _ in
            RoundConfiguration(
                roundDuration: template.roundDuration,
                restDuration: template.restDuration,
                roundWarningTime: template.roundWarningTime
            )
        }
        return draftRoundConfigurations + additions
    }

    private func roundNumber(for configuration: RoundConfiguration) -> Int {
        draftRoundConfigurations.firstIndex { $0.id == configuration.id }
            .map { $0 + 1 } ?? 1
    }

    private func applyQuickPreset(roundMinutes: Int, restMinutes: Int) {
        let roundDuration = TimeInterval(roundMinutes * 60)
        let restDuration = TimeInterval(restMinutes * 60)
        draftRoundConfigurations = draftRoundConfigurations.map { configuration in
            var updated = configuration
            updated.roundDuration = roundDuration
            updated.restDuration = restDuration
            return updated
        }
    }

    private func totalWorkoutSeconds() -> Int {
        guard !draftRoundConfigurations.isEmpty else { return 0 }
        var total = 0
        for (index, configuration) in draftRoundConfigurations.enumerated() {
            total += Int(configuration.roundDuration)
            if index < draftRoundConfigurations.count - 1 {
                total += Int(configuration.restDuration)
            }
        }
        return total
    }
}

// MARK: - Quick Preset Button
struct QuickPresetButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                VStack(spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
