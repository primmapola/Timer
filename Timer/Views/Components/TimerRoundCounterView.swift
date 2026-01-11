//
//  TimerRoundCounterView.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI

struct TimerRoundCounterView: View {
    let currentRound: Int
    let numberOfRounds: Int
    let completedRounds: Int
    let statusColor: Color

    @ScaledMetric(relativeTo: .title) private var dotSize: CGFloat = 8
    @ScaledMetric(relativeTo: .body) private var columnSpacing: CGFloat = 16
    @ScaledMetric(relativeTo: .body) private var rowSpacing: CGFloat = 32
    @ScaledMetric(relativeTo: .body) private var labelSpacing: CGFloat = 8
    @ScaledMetric(relativeTo: .body) private var dotSpacing: CGFloat = 6

    var body: some View {
        VStack(spacing: columnSpacing) {
            HStack(spacing: rowSpacing) {
                VStack(spacing: labelSpacing) {
                    Text("РАУНД")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(currentRound)")
                        .font(.title.bold())
                        .contentTransition(.numericText())
                }

                Text("/")
                    .font(.title3)
                    .foregroundStyle(.tertiary)

                VStack(spacing: labelSpacing) {
                    Text("ВСЕГО")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(numberOfRounds)")
                        .font(.title.bold())
                        .contentTransition(.numericText())
                }
            }

            HStack(spacing: dotSpacing) {
                ForEach(1...numberOfRounds, id: \.self) { round in
                    Circle()
                        .fill(round <= completedRounds ? statusColor : Color.secondary.opacity(0.3))
                        .frame(width: dotSize, height: dotSize)
                        .overlay(
                            Circle()
                                .stroke(round == currentRound ? statusColor : .clear, lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Счетчик раундов")
        .accessibilityValue("Раунд \(currentRound) из \(numberOfRounds)")
    }
}
