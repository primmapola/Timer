//
//  RoundConfigurationRowView.swift
//  Timer
//
//  Created by Grigory Don on 12.01.2026.
//

import SwiftUI

struct RoundConfigurationRowView: View {
    let roundNumber: Int
    @Binding var configuration: RoundConfiguration
    @Binding var expandedRoundIndex: Int?

    @ScaledMetric(relativeTo: .body) private var rowSpacing: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var iconWidth: CGFloat = 28
    @ScaledMetric(relativeTo: .body) private var sectionSpacing: CGFloat = 8
    @ScaledMetric(relativeTo: .body) private var detailSpacing: CGFloat = 6

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                expandedRoundIndex = expandedRoundIndex == roundNumber ? nil : roundNumber
            }
        } label: {
            HStack(spacing: rowSpacing) {
                Image(systemName: "timer")
                    .foregroundStyle(.red)
                    .font(.title3)
                    .frame(width: iconWidth)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Раунд \(roundNumber)")
                        .foregroundStyle(.primary)
                        .font(.body.weight(.medium))
                    Text("Индивидуальные параметры")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatTime(configuration.roundDuration))
                        .foregroundStyle(.red)
                        .font(.body.bold().monospacedDigit())
                    Text(formatTime(configuration.restDuration))
                        .foregroundStyle(.green)
                        .font(.caption.monospacedDigit())
                    Text("\(Int(configuration.roundWarningTime)) сек")
                        .foregroundStyle(isWarningValid ? .orange : .red)
                        .font(.caption.monospacedDigit())
                }
            }
        }

        if expandedRoundIndex == roundNumber {
            VStack(alignment: .leading, spacing: sectionSpacing) {
                VStack(alignment: .leading, spacing: detailSpacing) {
                    Text("Раунд")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TimePickerRow(
                        minutes: roundMinutesBinding,
                        seconds: roundSecondsBinding
                    )
                }

                VStack(alignment: .leading, spacing: detailSpacing) {
                    Text("Отдых после раунда")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TimePickerRow(
                        minutes: restMinutesBinding,
                        seconds: restSecondsBinding
                    )
                }

                VStack(alignment: .leading, spacing: detailSpacing) {
                    Text("Предупреждение до конца")
                        .font(.caption)
                        .foregroundStyle(isWarningValid ? .secondary : .red)
                    Picker("Секунды", selection: roundWarningSecondsBinding) {
                        ForEach([3, 5, 10, 15, 20, 30], id: \.self) { sec in
                            Text("\(sec) сек")
                                .tag(sec)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }

    private var isWarningValid: Bool {
        configuration.roundWarningTime < configuration.roundDuration
    }

    private var roundMinutesBinding: Binding<Int> {
        Binding(
            get: { Int(configuration.roundDuration) / 60 },
            set: { newValue in
                let seconds = Int(configuration.roundDuration) % 60
                configuration.roundDuration = TimeInterval(newValue * 60 + seconds)
            }
        )
    }

    private var roundSecondsBinding: Binding<Int> {
        Binding(
            get: { Int(configuration.roundDuration) % 60 },
            set: { newValue in
                let minutes = Int(configuration.roundDuration) / 60
                configuration.roundDuration = TimeInterval(minutes * 60 + newValue)
            }
        )
    }

    private var restMinutesBinding: Binding<Int> {
        Binding(
            get: { Int(configuration.restDuration) / 60 },
            set: { newValue in
                let seconds = Int(configuration.restDuration) % 60
                configuration.restDuration = TimeInterval(newValue * 60 + seconds)
            }
        )
    }

    private var restSecondsBinding: Binding<Int> {
        Binding(
            get: { Int(configuration.restDuration) % 60 },
            set: { newValue in
                let minutes = Int(configuration.restDuration) / 60
                configuration.restDuration = TimeInterval(minutes * 60 + newValue)
            }
        )
    }

    private var roundWarningSecondsBinding: Binding<Int> {
        Binding(
            get: { Int(configuration.roundWarningTime) },
            set: { configuration.roundWarningTime = TimeInterval($0) }
        )
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
}
