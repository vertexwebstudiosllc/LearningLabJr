import SwiftUI

/// Explicit artwork choices for literacy words. Never falls back to an opaque legacy sprite.
struct LiteracyVocabularyArt: View {
    let word: String
    private var key: String { word.lowercased() == "teddy bear" ? "teddy" : word.lowercased() }
    static let cleanAssets = [
        "chicken": "FamilyClean/chicken", "dolphin": "dolphinClean",
        "cat": "FamilyClean/cat", "dog": "FamilyClean/dog", "cow": "FamilyClean/cow",
        "hen": "FamilyClean/chicken", "chick": "FamilyClean/chick", "lamb": "FamilyClean/lamb",
        "sheep": "FamilyClean/sheep", "horse": "FamilyClean/horse", "goat": "BarnClean/goat",
        "pig": "BarnClean/pig", "rabbit": "BarnClean/rabbit", "duck": "BarnClean/duck",
        "crab": "OceanClean/crab", "seal": "OceanClean/seal", "shark": "OceanClean/shark",
        "whale": "OceanClean/whale", "lobster": "OceanClean/lobster", "jellyfish": "OceanClean/jellyfish",
        "sun": "SpaceClean/Sun", "moon": "SpaceClean/Moon", "earth": "SpaceClean/Earth"
    ]
    static let foods: Set<String> = ["strawberry", "apple", "egg", "kiwi", "lemon", "milk", "noodles", "orange", "yogurt", "zucchini", "watermelon", "pear", "bread", "carrot", "cheese"]
    // Platform illustrations are true transparent glyphs, not rectangular image files.
    static let illustrations = [
        "donkey": "🫏", "penguin": "🐧", "octopus": "🐙", "banana": "🍌",
        "potato": "🥔", "pineapple": "🍍", "cucumber": "🥒",
        "alpaca": "🦙", "llama": "🦙", "broccoli": "🥦", "hamburger": "🍔",
        "krill": "🦐", "pizza": "🍕", "rooster": "🐓", "tomato": "🍅",
        "volcano": "🌋", "mouse": "🐁", "corn": "🌽", "rice": "🍚", "peas": "🫛",
        "peach": "🍑", "goose": "🪿", "beef": "🥩", "onion": "🧅",
        "mango": "🥭", "bagel": "🥯"
    ]
    static let transparentVehicles = ["excavator": "excavator", "yellow truck": "truckYellow", "football": "football"]
    static func supports(_ word: String) -> Bool {
        let key = word.lowercased() == "teddy bear" ? "teddy" : word.lowercased()
        return cleanAssets[key] != nil || foods.contains(key) || illustrations[key] != nil || transparentVehicles[key] != nil
            || ["blueberry", "raspberry", "jam", "soup", "clam", "grape", "toast", "pasta", "plum", "lime", "eel", "orca", "walrus", "fish", "basketball", "volleyball", "turtle"].contains(key)
            || HuntItem.bank.contains { $0.id == key }
    }
    var body: some View {
        GeometryReader { geometry in
            art.frame(width: 100, height: 100)
                .scaleEffect(min(geometry.size.width, geometry.size.height) / 100)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }.accessibilityHidden(true)
    }
    @ViewBuilder private var art: some View {
        if let asset = Self.cleanAssets[key] { Image(asset).resizable().scaledToFit() }
        else if let asset = Self.transparentVehicles[key] { Image(asset).resizable().scaledToFit() }
        else if Self.foods.contains(key) { LiteracyFoodArt(food: key) }
        else if let glyph = Self.illustrations[key] { Text(glyph).font(.system(size: 76)).minimumScaleFactor(0.5) }
        else {
            switch key {
            case "blueberry", "raspberry":
                ZStack {
                    if key == "blueberry" {
                        Circle().fill(.indigo).frame(width: 77, height: 77)
                        Image(systemName: "star.fill").font(.system(size: 23)).foregroundStyle(.blue).offset(y: -22)
                        Ellipse().fill(.white.opacity(0.3)).frame(width: 16, height: 25).rotationEffect(.degrees(30)).offset(x: -20, y: -9)
                    } else {
                        ForEach(0..<4) { row in
                            ForEach(0..<(4-row), id: \.self) { column in
                                Circle().fill(Color(red: 0.85, green: 0.09, blue: 0.3))
                                    .frame(width: 24, height: 24)
                                    .overlay(Circle().stroke(.pink.opacity(0.65), lineWidth: 2))
                                    .position(x: CGFloat(17 + row * 11 + column * 22), y: CGFloat(28 + row * 18))
                            }
                        }
                        Image(systemName: "leaf.fill").font(.system(size: 27)).foregroundStyle(.green).offset(y: -38)
                    }
                }
            case "jam":
                ZStack {
                    RoundedRectangle(cornerRadius: 12).fill(.pink).frame(width: 62, height: 64).offset(y: 12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.purple, lineWidth: 3).frame(width: 62, height: 64).offset(y: 12))
                    RoundedRectangle(cornerRadius: 5).fill(.purple).frame(width: 68, height: 15).offset(y: -25)
                    Circle().fill(.white).frame(width: 37).offset(y: 12)
                    Text("🍓").font(.system(size: 26)).offset(y: 12)
                }
            case "soup":
                ZStack {
                    Path { p in p.move(to: CGPoint(x: 9, y: 47)); p.addLine(to: CGPoint(x: 91, y: 47)); p.addQuadCurve(to: CGPoint(x: 9, y: 47), control: CGPoint(x: 50, y: 130)); p.closeSubpath() }.fill(.blue)
                    Ellipse().fill(.orange).frame(width: 82, height: 26).offset(y: -3)
                    ForEach(0..<3) { i in Circle().fill(.green).frame(width: 7).position(x: CGFloat(29+i*20), y: CGFloat(i == 1 ? 43 : 51)) }
                    Capsule().fill(.gray).frame(width: 7, height: 46).rotationEffect(.degrees(30)).offset(x: 27, y: -24)
                }
            case "clam":
                ZStack {
                    Ellipse().fill(.brown).frame(width: 85, height: 37).offset(y: 9)
                    Ellipse().fill(Color(red: 1, green: 0.83, blue: 0.66)).frame(width: 75, height: 26).offset(y: 6)
                    Ellipse().fill(Color(red: 0.84, green: 0.65, blue: 0.4)).frame(width: 82, height: 37).rotationEffect(.degrees(-18)).offset(y: -15)
                    ForEach(0..<5) { i in
                        Capsule().fill(.brown.opacity(0.4)).frame(width: 3, height: 23).rotationEffect(.degrees(Double(i-2)*16)).offset(x: CGFloat(i-2)*12, y: -15)
                    }
                }
            case "grape": LiteracyFoodArt(food: "grapes")
            case "toast": LiteracyFoodArt(food: "bread")
            case "pasta": LiteracyFoodArt(food: "noodles")
            case "plum", "lime":
                ZStack {
                    Ellipse().fill(key == "plum" ? Color.purple : Color.green).frame(width: 73, height: 81).offset(y: 5)
                    Capsule().fill(.brown).frame(width: 6, height: 16).offset(y: -36)
                    Image(systemName: "leaf.fill").font(.system(size: 25)).foregroundStyle(.green).offset(x: 14, y: -31)
                }
            case "eel":
                ZStack {
                    Path { p in p.move(to: CGPoint(x: 18, y: 23)); p.addCurve(to: CGPoint(x: 74, y: 80), control1: CGPoint(x: 100, y: 7), control2: CGPoint(x: 0, y: 105)) }
                        .stroke(.teal, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    Circle().fill(.white).frame(width: 8).position(x: 19, y: 18)
                    Circle().fill(.black).frame(width: 4).position(x: 19, y: 18)
                }
            case "orca":
                ZStack {
                    Ellipse().fill(.black).frame(width: 76, height: 43).offset(x: 7, y: 8)
                    Ellipse().fill(.white).frame(width: 51, height: 17).offset(x: 9, y: 22)
                    Ellipse().fill(.white).frame(width: 13, height: 8).rotationEffect(.degrees(-20)).offset(x: 30, y: 4)
                    Image(systemName: "triangle.fill").font(.system(size: 30)).offset(x: 0, y: -17)
                    Image(systemName: "triangle.fill").font(.system(size: 27)).rotationEffect(.degrees(90)).offset(x: -36, y: 4)
                }
            case "walrus":
                ZStack {
                    Ellipse().fill(.brown).frame(width: 79, height: 62).offset(y: 15)
                    Circle().fill(.brown).frame(width: 63).offset(y: -12)
                    HStack(spacing: 19) { Circle().frame(width: 6); Circle().frame(width: 6) }.offset(y: -23)
                    Ellipse().fill(.black).frame(width: 14, height: 9).offset(y: -8)
                    HStack(spacing: 13) { Capsule().fill(.white).frame(width: 7, height: 35); Capsule().fill(.white).frame(width: 7, height: 35) }.offset(y: 14)
                }
            case "fish": Image(systemName: "fish.fill").resizable().scaledToFit().foregroundStyle(.teal)
            case "basketball", "ball": Image(systemName: "basketball.fill").resizable().scaledToFit().foregroundStyle(.orange)
            case "volleyball": Image(systemName: "volleyball.fill").resizable().scaledToFit().foregroundStyle(.blue)
            case "turtle": Image(systemName: "tortoise.fill").resizable().scaledToFit().foregroundStyle(.green)
            default:
                if let item = HuntItem.bank.first(where: { $0.id == key }) { HuntItemArt(item: item) }
            }
        }
    }
}
