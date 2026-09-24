import SwiftUI

/// Exhaust a picture collection before using it again, including across difficulty steps.
/// Avoid the last two pictures at a refill so three-round practice groups stay distinct.
func countingPictureCycle<Item: Identifiable>(_ bank: [Item], count: Int) -> [Item] {
    precondition(bank.count >= 3 && Set(bank.map(\.id)).count == bank.count)
    var result: [Item] = []
    var remaining: [Item] = []
    for _ in 0..<count {
        if remaining.isEmpty { remaining = bank.shuffled() }
        let recent = Set(result.suffix(2).map(\.id))
        let index = remaining.firstIndex { !recent.contains($0.id) } ?? 0
        result.append(remaining.remove(at: index))
    }
    return result
}

struct CountingTheme: Identifiable {
    let id: String
    let asset: String
    let color: Color
    let petals: Int
    let scenery: String
    static let bank: [Self] = [
        .init(id: "sunshine", asset: "Space/Sun", color: .orange, petals: 8, scenery: "sun.max.fill"),
        .init(id: "moonlight", asset: "Space/Moon", color: .indigo, petals: 5, scenery: "moon.stars.fill"),
        .init(id: "starry", asset: "Space/Star", color: .pink, petals: 6, scenery: "sparkles"),
        .init(id: "rocket", asset: "Space/Rocket", color: .red, petals: 4, scenery: "cloud.fill"),
        .init(id: "earth", asset: "Space/Earth", color: .teal, petals: 10, scenery: "tree.fill"),
        .init(id: "saturn", asset: "Space/Saturn", color: .purple, petals: 7, scenery: "mountain.2.fill"),
        .init(id: "rainbow", asset: "duck", color: .yellow, petals: 9, scenery: "rainbow"),
        .init(id: "meadow", asset: "rabbit", color: .mint, petals: 12, scenery: "leaf.fill")
    ]
}

/// One complete flower per counting space, with a stable style for the entire round.
struct CountingFlower: View {
    let theme: CountingTheme
    var body: some View {
        ZStack {
            Capsule().fill(.green).frame(width: 3, height: 24).offset(y: 9)
            Ellipse().fill(.green).frame(width: 13, height: 6).rotationEffect(.degrees(-30)).offset(x: 5, y: 12)
            ForEach(0..<theme.petals, id: \.self) { petal in
                Ellipse().fill(theme.color).frame(width: 9, height: 17).offset(y: -8)
                    .rotationEffect(.degrees(Double(petal) * 360 / Double(theme.petals)))
                    .offset(y: -5)
            }
            Circle().fill(.yellow).overlay(Circle().stroke(.orange, lineWidth: 1)).frame(width: 10, height: 10).offset(y: -5)
        }.frame(width: 38, height: 46).accessibilityHidden(true)
    }
}

struct CountingPond: View {
    let theme: CountingTheme
    let progress: Double
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 22).fill(theme.color.opacity(0.12))
                HStack {
                    Image(systemName: theme.scenery).font(.system(size: 34)).foregroundStyle(theme.color)
                    Spacer()
                    Image(systemName: theme.scenery).font(.system(size: 28)).foregroundStyle(theme.color.opacity(0.7))
                }.padding(14).frame(maxHeight: .infinity, alignment: .top)
                Ellipse().fill(.cyan.opacity(0.4)).frame(width: 82, height: 28).offset(x: geometry.size.width / 2 - 52, y: -8)
                Text("🐸").font(.system(size: 48))
                    .position(x: 32 + progress * max(0, geometry.size.width - 84), y: 72)
            }
        }.frame(height: 112).accessibilityHidden(true)
    }
}

/// Sample unordered fruit pairs without replacement; avoid sharing a fruit with
/// the previous round whenever possible. Swapping group positions isn't a new pair.
func countingFruitPairs(count: Int) -> [(NumberPicnicFood, NumberPicnicFood)] {
    let bank = NumberPicnicFood.bank
    let allPairs = bank.indices.flatMap { i in
        bank.indices.filter { $0 > i }.map { (bank[i], bank[$0]) }
    }
    var pool = allPairs.shuffled()
    var result: [(NumberPicnicFood, NumberPicnicFood)] = []
    for _ in 0..<count {
        if pool.isEmpty { pool = allPairs.shuffled() }
        let recent = result.last.map { Set([$0.0.id, $0.1.id]) } ?? []
        let index = pool.firstIndex { !recent.contains($0.0.id) && !recent.contains($0.1.id) }
            ?? pool.firstIndex { Set([$0.0.id, $0.1.id]) != recent } ?? 0
        let pair = pool.remove(at: index)
        result.append(Bool.random() ? pair : (pair.1, pair.0))
    }
    return result
}
