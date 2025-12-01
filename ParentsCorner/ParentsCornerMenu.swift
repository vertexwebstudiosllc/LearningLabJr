//
//  ParentsCornerMenu.swift
//  LearningLabJr
//
//  Created by Matthew Teitelman on 12/10/25.
//

import SwiftUI

struct ParentsCornerMenu: View {
    @AppStorage("parents.soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("parents.voicePromptsEnabled") private var voicePromptsEnabled = true
    @AppStorage("parents.backgroundMusicEnabled") private var backgroundMusicEnabled = false
    @AppStorage("parents.autoAdvanceEnabled") private var autoAdvanceEnabled = false
    @AppStorage("parents.sessionMinutes") private var sessionMinutes = 15.0
    @AppStorage("parents.difficulty") private var difficulty = ParentDifficulty.gentle.rawValue

    var body: some View {
        ZStack {
            ParentsBackgroundLayer()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Image("learningLabLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 170, maxHeight: 170)
                        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
                        .padding(.top, 12)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Parents Corner")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Options")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        OptionToggleRow(
                            title: "Sound Effects",
                            systemImage: "speaker.wave.2.fill",
                            isOn: $soundEffectsEnabled
                        )

                        OptionToggleRow(
                            title: "Voice Prompts",
                            systemImage: "waveform",
                            isOn: $voicePromptsEnabled
                        )

                        OptionToggleRow(
                            title: "Background Music",
                            systemImage: "music.note",
                            isOn: $backgroundMusicEnabled
                        )

                        OptionToggleRow(
                            title: "Auto Advance",
                            systemImage: "forward.fill",
                            isOn: $autoAdvanceEnabled
                        )
                    }
                    .padding(.horizontal, 18)

                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label("Session Length", systemImage: "timer")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)

                                Spacer()

                                Text("\(Int(sessionMinutes)) min")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }

                            Slider(value: $sessionMinutes, in: 5...30, step: 5)
                                .tint(.white)
                        }
                        .padding(16)
                        .background(Color.black.opacity(0.22))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                        VStack(alignment: .leading, spacing: 10) {
                            Label("Difficulty", systemImage: "dial.medium.fill")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Picker("Difficulty", selection: $difficulty) {
                                ForEach(ParentDifficulty.allCases) { level in
                                    Text(level.title).tag(level.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(16)
                        .background(Color.black.opacity(0.22))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 32)
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .navigationTitle("Parents Corner")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private enum ParentDifficulty: String, CaseIterable, Identifiable {
    case gentle
    case growing
    case challenge

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gentle:
            "Gentle"
        case .growing:
            "Growing"
        case .challenge:
            "Challenge"
        }
    }
}

private struct OptionToggleRow: View {
    let title: String
    let systemImage: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label(title, systemImage: systemImage)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .tint(.green)
        .padding(16)
        .background(Color.black.opacity(0.22))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ParentsBackgroundLayer: View {
    var body: some View {
        GeometryReader { proxy in
            let totalHeight = proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom

            ZStack(alignment: .center) {
                LinearGradient(
                    colors: [
                        Color(red: 0.18, green: 0.52, blue: 0.62),
                        Color(red: 0.12, green: 0.36, blue: 0.52)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(.all)

                Image("PlayfulBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: totalHeight)
                    .clipped()
                    .opacity(0.65)
                    .ignoresSafeArea(.all)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ParentsCornerMenu()
    }
}
