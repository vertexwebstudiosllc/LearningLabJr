//
//  ABCsAndPhonicsMenu.swift
//  LearningLabJr
//
//  Created by Matthew Teitelman on 12/10/25.
//

import SpriteKit
import SwiftUI

struct BigFeelingsMenu: View {
    private let games = PhonicsGame.allGames

    var body: some View {
        ZStack {
            ABCsBackgroundLayer()

            GeometryReader { geo in
                let horizontalPadding: CGFloat = 20
                let spacing: CGFloat = 12
                let columnsCount = min(3, max(1, Int((geo.size.width - horizontalPadding * 2) / 104)))
                let columns = Array(
                    repeating: GridItem(.flexible(), spacing: spacing),
                    count: columnsCount
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 20)

                        Image("learningLabLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 198, maxHeight: 198) // match MainMenu logo sizing
                            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
                            .offset(y: -8)

                        Image("learningLabKids")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 490, maxHeight: 490) // align with MainMenu hero sizing
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 6)
                            .padding(.top, -170)

                        LazyVGrid(columns: columns, spacing: spacing) {
                            ForEach(games) { game in
                                GameTileLink(game: game)
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, -145)
                        .padding(.bottom, 48)
                    }
                    .frame(minHeight: geo.size.height, alignment: .top)
                }
                .scrollBounceBehavior(.basedOnSize)
                .ignoresSafeArea(edges: .top)
            }
        }
    }
}

// MARK: - Game Tiles

private struct PhonicsGame: Identifiable {
    enum Destination {
        case letterMatch
        case letterDraw
        case soundBaskets
        case peekabooVehicle
        case placeholder
    }

    let id = UUID()
    let title: String
    let assetName: String?
    let destination: Destination
    let isLocked: Bool

    static let allGames: [PhonicsGame] = [
        PhonicsGame(title: "Letter Match", assetName: "Button-Letter-Match", destination: .letterMatch, isLocked: false),
        PhonicsGame(title: "Letter Draw", assetName: "Button-Letter-Draw", destination: .letterDraw, isLocked: true),
        PhonicsGame(title: "Sound Baskets", assetName: "Button-Sound-Basket", destination: .soundBaskets, isLocked: true),
        PhonicsGame(title: "Peekaboo Vehicle", assetName: nil, destination: .peekabooVehicle, isLocked: true),
        PhonicsGame(title: "Rhyme Time", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Letter Pop", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Word Builder", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Beginning Sounds", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Ending Sounds", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Vowel Garden", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Consonant Cove", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Syllable Hop", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Sight Word Stars", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Blend Builder", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Digraph Dash", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Letter Sounds", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Find the Word", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Trace & Say", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Phonics Puzzle", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "Story Sounds", assetName: nil, destination: .placeholder, isLocked: true),
        PhonicsGame(title: "ABC Review", assetName: nil, destination: .placeholder, isLocked: true)
    ]
}

private struct GameTileLink: View {
    let game: PhonicsGame
    @ObservedObject private var storeManager = StoreManager.shared
    @State private var showPremiumGate = false

    private var isPremiumLocked: Bool {
        game.isLocked && !storeManager.hasPremium
    }

    var body: some View {
        Group {
            if isPremiumLocked {
                Button {
                    showPremiumGate = true
                } label: {
                    GameTile(game: game, isLocked: true)
                }
                .buttonStyle(.plain)
            } else {
                NavigationLink {
                    destinationView
                } label: {
                    GameTile(game: game, isLocked: false)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showPremiumGate) {
            PremiumParentGateView()
        }
    }

    @ViewBuilder
    private var destinationView: some View {
        switch game.destination {
        case .letterMatch:
            LetterMatch()
        case .letterDraw:
            LetterDraw()
        case .soundBaskets:
            SoundBaskets()
        case .peekabooVehicle:
            PeekabooVehicleGameView()
        case .placeholder:
            ABCsPlaceholderGame(title: game.title)
        }
    }
}

private struct PeekabooVehicleGameView: View {
    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: makeScene(size: proxy.size))
                .ignoresSafeArea()
        }
    }

    private func makeScene(size: CGSize) -> SKScene {
        let scene = VehiclePeekabooScene(size: size)
        scene.scaleMode = .aspectFill
        return scene
    }
}

private struct GameTile: View {
    let game: PhonicsGame
    let isLocked: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            tileContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Circle().fill(Color.black.opacity(0.55)))
                    .padding(7)
                    .accessibilityLabel(Text("Locked"))
            }
        }
        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var tileContent: some View {
        if let assetName = game.assetName {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .aspectRatio(1, contentMode: .fit)
                .padding(2)
        } else {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.20, green: 0.55, blue: 0.95),
                            Color(red: 0.10, green: 0.78, blue: 0.72)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Text(game.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.65)
                        .padding(.horizontal, 10)
                )
        }
    }
}

private struct ABCsPlaceholderGame: View {
    let title: String

    var body: some View {
        ZStack {
            ABCsBackgroundLayer()

            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundColor(.white)

                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Coming Soon")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(24)
        }
    }
}

private struct ABCsBackgroundLayer: View {
    var body: some View {
        GeometryReader { proxy in
            let totalHeight = proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom

            ZStack(alignment: .center) {
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.78, blue: 0.42),
                        Color(red: 1.0, green: 0.68, blue: 0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(.all)

                Image("learningLabBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: totalHeight)
                    .clipped()
                    .ignoresSafeArea(.all)

                Image("PlayfulBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: totalHeight)
                    .clipped()
                    .ignoresSafeArea(.all)
            }
        }
    }
}

#Preview {
    BigFeelingsMenu()
}
