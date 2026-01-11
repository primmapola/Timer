//
//  TimerControlButtonsView.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI

struct TimerControlButtonsView: View {
    let controlState: BoxingTimerModel.ControlButtonsState
    let onStart: () -> Void
    let onPause: () -> Void
    let onReset: () -> Void

    @ScaledMetric(relativeTo: .body) private var horizontalSpacing: CGFloat = 16
    @ScaledMetric(relativeTo: .title2) private var buttonHeight: CGFloat = 112

    var body: some View {
        switch controlState {
        case .startOnly:
            Button {
                onStart()
            } label: {
                Label("Старт", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.green)
            .frame(minHeight: buttonHeight)
        case .startReset:
            HStack(spacing: horizontalSpacing) {
                Button {
                    onStart()
                } label: {
                    Label("Старт", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.green)
                .frame(minHeight: buttonHeight)

                Button(role: .destructive) {
                    onReset()
                } label: {
                    Label("Сброс", systemImage: "stop.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .frame(minHeight: buttonHeight)
            }
        case .pauseReset:
            HStack(spacing: horizontalSpacing) {
                Button {
                    onPause()
                } label: {
                    Label("Пауза", systemImage: "pause.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.orange)
                .frame(minHeight: buttonHeight)

                Button(role: .destructive) {
                    onReset()
                } label: {
                    Label("Сброс", systemImage: "stop.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .frame(minHeight: buttonHeight)
            }
        }
    }
}
