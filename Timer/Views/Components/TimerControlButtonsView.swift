//
//  TimerControlButtonsView.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI

struct TimerControlButtonsView: View {
    let canStart: Bool
    @State private var isInitial: Bool
    let onStart: () -> Void
    let onPause: () -> Void
    let onReset: () -> Void

    init(
        canStart: Bool,
        isInitial: Bool = false,
        onStart: @escaping () -> Void,
        onPause: @escaping () -> Void,
        onReset: @escaping () -> Void
    ) {
        self.canStart = canStart
        _isInitial = State(initialValue: isInitial)
        self.onStart = onStart
        self.onPause = onPause
        self.onReset = onReset
    }

    @ScaledMetric(relativeTo: .body) private var horizontalSpacing: CGFloat = 16
    @ScaledMetric(relativeTo: .title2) private var buttonHeight: CGFloat = 112
    
    private func buttonLabel(title: String, systemImage: String) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, minHeight: buttonHeight)
    }

    var body: some View {
        if canStart {
            HStack(spacing: horizontalSpacing) {
                Button {
                    if isInitial {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            isInitial = false
                        }
                    }
                    onStart()
                } label: {
                    buttonLabel(title: "Старт", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                if !isInitial {
                    Button(role: .destructive) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            isInitial = true
                        }
                        onReset()
                    } label: {
                        buttonLabel(title: "Сброс", systemImage: "stop.fill")
                    }
                    .disabled(false)
                    .buttonStyle(.bordered)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isInitial)
        } else {
            HStack(spacing: horizontalSpacing) {
                Button {
                    onPause()
                } label: {
                    buttonLabel(title: "Пауза", systemImage: "pause.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button(role: .destructive) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        isInitial = true
                    }
                    onReset()
                } label: {
                    buttonLabel(title: "Сброс", systemImage: "stop.fill")
                }
                .buttonStyle(.bordered)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}
