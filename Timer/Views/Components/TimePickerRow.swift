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

    var body: some View {
        HStack(spacing: 20) {
            // Минуты
            VStack(spacing: 8) {
                Picker("Минуты", selection: $minutes) {
                    ForEach(0...10, id: \.self) { min in
                        Text("\(min)")
                            .font(.title2)
                            .tag(min)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 100)

                Text("минут")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(":")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.secondary)
                .offset(y: -8)

            // Секунды
            VStack(spacing: 8) {
                Picker("Секунды", selection: $seconds) {
                    ForEach(0...59, id: \.self) { sec in
                        Text(String(format: "%02d", sec))
                            .font(.title2)
                            .tag(sec)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 100)

                Text("секунд")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
