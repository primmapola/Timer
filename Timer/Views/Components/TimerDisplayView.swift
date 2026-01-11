//
//  TimerDisplayView.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI

struct TimerDisplayView: View {
    let timeText: String
    let statusColor: Color
    let isPaused: Bool
    let isFinished: Bool
    let progress: Double
    let isWarningPulsing: Bool

    @ScaledMetric(relativeTo: .title) private var ringSize: CGFloat = 220
    @ScaledMetric(relativeTo: .title) private var ringLineWidth: CGFloat = 10
    @ScaledMetric(relativeTo: .caption) private var badgeHorizontalPadding: CGFloat = 12
    @ScaledMetric(relativeTo: .caption) private var badgeVerticalPadding: CGFloat = 6
    @ScaledMetric(relativeTo: .body) private var verticalSpacing: CGFloat = 8

    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: ringLineWidth)
                .frame(width: ringSize, height: ringSize)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    statusColor,
                    style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: ringSize, height: ringSize)
                .animation(.easeInOut(duration: 0.3), value: progress)

            VStack(spacing: verticalSpacing) {
                Text(timeText)
                    .font(.system(.largeTitle, design: .rounded).bold())
                    .monospacedDigit()
                    .foregroundStyle(statusColor)
                    .contentTransition(.numericText())
                    .minimumScaleFactor(0.6)
                    .scaleEffect(isWarningPulsing ? 1.05 : 1.0)

                if isPaused {
                    statusBadge(title: "ПАУЗА")
                } else if isFinished {
                    statusBadge(title: "ЗАВЕРШЕНО")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Оставшееся время")
        .accessibilityValue(timeText)
    }

    private func statusBadge(title: String) -> some View {
        Text(title)
            .font(.caption.bold())
            .padding(.horizontal, badgeHorizontalPadding)
            .padding(.vertical, badgeVerticalPadding)
            .background(.ultraThinMaterial, in: .capsule)
    }
}
