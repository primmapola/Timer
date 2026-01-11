//
//  IndividualRoundsView.swift
//  Timer
//
//  Created by Grigory Don on 11.01.2026.
//

import SwiftUI

struct IndividualRoundsView: View {
    @Binding var roundsConfiguration: RoundsConfigurationMode
    @Environment(\.dismiss) private var dismiss

    @State private var rounds: [RoundConfiguration] = []
    @State private var expandedRoundId: UUID?

    var body: some View {
        NavigationStack {
            List {
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
                            let totalDuration = calculateTotalDuration()
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
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    ForEach(rounds) { round in
                        if let index = rounds.firstIndex(where: { $0.id == round.id }) {
                            RoundRowView(
                                index: index,
                                round: $rounds[index],
                                isExpanded: Binding(
                                    get: { expandedRoundId == round.id },
                                    set: { isExpanded in
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            expandedRoundId = isExpanded ? round.id : nil
                                        }
                                    }
                                ),
                                onDuplicate: { duplicateRound(at: index) }
                            )
                        }
                    }
                    .onDelete(perform: deleteRounds)
                    .onMove(perform: moveRounds)

                    Button {
                        addRound()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                            Text("individual_rounds.add_round")
                                .foregroundStyle(.primary)
                        }
                    }
                } header: {
                    Text("individual_rounds.header")
                } footer: {
                    Text("individual_rounds.footer")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("individual_rounds.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("alert.cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveConfiguration()
                        dismiss()
                    } label: {
                        Text("alert.save")
                            .bold()
                    }
                    .disabled(rounds.isEmpty)
                }
            }
        }
        .onAppear {
            rounds = roundsConfiguration.rounds
        }
    }

    private func addRound() {
        let lastRound = rounds.last ?? RoundConfiguration(roundDuration: 180, restDuration: 60)
        withAnimation {
            rounds.append(RoundConfiguration(
                roundDuration: lastRound.roundDuration,
                restDuration: lastRound.restDuration
            ))
        }
    }

    private func duplicateRound(at index: Int) {
        guard index >= 0 && index < rounds.count else { return }
        let roundToDuplicate = rounds[index]

        withAnimation {
            // Создаем копию раунда с новым ID
            let duplicatedRound = RoundConfiguration(
                roundDuration: roundToDuplicate.roundDuration,
                restDuration: roundToDuplicate.restDuration,
                roundWarningTime: roundToDuplicate.roundWarningTime,
                restWarningTime: roundToDuplicate.restWarningTime
            )
            // Вставляем дубликат сразу после оригинала
            rounds.insert(duplicatedRound, at: index + 1)
        }
    }

    private func deleteRounds(at offsets: IndexSet) {
        rounds.remove(atOffsets: offsets)
    }

    private func moveRounds(from source: IndexSet, to destination: Int) {
        rounds.move(fromOffsets: source, toOffset: destination)
    }

    private func saveConfiguration() {
        roundsConfiguration = .individual(rounds: rounds)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return "\(minutes):\(twoDigitString(secs))"
    }

    private func twoDigitString(_ value: Int) -> String {
        value.formatted(.number.precision(.integerLength(2)).grouping(.never))
    }

    private func calculateTotalDuration() -> TimeInterval {
        rounds.reduce(0) { total, round in
            total + round.roundDuration + round.restDuration
        } - (rounds.last?.restDuration ?? 0) // Вычитаем последний отдых
    }

    private func formatTotalWorkoutTime() -> String {
        let totalSeconds = Int(calculateTotalDuration())
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours):\(twoDigitString(minutes)):\(twoDigitString(seconds))"
        }
        return "\(minutes):\(twoDigitString(seconds))"
    }
}

// MARK: - Round Time Picker
struct RoundTimePicker: View {
    @Binding var duration: TimeInterval

    private var minutes: Int {
        Int(duration) / 60
    }

    private var seconds: Int {
        Int(duration) % 60
    }

