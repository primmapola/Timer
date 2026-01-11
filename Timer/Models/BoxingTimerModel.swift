//
//  BoxingTimerModel.swift
//  Timer
//
//  Created by Grigory Don on 10.01.2026.
//

import SwiftUI
import AVFoundation
import Combine
import ActivityKit
#if canImport(UIKit)
import UIKit
#endif

@MainActor
@Observable
final class BoxingTimerModel {
    enum TimerState: Equatable {
        case idle
        case running(phase: Phase)
        case paused(phase: Phase)
        case finished

        enum Phase: Equatable {
            case round(number: Int)
            case rest(afterRound: Int)
        }
    }

    enum ControlButtonsState: Equatable {
        case startOnly
        case startReset
        case pauseReset
    }

    // MARK: - Settings
    var currentPresetName: String = "Таймер"
    var roundDuration: TimeInterval = 180
    var restDuration: TimeInterval = 60
    var numberOfRounds: Int = 3
    var roundWarningTime: TimeInterval = 10
    var restWarningTime: TimeInterval = 10

    // Sound settings
    var roundStartSound: SystemSound = .bell
    var restStartSound: SystemSound = .beep
    var roundWarningSound: SystemSound = .beep
    var restWarningSound: SystemSound = .beep
    var workoutCompleteSound: SystemSound = .complete

    // MARK: - State
    private(set) var timerState: TimerState = .idle
    private(set) var timeRemaining: TimeInterval = 0
    private(set) var hasStarted: Bool = false

    private var cancellable: AnyCancellable?
    private var activity: Activity<BoxingTimerActivityAttributes>?

    // MARK: - Computed Properties
    var currentRound: Int {
        switch timerState {
        case .running(.round(let number)), .paused(.round(let number)):
            return number
        case .running(.rest(let afterRound)), .paused(.rest(let afterRound)):
            return afterRound
        case .idle, .finished:
            return 1
        }
    }

    var completedRounds: Int {
        switch timerState {
        case .running(.round(let number)), .paused(.round(let number)):
            return max(0, number - 1)
        case .running(.rest(let afterRound)), .paused(.rest(let afterRound)):
            return afterRound
        case .finished:
            return numberOfRounds
        case .idle:
            return 0
        }
    }

    var isRunning: Bool {
        if case .running = timerState {
            return true
        }
        return false
    }

    var isPaused: Bool {
        if case .paused = timerState {
            return true
        }
        return false
    }

    var canStart: Bool {
        switch timerState {
        case .idle, .finished, .paused:
            return true
        case .running:
            return false
        }
    }

    var controlButtonsState: ControlButtonsState {
        if isRunning {
            return .pauseReset
        }

        if hasStarted {
            return .startReset
        }

        return .startOnly
    }

    var phaseTitle: String {
        switch timerState {
        case .running(.round), .paused(.round):
            return "РАУНД"
        case .running(.rest), .paused(.rest):
            return "ОТДЫХ"
        case .finished:
            return "ФИНИШ"
        case .idle:
            return "ГОТОВ"
        }
    }

    var phaseIconName: String {
        switch timerState {
        case .running(.round), .paused(.round):
            return "figure.boxing"
        case .running(.rest), .paused(.rest):
            return "figure.mind.and.body"
        case .finished:
            return "flag.checkered"
        case .idle:
            return "bolt.heart"
        }
    }

    var totalPhaseDuration: TimeInterval {
        switch timerState {
        case .running(.round), .paused(.round):
            return roundDuration
        case .running(.rest), .paused(.rest):
            return restDuration
        case .idle, .finished:
            return 0
        }
    }

    var phaseProgress: Double {
        let total = totalPhaseDuration
        guard total > 0 else {
            return timerState == .finished ? 1 : 0
        }
        let progress = (total - timeRemaining) / total
        return min(max(progress, 0), 1)
    }

    var isInWarningTime: Bool {
        guard timeRemaining > 0 else { return false }
        switch timerState {
        case .running(.round), .paused(.round):
            return timeRemaining <= roundWarningTime
        case .running(.rest), .paused(.rest):
            return timeRemaining <= restWarningTime
        case .idle, .finished:
            return false
        }
    }

    var statusText: String {
        switch timerState {
        case .idle:
            return "Хорошей тренировки!"
        case .running(.round(let number)), .paused(.round(let number)):
            return "РАУНД \(number)"
        case .running(.rest), .paused(.rest):
            return "ОТДЫХ"
        case .finished:
            return "Тренировка завершена!"
        }
    }

    var statusColor: Color {
        switch timerState {
        case .running(.round):
            return .red
        case .paused(.round):
            return .orange
        case .running(.rest):
            return .green
        case .paused(.rest):
            return .orange
        case .finished:
            return .purple
        case .idle:
            return .primary
        }
    }

    // MARK: - Public Methods
    func start() {
        switch timerState {
        case .idle, .finished:
            hasStarted = true
            timerState = .running(phase: .round(number: 1))
            timeRemaining = roundDuration
            playSound(roundStartSound)
            playHaptic(.success)
            startLiveActivity()
            startTimerPublisher()

        case .paused(let phase):
            timerState = .running(phase: phase)
            playHaptic(.light)
            updateLiveActivity()
            startTimerPublisher()

        case .running:
            break
        }
    }

    func pause() {
        guard case .running(let phase) = timerState else { return }
        timerState = .paused(phase: phase)
        playHaptic(.warning)
        updateLiveActivity()
        stopTimerPublisher()
    }

