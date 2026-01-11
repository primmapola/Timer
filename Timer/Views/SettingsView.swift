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
    case round
    case rest
    case numberOfRounds
    case roundWarning
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

    @State private var roundMinutes: Int
    @State private var roundSeconds: Int
    @State private var restMinutes: Int
    @State private var restSeconds: Int
    @State private var roundWarningSeconds: Int
    @State private var restWarningSeconds: Int
    @State private var expandedRow: SettingRow?
    @State private var showingSavePreset = false
    @State private var presetName = ""
    @State private var showingIndividualRounds = false
    @State private var isIndividualMode: Bool
    @Query private var presets: [WorkoutPreset]

    init(model: BoxingTimerModel) {
        self.model = model

        let roundTotal = Int(model.roundDuration)
        _roundMinutes = State(initialValue: roundTotal / 60)
        _roundSeconds = State(initialValue: roundTotal % 60)

        let restTotal = Int(model.restDuration)
        _restMinutes = State(initialValue: restTotal / 60)
        _restSeconds = State(initialValue: restTotal % 60)

        _roundWarningSeconds = State(initialValue: Int(model.roundWarningTime))
        _restWarningSeconds = State(initialValue: Int(model.restWarningTime))

        // Определяем режим конфигурации
        if case .individual = model.roundsConfiguration {
            _isIndividualMode = State(initialValue: true)
        } else {
            _isIndividualMode = State(initialValue: false)
        }
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
                            Text("section.total_time")
                                .font(.headline)
                            Spacer()
                            Text(formatTotalWorkoutTime())
                                .font(.title3.bold().monospacedDigit())
                                .foregroundStyle(.blue)
                        }

                        // Визуальный timeline с реальным соотношением времени
                        GeometryReader { geometry in
                            // Для uniform режима используем актуальные значения из @State переменных
                            let rounds: [RoundConfiguration] = isIndividualMode
                                ? model.roundsConfiguration.rounds
                                : (0..<model.numberOfRounds).map { _ in
                                    RoundConfiguration(
                                        roundDuration: TimeInterval(roundMinutes * 60 + roundSeconds),
                                        restDuration: TimeInterval(restMinutes * 60 + restSeconds)
                                    )
                                }

                            let totalDuration = rounds.reduce(0) { total, round in
                                total + round.roundDuration + round.restDuration
                            } - (rounds.last?.restDuration ?? 0)
                            let availableWidth = geometry.size.width

                            HStack(spacing: 0) {
                                ForEach(rounds.indices, id: \.self) { index in
                                    let round = rounds[index]

                                    // Раунд
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                colors: [.red.opacity(0.8), .red.opacity(0.6)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(width: (round.roundDuration / totalDuration) * availableWidth)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .strokeBorder(.red.opacity(0.3), lineWidth: 1)
                                        )
                                        .shadow(color: .red.opacity(0.3), radius: 2, y: 1)

                                    // Пауза (если не последний раунд)
                                    if index < rounds.count - 1 {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.green.opacity(0.7), .green.opacity(0.5)],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                            .frame(width: (round.restDuration / totalDuration) * availableWidth)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .strokeBorder(.green.opacity(0.3), lineWidth: 1)
                                            )
                                            .shadow(color: .green.opacity(0.2), radius: 2, y: 1)
                                    }
                                }
                            }
                        }
                        .frame(height: 32)

                        if isIndividualMode {
                            Text("individual_rounds.summary")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(String(format: String(localized: "%lld × (%@ раунд + %@ отдых)"), model.numberOfRounds, formatTime(minutes: roundMinutes, seconds: roundSeconds), formatTime(minutes: restMinutes, seconds: restSeconds)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Быстрые пресеты
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            QuickPresetButton(
                                title: String(localized: "quick_preset.3min.title"),
                                subtitle: String(localized: "quick_preset.3min.subtitle"),
                                icon: "bolt.fill",
                                color: .orange
                            ) {
                                roundMinutes = 3
                                roundSeconds = 0
                                restMinutes = 1
                                restSeconds = 0
                            }

                            QuickPresetButton(
                                title: String(localized: "quick_preset.5min.title"),
                                subtitle: String(localized: "quick_preset.5min.subtitle"),
                                icon: "flame.fill",
                                color: .red
                            ) {
                                roundMinutes = 5
                                roundSeconds = 0
                                restMinutes = 1
                                restSeconds = 0
                            }

                            QuickPresetButton(
                                title: String(localized: "quick_preset.12min.title"),
                                subtitle: String(localized: "quick_preset.12min.subtitle"),
                                icon: "figure.boxing",
                                color: .purple
                            ) {
                                roundMinutes = 12
                                roundSeconds = 0
                                restMinutes = 3
                                restSeconds = 0
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                } header: {
                    Text("section.quick_presets")
                }

                Section {
                    // Переключатель режима
                    Toggle(isOn: Binding(
                        get: { isIndividualMode },
                        set: { newValue in
                            isIndividualMode = newValue
                            if newValue {
                                // Переключаемся в индивидуальный режим
                                let currentRounds = model.roundsConfiguration.rounds
                                model.roundsConfiguration = .individual(rounds: currentRounds)
                            } else {
                                // Переключаемся в единообразный режим
                                model.roundsConfiguration = .uniform(
                                    roundDuration: TimeInterval(roundMinutes * 60 + roundSeconds),
                                    restDuration: TimeInterval(restMinutes * 60 + restSeconds),
                                    count: model.numberOfRounds
                                )
                            }
                        }
                    )) {
                        HStack(spacing: 12) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(.purple)
                                .font(.title3)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("settings.configuration_mode.label")
                                    .foregroundStyle(.primary)
                                    .font(.body.weight(.medium))
                                Text("settings.configuration_mode.description")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .tint(.purple)

                    if isIndividualMode {
                        Button {
                            showingIndividualRounds = true
                        } label: {
                            HStack {
                                Text("settings.configure_rounds")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(String.localizedStringWithFormat(String(localized: "settings.rounds_count"), model.numberOfRounds))
                                    .foregroundStyle(.secondary)
                                    .font(.body)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("settings.configuration_mode.header")
                }

                if !isIndividualMode {
                    Section {
                    // Раунд
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandedRow = expandedRow == .round ? nil : .round
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "timer")
                                .foregroundStyle(.red)
                                .font(.title3)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("settings.round.label")
                                    .foregroundStyle(.primary)
                                    .font(.body.weight(.medium))
                                Text("settings.round.description")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(formatTime(minutes: roundMinutes, seconds: roundSeconds))
                                .foregroundStyle(.red)
                                .font(.body.bold().monospacedDigit())
                        }
                    }

                    if expandedRow == .round {
                        TimePickerRow(
                            minutes: $roundMinutes,
                            seconds: $roundSeconds
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    // Пауза
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandedRow = expandedRow == .rest ? nil : .rest
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "pause.circle.fill")
                                .foregroundStyle(.green)
                                .font(.title3)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("settings.pause.label")
                                    .foregroundStyle(.primary)
                                    .font(.body.weight(.medium))
                                Text("settings.pause.description")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(formatTime(minutes: restMinutes, seconds: restSeconds))
                                .foregroundStyle(.green)
                                .font(.body.bold().monospacedDigit())
                        }
                    }

                    if expandedRow == .rest {
                        TimePickerRow(
                            minutes: $restMinutes,
                            seconds: $restSeconds
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

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
                                Text("settings.rounds.label")
                                    .foregroundStyle(.primary)
                                    .font(.body.weight(.medium))
                                Text("settings.rounds.description")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\(model.numberOfRounds)")
                                .foregroundStyle(.blue)
                                .font(.body.bold().monospacedDigit())
                        }
                    }

                    if expandedRow == .numberOfRounds {
                        Picker("Количество раундов", selection: $model.numberOfRounds) {
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

                } header: {
                    Text("section.main_settings")
                }
                }

                Section {
                    // Предупреждение о конце раунда
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            expandedRow = expandedRow == .roundWarning ? nil : .roundWarning
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.orange)
                                .font(.title3)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("settings.round_warning.label")
                                    .foregroundStyle(.primary)
                                    .font(.body.weight(.medium))
                                Text(String.localizedStringWithFormat(String(localized: "settings.round_warning.description"), roundWarningSeconds))
                                    .font(.caption)
                                    .foregroundStyle(isRoundWarningValid ? Color.secondary : Color.red)
                            }

                            Spacer()

                            Text(String.localizedStringWithFormat(String(localized: "settings.round_warning.display"), roundWarningSeconds))
                                .foregroundStyle(isRoundWarningValid ? .orange : .red)
                                .font(.body.bold().monospacedDigit())

                            if !isRoundWarningValid {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }
                        }
                    }

                    if expandedRow == .roundWarning {
                        Picker("Секунды", selection: $roundWarningSeconds) {
                            ForEach([3, 5, 10, 15, 20, 30], id: \.self) { sec in
                                Text(String.localizedStringWithFormat(String(localized: "settings.round_warning.picker_option"), sec))
                                    .tag(sec)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

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
                                Text("settings.rest_warning.label")
                                    .foregroundStyle(.primary)
                                    .font(.body.weight(.medium))
                                Text(String.localizedStringWithFormat(String(localized: "settings.rest_warning.description"), restWarningSeconds))
                                    .font(.caption)
                                    .foregroundStyle(isRestWarningValid ? Color.secondary : Color.red)
                            }

                            Spacer()

                            Text(String.localizedStringWithFormat(String(localized: "settings.rest_warning.display"), restWarningSeconds))
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
                                Text(String.localizedStringWithFormat(String(localized: "settings.rest_warning.picker_option"), sec))
                                    .tag(sec)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                } header: {
                    Text("section.warnings")
                } footer: {
                    if !isRoundWarningValid || !isRestWarningValid {
                        Text("settings.warning.duration_invalid")
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
                            Text("settings.sound.round_start")
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
                            Text("settings.sound.pause_start")
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
                            Text("settings.sound.round_warning")
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
                            Text("settings.sound.pause_warning")
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
                            Text("settings.sound.workout_end")
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
                    Text("section.sounds")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("settings.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("alert.cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingSavePreset = true
                        } label: {
                            Label("settings.save_as_new_preset", systemImage: "plus.square")
                        }

                        // Показываем кнопку обновления только если есть активный пресет
                        if let currentPresetId = model.currentPresetId,
                           presets.contains(where: { $0.id == currentPresetId }) {
                            Button {
                                updateCurrentPreset()
                            } label: {
                                Label("settings.update_preset", systemImage: "arrow.triangle.2.circlepath")
                            }
                        }
                    } label: {
                        Label("settings.save_preset", systemImage: "square.and.arrow.down")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveSettings()
                        dismiss()
                    } label: {
                        Label("alert.save", systemImage: "checkmark")
                    }
                    .disabled(!isValid)
                }
            }
            .alert("alert.save_preset.title", isPresented: $showingSavePreset) {
                TextField("Название шаблона", text: $presetName)
                Button("alert.save") {
                    saveAsPreset()
                }
                Button("alert.cancel", role: .cancel) {
                    presetName = ""
                }
            } message: {
                Text("alert.save_preset.message")
            }
            .sheet(isPresented: $showingIndividualRounds) {
                IndividualRoundsView(roundsConfiguration: $model.roundsConfiguration)
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var isValid: Bool {
        let roundTotal = roundMinutes * 60 + roundSeconds
        let restTotal = restMinutes * 60 + restSeconds
        return roundTotal > 0 && restTotal > 0 && isRoundWarningValid && isRestWarningValid
    }

    private var isRoundWarningValid: Bool {
        let roundTotal = roundMinutes * 60 + roundSeconds
        return roundWarningSeconds < roundTotal
    }

    private var isRestWarningValid: Bool {
        let restTotal = restMinutes * 60 + restSeconds
        return restWarningSeconds < restTotal
    }

    private func formatTotalWorkoutTime() -> String {
        // Для uniform режима вычисляем общее время из актуальных значений @State переменных
        let totalSeconds: Int
        if isIndividualMode {
            totalSeconds = Int(model.roundsConfiguration.totalDuration)
        } else {
            let roundDuration = roundMinutes * 60 + roundSeconds
            let restDuration = restMinutes * 60 + restSeconds
            // Общее время = (раунд + отдых) * количество - последний отдых
            totalSeconds = (roundDuration + restDuration) * model.numberOfRounds - restDuration
        }

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours):\(twoDigitString(minutes)):\(twoDigitString(seconds))"
        }
        return "\(minutes):\(twoDigitString(seconds))"
    }

    private func formatTime(minutes: Int, seconds: Int) -> String {
        return "\(minutes):\(twoDigitString(seconds))"
    }

    private func twoDigitString(_ value: Int) -> String {
        value.formatted(.number.precision(.integerLength(2)).grouping(.never))
    }

    private func saveSettings() {
        model.roundDuration = TimeInterval(roundMinutes * 60 + roundSeconds)
        model.restDuration = TimeInterval(restMinutes * 60 + restSeconds)
        model.roundWarningTime = TimeInterval(roundWarningSeconds)
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

    private func updateCurrentPreset() {
        guard let currentPresetId = model.currentPresetId,
              let preset = presets.first(where: { $0.id == currentPresetId }) else {
            return
        }

        // Сначала сохраняем текущие настройки в модель
        saveSettings()

        // Обновляем пресет
        preset.update(from: model)

        do {
            try modelContext.save()
        } catch {
            print("Failed to update preset: \(error)")
        }
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
