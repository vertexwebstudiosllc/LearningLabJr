//
//  CountingMenu.swift
//  LearningLabJr
//
//  Created by Matthew Teitelman on 12/10/25.
//

import SwiftUI

struct CountingMenu: View {
    private let games = CountingGame.allGames

    var body: some View {
        ZStack {
            CountingBackgroundLayer()

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
                            .frame(maxWidth: 198, maxHeight: 198)
                            .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
                            .offset(y: -8)

                        Image("learningLabKids")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 490, maxHeight: 490)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 6)
                            .padding(.top, -170)

                        LazyVGrid(columns: columns, spacing: spacing) {
                            ForEach(games) { game in
                                CountingGameTileLink(game: game)
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

private struct CountingGame: Identifiable {
    enum Destination {
        case animalParade
        case snackStack
        case toyTrain
        case farmyardFriends
        case rocketLaunch
        case bubbleCount
        case treasureChest
        case balloonPop
        case cookieJar
        case oceanCount
        case spaceStars
        case dinosaurDash
    }

    let id = UUID()
    let title: String
    let destination: Destination
    let accentColors: [Color]

    static let allGames: [CountingGame] = [
        CountingGame(title: "Animal Parade", destination: .animalParade, accentColors: [.orange, .pink]),
        CountingGame(title: "Snack Stack", destination: .snackStack, accentColors: [.green, .mint]),
        CountingGame(title: "Toy Train", destination: .toyTrain, accentColors: [.blue, .cyan]),
        CountingGame(title: "Farmyard Friends", destination: .farmyardFriends, accentColors: [.red, .purple]),
        CountingGame(title: "Rocket Launch", destination: .rocketLaunch, accentColors: [.indigo, .teal]),
        CountingGame(title: "Bubble Count", destination: .bubbleCount, accentColors: [.pink, .purple]),
        CountingGame(title: "Treasure Chest", destination: .treasureChest, accentColors: [.yellow, .orange]),
        CountingGame(title: "Balloon Pop", destination: .balloonPop, accentColors: [.teal, .blue]),
        CountingGame(title: "Cookie Jar", destination: .cookieJar, accentColors: [.brown, .orange]),
        CountingGame(title: "Ocean Count", destination: .oceanCount, accentColors: [.cyan, .blue]),
        CountingGame(title: "Space Stars", destination: .spaceStars, accentColors: [.purple, .indigo]),
        CountingGame(title: "Dinosaur Dash", destination: .dinosaurDash, accentColors: [.green, .yellow])
    ]
}

private struct CountingGameTileLink: View {
    let game: CountingGame

    var body: some View {
        NavigationLink {
            destinationView
        } label: {
            CountingGameTile(game: game)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var destinationView: some View {
        switch game.destination {
        case .animalParade:
            CountingChallengeView(
                title: "Animal Parade",
                prompt: "Count the animals and choose the matching number.",
                instructions: "Tap the number that matches how many animals you see.",
                assetNames: ["cat", "dog", "duck"],
                answer: 3,
                accentColors: game.accentColors
            )
        case .snackStack:
            CountingChallengeView(
                title: "Snack Stack",
                prompt: "Count the yummy snacks before the next bite.",
                instructions: "Pick the number that shows how many snacks are stacked.",
                assetNames: ["Apple", "Cookie", "Milk"],
                answer: 4,
                accentColors: game.accentColors
            )
        case .toyTrain:
            CountingChallengeView(
                title: "Toy Train",
                prompt: "Count the cars on the toy train.",
                instructions: "Choose the number that matches the train cars.",
                assetNames: ["duck", "turtle", "cow"],
                answer: 5,
                accentColors: game.accentColors
            )
        case .farmyardFriends:
            CountingChallengeView(
                title: "Farmyard Friends",
                prompt: "Count the friendly farm animals.",
                instructions: "Find the number that matches the animals in the barn.",
                assetNames: ["cow", "pig", "sheep"],
                answer: 2,
                accentColors: game.accentColors
            )
        case .rocketLaunch:
            CountingChallengeView(
                title: "Rocket Launch",
                prompt: "Count the rockets ready for takeoff.",
                instructions: "Tap the number that matches the rockets.",
                assetNames: ["groceryBag", "Milk", "Apple"],
                answer: 3,
                accentColors: game.accentColors
            )
        case .bubbleCount:
            CountingChallengeView(
                title: "Bubble Count",
                prompt: "Pop the bubbles by counting them carefully.",
                instructions: "Choose the correct bubble count.",
                assetNames: ["cat", "dog", "duck"],
                answer: 6,
                accentColors: game.accentColors
            )
        case .treasureChest:
            CountingChallengeView(
                title: "Treasure Chest",
                prompt: "Count the shiny treasures in the chest.",
                instructions: "Pick the number that matches the treasure pile.",
                assetNames: ["Apple", "Milk", "Cookie"],
                answer: 4,
                accentColors: game.accentColors
            )
        case .balloonPop:
            CountingChallengeView(
                title: "Balloon Pop",
                prompt: "Count the balloons floating in the sky.",
                instructions: "Select the correct balloon count.",
                assetNames: ["Milk", "Apple", "Cookie"],
                answer: 5,
                accentColors: game.accentColors
            )
        case .cookieJar:
            CountingChallengeView(
                title: "Cookie Jar",
                prompt: "Count the cookies in the jar.",
                instructions: "Tap the number that matches the cookies.",
                assetNames: ["Cookie", "Apple", "Milk"],
                answer: 2,
                accentColors: game.accentColors
            )
        case .oceanCount:
            CountingChallengeView(
                title: "Ocean Count",
                prompt: "Count the sea creatures swimming by.",
                instructions: "Choose the number that matches the ocean friends.",
                assetNames: ["duck", "cow", "pig"],
                answer: 3,
                accentColors: game.accentColors
            )
        case .spaceStars:
            CountingChallengeView(
                title: "Space Stars",
                prompt: "Count the stars shining in the sky.",
                instructions: "Select the number that matches the stars.",
                assetNames: ["cat", "dog", "duck"],
                answer: 1,
                accentColors: game.accentColors
            )
        case .dinosaurDash:
            CountingChallengeView(
                title: "Dinosaur Dash",
                prompt: "Count the dinosaurs hurrying across the field.",
                instructions: "Tap the number that matches the dinosaurs.",
                assetNames: ["cow", "pig", "sheep"],
                answer: 6,
                accentColors: game.accentColors
            )
        }
    }
}

private struct CountingGameTile: View {
    let game: CountingGame

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(
                LinearGradient(
                    colors: game.accentColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                VStack(spacing: 10) {
                    Image(systemName: "number.circle.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text(game.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 10)
                }
            )
            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
            .contentShape(Rectangle())
    }
}

private struct CountingChallengeView: View {
    let title: String
    let prompt: String
    let instructions: String
    let assetNames: [String]
    let answer: Int
    let accentColors: [Color]

    @State private var selectedAnswer: Int?

    var body: some View {
        ZStack {
            CountingBackgroundLayer()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text(title)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)

                    Text(prompt)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Text(instructions)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: min(3, max(1, answer))), spacing: 12) {
                        ForEach(0..<answer, id: \ .self) { index in
                            Image(assetNames[index % assetNames.count])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal, 8)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(1...6, id: \ .self) { number in
                            Button {
                                selectedAnswer = number
                            } label: {
                                Text("\(number)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .frame(maxWidth: .infinity, minHeight: 58)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(number == selectedAnswer ? Color.white.opacity(0.95) : Color.white.opacity(0.75))
                                    )
                                    .foregroundColor(number == selectedAnswer ? .indigo : .black)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)

                    if let selectedAnswer {
                        Text(selectedAnswer == answer ? "You got it!" : "Try another number.")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 4)
                    }

                    Button {
                        selectedAnswer = nil
                    } label: {
                        Text("Reset")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.white.opacity(0.18)))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CountingBackgroundLayer: View {
    var body: some View {
        GeometryReader { proxy in
            let totalHeight = proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom

            ZStack(alignment: .center) {
                LinearGradient(
                    colors: [
                        Color(red: 0.92, green: 0.55, blue: 0.62),
                        Color(red: 0.60, green: 0.30, blue: 0.86)
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
    CountingMenu()
}
