//
//  TimerBackgroundView.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI

struct TimerBackgroundView: View {
    let timerState: BoxingTimerModel.TimerState

    var body: some View {
        Group {
            switch timerState {
            case .running(.round):
                LinearGradient(
                    colors: [Color.red.opacity(0.25), Color.red.opacity(0.05), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .running(.rest):
                LinearGradient(
                    colors: [Color.green.opacity(0.25), Color.green.opacity(0.05), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            case .paused:
                LinearGradient(
                    colors: [Color.orange.opacity(0.25), Color.orange.opacity(0.05), .clear],
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
}
