//
//  BoxingTimerView.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI

struct BoxingTimerView: View {
    @State private var model = BoxingTimerModel()
    @State private var isSettingsPresented = false
    @State private var isPresetsPresented = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                statusSection
                timerDisplay
                roundCounter
                Spacer()
                controlButtons
            }
            .padding()
            .background {
                backgroundGradient
            }
            .animation(.easeInOut(duration: 0.3), value: model.timerState)
            .navigationTitle(model.currentPresetName)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresetsPresented = true
                    } label: {
                        Image(systemName: "folder")
                    }
                    .disabled(model.isRunning)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSettingsPresented = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .disabled(model.isRunning)
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView(model: model)
            }
            .sheet(isPresented: $isPresetsPresented) {
                PresetsView(model: model)
            }
        }
    }

    // MARK: - View Components
    private var backgroundGradient: some View {
        Group {
            switch model.timerState {
            case .running(.round), .paused(.round):
                Color.red.opacity(0.1)
            case .running(.rest), .paused(.rest):
                Color.green.opacity(0.1)
            case .finished:
                Color.purple.opacity(0.1)
            case .idle:
                Color.clear
            }
        }
        .ignoresSafeArea()
    }

    private var statusSection: some View {
        Text(model.statusText)
            .font(.title2.weight(.semibold))
            .foregroundStyle(model.statusColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.thinMaterial, in: .rect(cornerRadius: 16))
    }

    private var timerDisplay: some View {
        Text(model.formatTime(model.timeRemaining))
            .font(.system(size: 96, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(model.statusColor)
            .contentTransition(.numericText())
    }

    private var roundCounter: some View {
        HStack(spacing: 40) {
            VStack(spacing: 8) {
                Text("РАУНД")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(model.currentRound)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
            }

            Text("/")
                .font(.system(size: 48, weight: .ultraLight))
                .foregroundStyle(.tertiary)

            VStack(spacing: 8) {
                Text("ВСЕГО")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(model.numberOfRounds)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
            }
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
    }

    @ViewBuilder
    private var controlButtons: some View {
        if model.canStart {
            Button {
                model.start()
            } label: {
                Label("Старт", systemImage: "play.fill")
                    .font(.title3.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.green)
        } else {
            HStack(spacing: 16) {
                Button {
                    model.pause()
                } label: {
                    Label("Пауза", systemImage: "pause.fill")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.orange)

                Button(role: .destructive) {
                    model.reset()
                } label: {
                    Label("Сброс", systemImage: "stop.fill")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }
}

// MARK: - Preview
#Preview("Idle") {
    BoxingTimerView()
}

#Preview("Running") {
    @Previewable @State var model = BoxingTimerModel()

    BoxingTimerView()
        .onAppear {
            model.start()
        }
}
