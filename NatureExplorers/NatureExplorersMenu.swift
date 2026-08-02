import SpriteKit
import SwiftUI

struct NatureExplorersMenu: View {
    private let games = NatureExplorerGame.allGames

    var body: some View {
        ZStack {
            NatureMenuBackground()

            GeometryReader { geo in
                let padding: CGFloat = 20
                let spacing: CGFloat = 12
                let count = min(3, max(1, Int((geo.size.width - padding * 2) / 104)))
                let columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: count)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 20)

                        Image("learningLabLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 198, maxHeight: 198)
                            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
                            .offset(y: -8)

                        Image("learningLabKids")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 490, maxHeight: 490)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)
                            .padding(.top, -170)

                        LazyVGrid(columns: columns, spacing: spacing) {
                            ForEach(games) { game in
                                NavigationLink {
                                    if game.kind == .peekaboo {
                                        NatureBarnyardGameView()
                                    } else {
                                        NatureLearningGameView(game: game)
                                    }
                                } label: {
                                    NatureGameTile(game: game)
                                        .aspectRatio(1, contentMode: .fit)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, padding)
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

struct NatureExplorerGame: Identifiable, Hashable {
    enum Kind: String, Hashable {
        case habitat, dino, space, families, size, pattern
        case peekaboo, oddOne, memory, fossil, scene, counting, clues
    }

    let kind: Kind
    let title: String
    let subtitle: String
    let image: String
    let colors: [Color]
    var id: Kind { kind }

    static let allGames: [NatureExplorerGame] = [
        .init(kind: .habitat, title: "Habitat Helpers", subtitle: "Find each creature's home.", image: "dolphin", colors: [.teal, .blue]),
        .init(kind: .dino, title: "Dino Discovery", subtitle: "Meet prehistoric friends.", image: "Triceratops", colors: [.green, .orange]),
        .init(kind: .space, title: "Space Scouts", subtitle: "Explore our sky and planets.", image: "Rocket", colors: [.indigo, .purple]),
        .init(kind: .families, title: "Animal Families", subtitle: "Match grown-ups and babies.", image: "calf", colors: [.orange, .pink]),
        .init(kind: .size, title: "Big & Little Safari", subtitle: "Compare animal sizes.", image: "blue whale", colors: [.cyan, .blue]),
        .init(kind: .pattern, title: "Nature Patterns", subtitle: "Finish the picture pattern.", image: "starfish", colors: [.purple, .pink]),
        .init(kind: .peekaboo, title: "Peekaboo Barnyard", subtitle: "Open the barn and meet animals.", image: "cow", colors: [.yellow, .orange]),
        .init(kind: .memory, title: "Explorer Memory", subtitle: "Remember the hidden picture.", image: "Telescope", colors: [.mint, .teal]),
        .init(kind: .fossil, title: "Fossil Detectives", subtitle: "Use clues to find dinosaurs.", image: "DinoBone", colors: [.brown, .orange]),
        .init(kind: .scene, title: "Where Does It Belong?", subtitle: "Sort items into their worlds.", image: "WoollyMammoth", colors: [.green, .teal]),
        .init(kind: .counting, title: "Creature Counter", subtitle: "Count a lively animal group.", image: "penguin", colors: [.blue, .mint]),
        .init(kind: .clues, title: "Who Am I?", subtitle: "Solve friendly nature clues.", image: "Smilodon", colors: [.red, .orange])
    ]
}

private struct NatureBarnyardGameView: View {
    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: makeScene(size: proxy.size))
                .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(false)
    }

    private func makeScene(size: CGSize) -> SKScene {
        let scene = BarnyardPeekabooScene(size: size)
        scene.scaleMode = .aspectFill
        return scene
    }
}

private struct NatureGameTile: View {
    let game: NatureExplorerGame

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(LinearGradient(colors: game.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(alignment: .topTrailing) {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 68, height: 68)
                    .offset(x: 16, y: -18)
            }
            .overlay {
                VStack(spacing: 5) {
                    Image(game.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 48)
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 3)

                    Text(game.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)

                    Text(game.subtitle)
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .opacity(0.9)
                        .lineLimit(2)
                }
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(7)
            }
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(game.title). \(game.subtitle)")
    }
}

private struct NatureMenuBackground: View {
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
