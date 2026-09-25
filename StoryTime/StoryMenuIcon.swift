import SwiftUI

/// Activity-specific silhouettes with the same scale and accent treatment as Nature's tiles.
struct StoryMenuIcon: View {
    let activity: StoryActivity

    var body: some View {
        GeometryReader { geometry in
            drawing.frame(width: 100, height: 100)
                .scaleEffect(min(geometry.size.width, geometry.size.height) / 100)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    @ViewBuilder private var drawing: some View {
        switch activity {
        case .library:
            symbol("book.fill", size: 88)
        case .pictureHunt:
            ZStack {
                Circle().stroke(lineWidth: 8).frame(width: 62, height: 62).offset(x: -10, y: -10)
                symbol("cup.and.saucer.fill", size: 34).offset(x: -10, y: -10)
                Capsule().frame(width: 11, height: 39).rotationEffect(.degrees(-45)).offset(x: 27, y: 27)
            }
        case .storyOrder:
            VStack(spacing: 9) {
                HStack(spacing: 5) {
                    ForEach(1...3, id: \.self) { number in
                        Text("\(number)").font(.system(size: 22, weight: .bold, design: .rounded))
                            .frame(width: 28, height: 40)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(lineWidth: 3))
                    }
                }
                symbol("arrow.right", size: 38).frame(height: 20)
            }
        case .puppets:
            HStack(spacing: 7) {
                puppet(tilt: -10)
                puppet(tilt: 10)
            }
        case .finishSentence:
            ZStack {
                symbol("bubble.left.fill", size: 90)
                HStack(spacing: 5) {
                    ForEach(0..<2) { _ in Capsule().frame(width: 15, height: 5) }
                    RoundedRectangle(cornerRadius: 3).stroke(style: StrokeStyle(lineWidth: 2, dash: [3, 2])).frame(width: 20, height: 22)
                }.foregroundStyle(.white).offset(y: -5)
            }
        case .soundStory:
            ZStack {
                symbol("book.fill", size: 69).offset(x: -12, y: 15)
                symbol("speaker.wave.2.fill", size: 42).offset(x: 24, y: -25)
            }
        case .storyBag:
            ZStack {
                symbol("bag.fill", size: 78).offset(y: 12)
                symbol("star.fill", size: 26).offset(x: -26, y: -34)
                symbol("sparkle", size: 24).offset(x: 25, y: -32)
                symbol("hare.fill", size: 32).foregroundStyle(.white).offset(y: 24)
            }
        case .sillyScene:
            ZStack {
                symbol("shoe.fill", size: 59).rotationEffect(.degrees(-15)).offset(x: -13, y: -22)
                symbol("arrow.down", size: 26).offset(x: 29, y: 5)
                symbol("fork.knife", size: 42).offset(x: -8, y: 27)
            }
        case .bunny:
            ZStack {
                symbol("hare.fill", size: 63).offset(y: -19)
                RoundedRectangle(cornerRadius: 5).frame(width: 82, height: 41).offset(y: 25)
                Path { p in
                    p.move(to: CGPoint(x: 12, y: 59)); p.addLine(to: CGPoint(x: 88, y: 59))
                    p.move(to: CGPoint(x: 50, y: 59)); p.addLine(to: CGPoint(x: 50, y: 93))
                }.stroke(.white, lineWidth: 3)
            }
        case .conversation:
            VStack(spacing: 0) {
                symbol("bubble.left.and.bubble.right.fill", size: 67).frame(height: 53)
                symbol("basket.fill", size: 48).frame(height: 43)
            }
        case .storyChoices:
            ZStack {
                symbol("arrow.triangle.branch", size: 70).offset(y: 12)
                symbol("leaf.fill", size: 29).offset(x: -30, y: -34)
                symbol("water.waves", size: 29).offset(x: 30, y: -34)
            }
        case .sentenceBuilder:
            HStack(spacing: 5) {
                wordTile("hare.fill")
                wordTile("eye.fill")
                wordTile("book.fill")
            }
        }
    }

    private func symbol(_ name: String, size: CGFloat) -> some View {
        Image(systemName: name).resizable().scaledToFit().frame(width: size, height: size)
    }

    private func wordTile(_ name: String) -> some View {
        symbol(name, size: 21).frame(width: 28, height: 43)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(lineWidth: 3))
    }

    private func puppet(tilt: Double) -> some View {
        ZStack {
            Capsule().frame(width: 5, height: 34).offset(y: 31)
            RoundedRectangle(cornerRadius: 13).frame(width: 38, height: 45).offset(y: 1)
            Circle().frame(width: 40, height: 40).offset(y: -22)
            HStack(spacing: 10) {
                Circle().frame(width: 5, height: 5)
                Circle().frame(width: 5, height: 5)
            }.foregroundStyle(.white).offset(y: -25)
            Capsule().fill(.white).frame(width: 12, height: 3).offset(y: -14)
        }.frame(width: 43, height: 94).rotationEffect(.degrees(tilt))
    }
}
