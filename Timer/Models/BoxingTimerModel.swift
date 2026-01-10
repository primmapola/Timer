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

    // MARK: - Settings
    var currentPresetName: String = "Бокс Таймер"
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

    var isRunning: Bool {
        if case .running = timerState {
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

    var statusText: String {
        switch timerState {
        case .idle:
            return "Хорошей тренировки"
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
        case .running(.round), .paused(.round):
            return .red
        case .running(.rest), .paused(.rest):
            return .green
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
            timerState = .running(phase: .round(number: 1))
            timeRemaining = roundDuration
            playSound(roundStartSound)
            startLiveActivity()
            startTimerPublisher()

        case .paused(let phase):
            timerState = .running(phase: phase)
            updateLiveActivity()
            startTimerPublisher()

        case .running:
            break
        }
    }

    func pause() {
        guard case .running(let phase) = timerState else { return }
        timerState = .paused(phase: phase)
        updateLiveActivity()
        stopTimerPublisher()
    }

    func reset() {
        stopTimerPublisher()
        endLiveActivity()
        timerState = .idle
        timeRemaining = 0
    }

    func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
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
                    }
                case .rest:
                    if timeRemaining == restWarningTime {
                        playSound(restWarningSound)
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
            } else {
                // Тренировка завершена
                timerState = .finished
                timeRemaining = 0
                stopTimerPublisher()
                endLiveActivity()
                playSound(workoutCompleteSound)
            }

        case .rest(let afterRound):
            // Переход к следующему раунду
            let nextRound = afterRound + 1
            timerState = .running(phase: .round(number: nextRound))
            timeRemaining = roundDuration
            updateLiveActivity()
            playSound(roundStartSound)
        }
    }

    private func playSound(_ sound: SystemSound) {
        AudioServicesPlaySystemSound(sound.rawValue)
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
