//
//  TimerPhaseBadgeView.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI

struct TimerPhaseBadgeView: View {
    let phaseTitle: String
    let iconName: String
    let statusColor: Color
    let currentRound: Int
    let numberOfRounds: Int

    @ScaledMetric(relativeTo: .body) private var badgeHorizontalPadding: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var badgeVerticalPadding: CGFloat = 8
    @ScaledMetric(relativeTo: .body) private var horizontalSpacing: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var horizontalPadding: CGFloat = 4

    var body: some View {
        HStack(spacing: horizontalSpacing) {
            Label(phaseTitle, systemImage: iconName)
                .font(.caption.bold())
                .padding(.horizontal, badgeHorizontalPadding)
                .padding(.vertical, badgeVerticalPadding)
                .background(statusColor.opacity(0.15), in: .capsule)

            Text("Раунд \(currentRound) из \(numberOfRounds)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, horizontalPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Фаза")
        .accessibilityValue("\(phaseTitle), Раунд \(currentRound) из \(numberOfRounds)")
    }
}
