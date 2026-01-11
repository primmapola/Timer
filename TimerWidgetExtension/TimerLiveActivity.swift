//
//  TimerLiveActivity.swift
//  TimerWidgetExtension
//
//  Created by Grigory Don on 10.01.2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BoxingTimerActivityAttributes.self) { context in
            // Lock screen/banner UI
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(context.state.phase == .round ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: context.state.phase == .round ? "figure.boxing" : "moon.zzz.fill")
                            .font(.title2)
                            .foregroundStyle(context.state.phase == .round ? .red : .green)
                        Text(context.state.phase == .round ? String(localized: "status.round") : String(localized: "status.rest"))
                            .font(.caption.weight(.semibold))
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    HStack {
                        Text("\(context.state.currentRound)")
                            .font(.title.weight(.bold))
                        Text("/")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Text("\(context.attributes.numberOfRounds)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }

                DynamicIslandExpandedRegion(.center) {
                    Text(formatTime(context.state.timeRemaining))
                        .font(.title.bold())
                        .monospacedDigit()
                        .foregroundStyle(context.state.phase == .round ? .red : .green)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isPaused {
                        HStack {
                            Image(systemName: "pause.circle.fill")
                            Text("widget.on_pause")
                        }
                        .font(.caption)
                        .foregroundStyle(.orange)
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.phase == .round ? "figure.boxing" : "moon.zzz.fill")
                    .foregroundStyle(context.state.phase == .round ? .red : .green)
            } compactTrailing: {
                Text(formatTime(context.state.timeRemaining))
                    .font(.caption2.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(context.state.phase == .round ? .red : .green)
            } minimal: {
                Image(systemName: context.state.phase == .round ? "figure.boxing" : "moon.zzz.fill")
                    .foregroundStyle(context.state.phase == .round ? .red : .green)
            }
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return "\(twoDigitString(minutes)):\(twoDigitString(secs))"
    }

    private func twoDigitString(_ value: Int) -> String {
        value.formatted(.number.precision(.integerLength(2)).grouping(.never))
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<BoxingTimerActivityAttributes>

    var body: some View {
        VStack {
            // Название тренировки
            Text(context.attributes.workoutName)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                // Левая часть - иконка и фаза
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: context.state.phase == .round ? "figure.boxing" : "moon.zzz.fill")
                            .font(.title3)
                        Text(context.state.phase == .round ? String(localized: "status.round") : String(localized: "status.rest"))
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(context.state.phase == .round ? .red : .green)

                    Text(String.localizedStringWithFormat(String(localized: "widget.round_status"), context.state.currentRound, context.attributes.numberOfRounds))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Центр - таймер
                VStack {
                    Text(formatTime(context.state.timeRemaining))
                        .font(.title2.bold())
                        .monospacedDigit()
                        .foregroundStyle(context.state.phase == .round ? .red : .green)

                    if context.state.isPaused {
                        Text("status.paused")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return "\(twoDigitString(minutes)):\(twoDigitString(secs))"
    }

    private func twoDigitString(_ value: Int) -> String {
        value.formatted(.number.precision(.integerLength(2)).grouping(.never))
    }
}
