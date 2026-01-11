//
//  SoundPickerView.swift
//  Timer
//
//  Created by Grigory Don on 11.01.2026.
//

import SwiftUI
import AVFoundation

struct SoundPickerView: View {
    @Binding var selectedSound: SystemSound
    let onSoundSelected: (SystemSound) -> Void

    @State private var playingSound: SystemSound?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(SystemSound.allCases) { sound in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedSound = sound
                        onSoundSelected(sound)
                    }
                } label: {
                    HStack(spacing: 12) {
                        // Название звука
                        Text(sound.name)
                            .foregroundStyle(selectedSound == sound ? .blue : .primary)
                            .fontWeight(selectedSound == sound ? .medium : .regular)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()

                        // Кнопка проигрывания
                        Button {
                            playingSound = sound
                            AudioServicesPlaySystemSound(sound.rawValue)

                            // Анимация для визуального feedback
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                playingSound = nil
                            }
                        } label: {
                            Image(systemName: playingSound == sound ? "waveform.circle.fill" : "play.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)
                                .symbolEffect(.pulse, isActive: playingSound == sound)
                        }
                        .buttonStyle(.plain)

                        // Чекмарк для выбранного звука
                        if selectedSound == sound {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.body)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        selectedSound == sound ?
                            Color.blue.opacity(0.08) : Color.clear
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if sound != SystemSound.allCases.last {
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    @Previewable @State var selectedSound: SystemSound = .bell

    List {
        Section {
            SoundPickerView(
                selectedSound: $selectedSound,
                onSoundSelected: { sound in
                    print("Selected: \(sound.name)")
                }
            )
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        } header: {
            Text("sound_picker.header")
        }
    }
    .listStyle(.insetGrouped)
}
