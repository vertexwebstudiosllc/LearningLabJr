import SwiftUI

enum GameTileCategory: Int {
    case phonics, shapes, nature, stories, feelings
}

/// A consistent game card used by each learning-section menu.
struct SharedGameTile: View {
    let title: String
    let category: GameTileCategory

    private static let palettes: [[Color]] = [
        [.orange, .pink],
        [.blue, .cyan],
        [.green, .mint],
        [.purple, .indigo],
        [.yellow, .orange],
        [.teal, .blue],
        [.pink, .purple],
        [.red, .orange]
    ]

    private var colors: [Color] {
        let value = title.unicodeScalars.reduce(category.rawValue * 3) { $0 + Int($1.value) }
        return Self.palettes[value % Self.palettes.count]
    }

    private var icon: String {
        let name = title.lowercased()

        if name.contains("match") { return "rectangle.on.rectangle.angled" }
        if name.contains("draw") || name.contains("trace") { return "pencil.and.outline" }
        if name.contains("basket") { return "basket.fill" }
        if name.contains("peekaboo") { return "eye.fill" }
        if name.contains("vehicle") { return "car.fill" }
        if name.contains("barnyard") { return "pawprint.fill" }
        if name.contains("food") { return "fork.knife" }
        if name.contains("claw") { return "arcade.stick.console.fill" }
        if name.contains("builder") || name.contains("blend") { return "hammer.fill" }
        if name.contains("beginning") { return "speaker.wave.1.fill" }
        if name.contains("ending") { return "speaker.wave.3.fill" }
        if name.contains("alphabet") || name.contains("abc") { return "textformat.abc" }
        if name.contains("vowel") { return "a.circle.fill" }
        if name.contains("consonant") { return "b.circle.fill" }
        if name.contains("syllable") || name.contains("hop") { return "figure.jumprope" }
        if name.contains("rhyme") { return "music.note.list" }
        if name.contains("pop") { return "bubble.left.and.bubble.right.fill" }
        if name.contains("sight") || name.contains("star") { return "star.fill" }
        if name.contains("digraph") || name.contains("dash") { return "hare.fill" }
        if name.contains("sound") { return "waveform.circle.fill" }
        if name.contains("find") { return "magnifyingglass.circle.fill" }
        if name.contains("puzzle") { return "puzzlepiece.fill" }
        if name.contains("review") { return "checkmark.seal.fill" }
        if name.contains("train") { return "tram.fill" }
        if name.contains("adventure") { return "map.fill" }
        if name.contains("onion") || name.contains("volume") { return "book.pages.fill" }

        switch category {
        case .phonics: return "character.book.closed.fill"
        case .shapes: return shapeIcon
        case .nature: return natureIcon
        case .stories: return storyIcon
        case .feelings: return feelingIcon
        }
    }

    private var shapeIcon: String {
        let icons = ["circle.fill", "triangle.fill", "square.fill", "paintpalette.fill", "hexagon.fill"]
        return icons[styleIndex % icons.count]
    }

    private var natureIcon: String {
        let icons = ["leaf.fill", "ladybug.fill", "bird.fill", "tree.fill", "sun.max.fill"]
        return icons[styleIndex % icons.count]
    }

    private var storyIcon: String {
        let icons = ["book.fill", "text.book.closed.fill", "books.vertical.fill", "moon.stars.fill", "wand.and.stars"]
        return icons[styleIndex % icons.count]
    }

    private var feelingIcon: String {
        let icons = ["heart.fill", "face.smiling.fill", "hands.sparkles.fill", "rainbow", "person.2.fill"]
        return icons[styleIndex % icons.count]
    }

    private var styleIndex: Int {
        title.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .bold))

                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.65)
                        .padding(.horizontal, 10)
                }
                .foregroundStyle(.white)
                .padding(8)
            }
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
            .contentShape(Rectangle())
            .accessibilityElement(children: .combine)
    }
}