    func reset() {
        stopTimerPublisher()
        endLiveActivity()
        timerState = .idle
        timeRemaining = 0
        hasStarted = false
        playHaptic(.rigid)
    }

    func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = max(0, Int(seconds))
        let minutes = totalSeconds / 60
        let secs = totalSeconds % 60
        return "\(twoDigitString(minutes)):\(twoDigitString(secs))"
    }

    private func twoDigitString(_ value: Int) -> String {
        value.formatted(.number.precision(.integerLength(2)).grouping(.never))
    }

    // MARK: - Private Methods
    private func startTimerPublisher() {
        stopTimerPublisher()

        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func stopTimerPublisher() {
        cancellable?.cancel()
        cancellable = nil
    }

    private func tick() {
        guard isRunning else { return }

        if timeRemaining > 0 {
            timeRemaining -= 1
            updateLiveActivity()

            // Предупреждающий сигнал
            if case .running(let phase) = timerState {
                switch phase {
                case .round:
                    if timeRemaining == roundWarningTime {
                        playSound(roundWarningSound)
                        playHaptic(.warning)
                    }
                case .rest:
                    if timeRemaining == restWarningTime {
                        playSound(restWarningSound)
                        playHaptic(.warning)
                    }
                }
            }
        } else {
            handlePhaseComplete()
        }
    }

    private func handlePhaseComplete() {
        guard case .running(let phase) = timerState else { return }

        switch phase {
        case .round(let number):
            if number < numberOfRounds {
                // Переход к отдыху
                timerState = .running(phase: .rest(afterRound: number))
                timeRemaining = restDuration
                updateLiveActivity()
                playSound(restStartSound)
                playHaptic(.light)
            } else {
                // Тренировка завершена
                timerState = .finished
                timeRemaining = 0
                stopTimerPublisher()
                endLiveActivity()
                playSound(workoutCompleteSound)
                playHaptic(.success)
            }

        case .rest(let afterRound):
            // Переход к следующему раунду
            let nextRound = afterRound + 1
            timerState = .running(phase: .round(number: nextRound))
            timeRemaining = roundDuration
            updateLiveActivity()
            playSound(roundStartSound)
            playHaptic(.light)
        }
    }

    private func playSound(_ sound: SystemSound) {
        AudioServicesPlaySystemSound(sound.rawValue)
    }

    private func playHaptic(_ style: HapticStyle) {
        #if canImport(UIKit)
        switch style {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .rigid:
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        #endif
    }

    // MARK: - Live Activity Methods
    private func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = BoxingTimerActivityAttributes(
            workoutName: currentPresetName,
            numberOfRounds: numberOfRounds,
            roundDuration: roundDuration,
            restDuration: restDuration
        )

        let contentState = BoxingTimerActivityAttributes.ContentState(
            timeRemaining: timeRemaining,
            currentRound: currentRound,
            phase: .round,
            isPaused: false
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil)
            )
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    private func updateLiveActivity() {
        guard let activity = activity else { return }

        let phase: BoxingTimerActivityAttributes.ContentState.Phase
        switch timerState {
        case .running(.round), .paused(.round):
            phase = .round
        case .running(.rest), .paused(.rest):
            phase = .rest
        case .finished:
            phase = .finished
        case .idle:
            return
        }

        let isPaused: Bool
        if case .paused = timerState {
            isPaused = true
        } else {
            isPaused = false
        }

        let contentState = BoxingTimerActivityAttributes.ContentState(
            timeRemaining: timeRemaining,
            currentRound: currentRound,
            phase: phase,
            isPaused: isPaused
        )

        Task {
            await activity.update(.init(state: contentState, staleDate: nil))
        }
    }

    private func endLiveActivity() {
        guard let activity = activity else { return }

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            self.activity = nil
        }
    }
}

private enum HapticStyle {
    case light
    case rigid
    case warning
    case success
}

// MARK: - System Sounds
enum SystemSound: UInt32, CaseIterable, Identifiable {
    case bell = 1005
    case beep = 1109
    case complete = 1016
    case anticipate = 1020
    case bloom = 1021
    case calypso = 1022
    case chime = 1023
    case descent = 1024
    case fanfare = 1025
    case ladder = 1026
    case minuet = 1027
    case newsFlash = 1028
    case noir = 1029
    case sherwood = 1030
    case spell = 1031
    case suspense = 1032
    case telegraph = 1033
    case tiptoes = 1034
    case typewriters = 1035
    case update = 1036

    var id: UInt32 { rawValue }

    var name: String {
        switch self {
        case .bell: return "Колокол"
        case .beep: return "Гудок"
        case .complete: return "Завершение"
        case .anticipate: return "Ожидание"
        case .bloom: return "Цветение"
        case .calypso: return "Калипсо"
        case .chime: return "Перезвон"
        case .descent: return "Спуск"
        case .fanfare: return "Фанфары"
        case .ladder: return "Лестница"
        case .minuet: return "Менуэт"
        case .newsFlash: return "Новости"
        case .noir: return "Нуар"
        case .sherwood: return "Шервуд"
        case .spell: return "Заклинание"
        case .suspense: return "Саспенс"
        case .telegraph: return "Телеграф"
        case .tiptoes: return "На цыпочках"
        case .typewriters: return "Печатная машинка"
        case .update: return "Обновление"
        }
    }
}
