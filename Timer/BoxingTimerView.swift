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
    @State private var isWarningPulsing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                statusSection
                phaseBadge
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
            .onChange(of: model.isInWarningTime) { _, newValue in
                if newValue {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        isWarningPulsing = true
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isWarningPulsing = false
                    }
                }
            }
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
                LinearGradient(
                    colors: [Color.red.opacity(0.25), Color.red.opacity(0.05), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .running(.rest), .paused(.rest):
                LinearGradient(
                    colors: [Color.green.opacity(0.25), Color.green.opacity(0.05), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .finished:
                LinearGradient(
                    colors: [Color.purple.opacity(0.25), Color.purple.opacity(0.05), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .idle:
                Color.clear
            }
        }
        .ignoresSafeArea()
    }

    private var statusSection: some View {
        HStack(spacing: 12) {
            Image(systemName: model.phaseIconName)
                .font(.title2.weight(.semibold))
                .foregroundStyle(model.statusColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(model.statusText)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(model.isPaused ? "Пауза" : model.phaseTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(model.statusColor)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial, in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Статус")
        .accessibilityValue("\(model.statusText), \(model.isPaused ? "Пауза" : model.phaseTitle)")
    }

    private var timerDisplay: some View {
        ZStack {
            timerRing

            VStack(spacing: 8) {
                Text(model.formatTime(model.timeRemaining))
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(model.statusColor)
                    .contentTransition(.numericText())
                    .scaleEffect(isWarningPulsing ? 1.05 : 1.0)

                if model.isPaused {
                    Text("ПАУЗА")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: .capsule)
                } else if model.timerState == .finished {
                    Text("ЗАВЕРШЕНО")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: .capsule)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Оставшееся время")
        .accessibilityValue(model.formatTime(model.timeRemaining))
    }

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: 10)
                .frame(width: 220, height: 220)

            Circle()
                .trim(from: 0, to: model.phaseProgress)
                .stroke(
                    model.statusColor,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 220, height: 220)
                .animation(.easeInOut(duration: 0.3), value: model.phaseProgress)
        }
    }

    private var phaseBadge: some View {
        HStack(spacing: 12) {
            Label(model.phaseTitle, systemImage: model.phaseIconName)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(model.statusColor.opacity(0.15), in: .capsule)

            Text("Раунд \(model.currentRound) из \(model.numberOfRounds)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Фаза")
        .accessibilityValue("\(model.phaseTitle), Раунд \(model.currentRound) из \(model.numberOfRounds)")
    }

    private var roundCounter: some View {
        VStack(spacing: 16) {
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

            roundProgressDots
        }
        .padding()
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Счетчик раундов")
        .accessibilityValue("Раунд \(model.currentRound) из \(model.numberOfRounds)")
    }

    private var roundProgressDots: some View {
        HStack(spacing: 6) {
            ForEach(1...model.numberOfRounds, id: \.self) { round in
                Circle()
                    .fill(round <= model.completedRounds ? model.statusColor : Color.secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(round == model.currentRound ? model.statusColor : .clear, lineWidth: 1)
                    )
            }
        }
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
