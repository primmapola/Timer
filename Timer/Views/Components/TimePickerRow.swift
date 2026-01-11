//
//  TimePickerRow.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI

struct TimePickerRow: View {
    @Binding var minutes: Int
    @Binding var seconds: Int

    @ScaledMetric(relativeTo: .body) private var horizontalSpacing: CGFloat = 20
    @ScaledMetric(relativeTo: .body) private var verticalSpacing: CGFloat = 8
    @ScaledMetric(relativeTo: .body) private var pickerHeight: CGFloat = 100
    @ScaledMetric(relativeTo: .body) private var colonOffset: CGFloat = -8

    var body: some View {
        HStack(spacing: horizontalSpacing) {
            // Минуты
            VStack(spacing: verticalSpacing) {
                Picker("Минуты", selection: $minutes) {
                    ForEach(0...10, id: \.self) { min in
                        Text("\(min)")
                            .font(.title2)
                            .tag(min)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: pickerHeight)

                Text("минут")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(":")
                .font(.title2)
                .foregroundStyle(.secondary)
                .offset(y: colonOffset)

            // Секунды
            VStack(spacing: verticalSpacing) {
                Picker("Секунды", selection: $seconds) {
                    ForEach(0...59, id: \.self) { sec in
                        Text(twoDigitString(sec))
                            .font(.title2)
                            .tag(sec)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: pickerHeight)

                Text("секунд")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func twoDigitString(_ value: Int) -> String {
        value.formatted(.number.precision(.integerLength(2)).grouping(.never))
    }
}