    var body: some View {
        HStack {
            // Минуты
            Picker("time_picker.minutes", selection: Binding(
                get: { minutes },
                set: { newMinutes in
                    duration = TimeInterval(newMinutes * 60 + seconds)
                }
            )) {
                ForEach(0...59, id: \.self) { minute in
                    Text("\(minute)")
                        .tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)

            Text("time_unit.min")
                .foregroundStyle(.secondary)

            // Секунды
            Picker("time_picker.seconds", selection: Binding(
                get: { seconds },
                set: { newSeconds in
                    duration = TimeInterval(minutes * 60 + newSeconds)
                }
            )) {
                ForEach(0...59, id: \.self) { second in
                    Text("\(second)")
                        .tag(second)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)

            Text("time_unit.sec")
                .foregroundStyle(.secondary)
        }
        .frame(height: 120)
    }
}

// MARK: - Warning Time Picker
struct WarningTimePicker: View {
    @Binding var warningTime: TimeInterval
    let maxDuration: TimeInterval

    var body: some View {
        HStack {
            Picker("time_picker.seconds", selection: Binding(
                get: { Int(warningTime) },
                set: { newValue in
                    warningTime = TimeInterval(newValue)
                }
            )) {
                ForEach(1...min(59, Int(maxDuration - 1)), id: \.self) { second in
                    Text("\(second)")
                        .tag(second)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)

            Text("time_unit.sec")
                .foregroundStyle(.secondary)
        }
        .frame(height: 100)
    }
}

// MARK: - Round Row View
private struct RoundRowView: View {
    let index: Int
    @Binding var round: RoundConfiguration
    @Binding var isExpanded: Bool
    let onDuplicate: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button {
                isExpanded.toggle()
            } label: {
                HStack(spacing: 12) {
                    // Номер раунда
                    ZStack {
                        Circle()
                            .fill(.blue.opacity(0.2))
                            .frame(width: 36, height: 36)

                        Text("\(index + 1)")
                            .font(.body.bold())
                            .foregroundStyle(.blue)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(String.localizedStringWithFormat(String(localized: "individual_rounds.round_number"), index + 1))
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)

                        HStack(spacing: 12) {
                            // Длительность раунда
                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                Text(formatTime(round.roundDuration))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            // Отдых
                            HStack(spacing: 4) {
                                Image(systemName: "pause.circle")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                                Text(formatTime(round.restDuration))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    onDuplicate()
                } label: {
                    Label("individual_rounds.duplicate", systemImage: "doc.on.doc")
                }
                .tint(.blue)
            }
            .contextMenu {
                Button {
                    onDuplicate()
                } label: {
                    Label("individual_rounds.duplicate", systemImage: "doc.on.doc")
                }
            }

            if isExpanded {
                VStack(spacing: 16) {
                    // Длительность раунда
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(.red)
                            Text("individual_rounds.round_duration")
                                .font(.subheadline.weight(.medium))
                        }

                        RoundTimePicker(duration: $round.roundDuration)
                    }

                    Divider()

                    // Предупреждение раунда
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "bell.badge")
                                .foregroundStyle(.orange)
                            Text("individual_rounds.round_warning")
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { round.roundWarningTime != nil },
                                set: { enabled in
                                    round.roundWarningTime = enabled ? 10 : nil
                                }
                            ))
                        }

                        if round.roundWarningTime != nil {
                            WarningTimePicker(
                                warningTime: Binding(
                                    get: { round.roundWarningTime ?? 10 },
                                    set: { newValue in
                                        round.roundWarningTime = newValue
                                    }
                                ),
                                maxDuration: round.roundDuration
                            )
                        }
                    }

                    Divider()

                    // Отдых после раунда
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "pause.circle")
                                .foregroundStyle(.green)
                            Text("individual_rounds.rest_after")
                                .font(.subheadline.weight(.medium))
                        }

                        RoundTimePicker(duration: $round.restDuration)
                    }

                    Divider()

                    // Предупреждение отдыха
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "bell.badge")
                                .foregroundStyle(.orange)
                            Text("individual_rounds.rest_warning")
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { round.restWarningTime != nil },
                                set: { enabled in
                                    round.restWarningTime = enabled ? 10 : nil
                                }
                            ))
                        }

                        if round.restWarningTime != nil {
                            WarningTimePicker(
                                warningTime: Binding(
                                    get: { round.restWarningTime ?? 10 },
                                    set: { newValue in
                                        round.restWarningTime = newValue
                                    }
                                ),
                                maxDuration: round.restDuration
                            )
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return "\(minutes):\(twoDigitString(secs))"
    }

    private func twoDigitString(_ value: Int) -> String {
        value.formatted(.number.precision(.integerLength(2)).grouping(.never))
    }
}
