import SwiftUI

/// A consistent game card used by each learning-section menu.
struct SharedGameTile: View {
    let title: String
    let icon: String

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
        let value = title.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return Self.palettes[value % Self.palettes.count]
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
