//
//  BoxingTimerView.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI

struct BoxingTimerView: View {
    @Bindable var model: BoxingTimerModel

    @State private var isSettingsPresented = false
    @State private var isPresetsPresented = false
    @State private var isWarningPulsing = false
    @ScaledMetric(relativeTo: .body) private var stackSpacing: CGFloat = 24

    var body: some View {
        NavigationStack {
            VStack(spacing: stackSpacing) {
                TimerStatusView(
                    statusText: model.statusText,
                    phaseTitle: model.phaseTitle,
                    isPaused: model.isPaused,
                    statusColor: model.statusColor,
                    iconName: model.phaseIconName
                )

                TimerPhaseBadgeView(
                    phaseTitle: model.phaseTitle,
                    iconName: model.phaseIconName,
                    statusColor: model.statusColor,
                    currentRound: model.currentRound,
                    numberOfRounds: model.numberOfRounds
                )

                TimerDisplayView(
                    timeText: model.formatTime(model.timeRemaining),
                    statusColor: model.statusColor,
                    isPaused: model.isPaused,
                    isFinished: model.timerState == .finished,
                    progress: model.phaseProgress,
                    isWarningPulsing: isWarningPulsing
                )

                TimerRoundCounterView(
                    currentRound: model.currentRound,
                    numberOfRounds: model.numberOfRounds,
                    completedRounds: model.completedRounds,
                    statusColor: model.statusColor
                )

                Spacer()

                TimerControlButtonsView(
                    canStart: model.canStart,
                    onStart: model.start,
                    onPause: model.pause,
                    onReset: model.reset
                )
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                TimerBackgroundView(timerState: model.timerState)
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
                        Label("Пресеты", systemImage: "folder")
                    }
                    .disabled(model.isRunning)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isSettingsPresented = true
                    } label: {
                        Label("Настройки", systemImage: "gearshape")
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
}

#Preview("Idle") {
    @Previewable @State var model = BoxingTimerModel()
    BoxingTimerView(model: model)
}

#Preview("Running") {
    @Previewable @State var model = BoxingTimerModel()

    BoxingTimerView(model: model)
        .onAppear {
            model.start()
        }
}
