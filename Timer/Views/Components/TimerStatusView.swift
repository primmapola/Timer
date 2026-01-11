//
//  TimerStatusView.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI

struct TimerStatusView: View {
    let statusText: String
    let phaseTitle: String
    let isPaused: Bool
    let statusColor: Color
    let iconName: String

    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 24
    @ScaledMetric(relativeTo: .body) private var horizontalSpacing: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var verticalSpacing: CGFloat = 4

    var body: some View {
        HStack(spacing: horizontalSpacing) {
            Image(systemName: iconName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(statusColor)

            VStack(alignment: .leading, spacing: verticalSpacing) {
                Text(statusText)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(isPaused ? "Пауза" : phaseTitle)
                    .font(.caption.bold())
                    .foregroundStyle(statusColor)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Статус")
        .accessibilityValue("\(statusText), \(isPaused ? "Пауза" : phaseTitle)")
    }
}
