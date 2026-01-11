//
//  TimerControlButtonsView.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI

struct TimerControlButtonsView: View {
    let canStart: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    let onReset: () -> Void

    @ScaledMetric(relativeTo: .body) private var horizontalSpacing: CGFloat = 16
    @ScaledMetric(relativeTo: .title2) private var buttonHeight: CGFloat = 56

    var body: some View {
        if canStart {
            Button {
                onStart()
            } label: {
                Label("Старт", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .frame(height: buttonHeight)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.green)
        } else {
            HStack(spacing: horizontalSpacing) {
                Button {
                    onPause()
                } label: {
                    Label("Пауза", systemImage: "pause.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .frame(height: buttonHeight)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.orange)

                Button(role: .destructive) {
                    onReset()
                } label: {
                    Label("Сброс", systemImage: "stop.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .frame(height: buttonHeight)
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }
}
