import SwiftUI

struct BuddyBodySpot: Identifiable {
    let part: BuddyPart
    let side: Int
    let x: CGFloat
    let y: CGFloat
    var width: CGFloat = 46
    var height: CGFloat = 46
    var id: String { part.rawValue + "." + String(side) }
    func rect(scale: CGFloat) -> CGRect {
        let w = max(44, width * scale), h = max(44, height * scale)
        return CGRect(x: x * scale - w / 2, y: y * scale - h / 2, width: w, height: h)
    }
    static let all: [BuddyBodySpot] = [
        .init(part: .head, side: 0, x: 170, y: 25, width: 95),
        .init(part: .eyes, side: 0, x: 133, y: 80), .init(part: .eyes, side: 1, x: 207, y: 80),
        .init(part: .ears, side: 0, x: 73, y: 135), .init(part: .ears, side: 1, x: 267, y: 135),
        .init(part: .nose, side: 0, x: 170, y: 135),
        .init(part: .mouth, side: 0, x: 170, y: 190, width: 76),
        .init(part: .hands, side: 0, x: 57, y: 290, width: 57, height: 60),
        .init(part: .hands, side: 1, x: 283, y: 290, width: 57, height: 60),
        .init(part: .tummy, side: 0, x: 170, y: 275, width: 88, height: 70),
        .init(part: .knees, side: 0, x: 134, y: 377), .init(part: .knees, side: 1, x: 206, y: 377),
        .init(part: .feet, side: 0, x: 125, y: 443, width: 68, height: 50),
        .init(part: .feet, side: 1, x: 215, y: 443, width: 68, height: 50)
    ]
}

struct BodyBuddyPicture: View {
    let buddy: BodyBuddy
    let highlight: BuddyPart?
    let solved: Bool
    let onTap: (BuddyPart) -> Void
    var body: some View {
        GeometryReader { g in
            let scale = g.size.width / 340
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 28).fill(Color.cyan.opacity(0.08))
                BodyBuddyDrawing(buddy: buddy).frame(width: 340, height: 480)
                    .scaleEffect(scale, anchor: .topLeading).allowsHitTesting(false).accessibilityHidden(true)
                ForEach(BuddyBodySpot.all) { spot in
                    let rect = spot.rect(scale: scale)
                    Button { onTap(spot.part) } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(highlight == spot.part ? (solved ? Color.green : .orange).opacity(0.18) : .clear)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(highlight == spot.part ? (solved ? Color.green : .orange) : Color.indigo.opacity(0.8), lineWidth: 3))
                            .contentShape(Rectangle())
                    }.buttonStyle(.plain)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                        .accessibilityLabel(spot.part.title)
                        .accessibilityHint("Choose this part of \(buddy.name)'s picture")
                        .accessibilityIdentifier("body.part.\(spot.id)")
                }
            }
        }.aspectRatio(340.0 / 480.0, contentMode: .fit).frame(maxWidth: 390)
            .accessibilityElement(children: .contain)
    }
}

struct BodyBuddyDrawing: View {
    let buddy: BodyBuddy
    private var skin: Color { .sportsRGB(buddy.skin) }
    private var hair: Color { .sportsRGB(buddy.hair) }
    private var shirt: Color { .sportsRGB(buddy.shirt) }
    var body: some View {
        ZStack {
            Ellipse().fill(.teal.opacity(0.1)).frame(width: 190, height: 20).position(x: 170, y: 460)
            // Long hair stays behind the ears and face so every clue remains visible.
            if [.long, .braid, .waves].contains(buddy.style) {
                RoundedRectangle(cornerRadius: 65).fill(hair).frame(width: 174, height: 226).position(x: 170, y: 119)
            }
            ForEach([134.0, 206.0], id: \.self) { x in
                Capsule().fill(skin).frame(width: 39, height: 120).position(x: x, y: 378)
                Ellipse().stroke(.brown.opacity(0.35), lineWidth: 2).frame(width: 22, height: 12).position(x: x, y: 377)
                RoundedRectangle(cornerRadius: 14).fill(.indigo).frame(width: 48, height: 54).position(x: x, y: 335)
                Ellipse().fill(skin).frame(width: 62, height: 29).position(x: x == 134 ? 125 : 215, y: 443)
                ForEach(0..<4) { toe in
                    Circle().fill(skin).frame(width: CGFloat(10 - toe), height: CGFloat(10 - toe))
                        .position(x: x == 134 ? 103 + Double(toe) * 8 : 237 - Double(toe) * 8, y: 434)
                }
            }
            Capsule().fill(skin).frame(width: 26, height: 96).rotationEffect(.degrees(42)).position(x: 86, y: 253)
            Capsule().fill(skin).frame(width: 26, height: 96).rotationEffect(.degrees(-42)).position(x: 254, y: 253)
            ForEach([57.0, 283.0], id: \.self) { x in
                Ellipse().fill(skin).frame(width: 36, height: 38).position(x: x, y: 290)
                ForEach(0..<4) { finger in
                    Capsule().fill(skin).frame(width: 7, height: CGFloat(20 + (finger % 2) * 4))
                        .position(x: x - 12 + Double(finger) * 8, y: 311)
                }
                Capsule().fill(skin).frame(width: 9, height: 22).rotationEffect(.degrees(x == 57 ? 40 : -40))
                    .position(x: x == 57 ? 36 : 304, y: 289)
            }
            Capsule().fill(skin).frame(width: 42, height: 50).position(x: 170, y: 207)
            RoundedRectangle(cornerRadius: 29).fill(shirt).frame(width: 121, height: 123).position(x: 170, y: 267)
            Capsule().fill(shirt).frame(width: 39, height: 54).rotationEffect(.degrees(42)).position(x: 112, y: 230)
            Capsule().fill(shirt).frame(width: 39, height: 54).rotationEffect(.degrees(-42)).position(x: 228, y: 230)
            Image(systemName: "sun.max.fill").font(.system(size: 31)).foregroundStyle(.white.opacity(0.85)).position(x: 170, y: 249)
            Path { p in p.move(to: CGPoint(x: 144, y: 294)); p.addQuadCurve(to: CGPoint(x: 196, y: 294), control: CGPoint(x: 170, y: 305)) }
                .stroke(.white.opacity(0.5), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            ForEach([73.0, 267.0], id: \.self) { x in
                Ellipse().fill(skin).frame(width: 32, height: 49).position(x: x, y: 135)
                Ellipse().stroke(hair.opacity(0.4), lineWidth: 3).frame(width: 14, height: 29).position(x: x, y: 135)
            }
            Ellipse().fill(skin).frame(width: 176, height: 218).position(x: 170, y: 113)
            hairArt
            ForEach([133.0, 207.0], id: \.self) { x in
                Ellipse().fill(.white).frame(width: 29, height: 23).position(x: x, y: 80)
                Ellipse().fill(Color.sportsRGB(0x292329)).frame(width: 13, height: 18).position(x: x, y: 80)
                Circle().fill(.white).frame(width: 5).position(x: x - 2, y: 76)
                Capsule().fill(hair).frame(width: 25, height: 5).rotationEffect(.degrees(x == 133 ? -6 : 6)).position(x: x, y: 61)
            }
            RoundedRectangle(cornerRadius: 9).fill(.brown.opacity(0.15)).frame(width: 24, height: 29).position(x: 170, y: 133)
            Path { p in p.move(to: CGPoint(x: 158, y: 141)); p.addQuadCurve(to: CGPoint(x: 182, y: 141), control: CGPoint(x: 170, y: 149)) }
                .stroke(hair.opacity(0.6), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            Path { p in p.move(to: CGPoint(x: 146, y: 183)); p.addQuadCurve(to: CGPoint(x: 194, y: 183), control: CGPoint(x: 170, y: 209)); p.closeSubpath() }
                .fill(Color.sportsRGB(0x321923))
            Capsule().fill(.white).frame(width: 32, height: 5).position(x: 170, y: 187)
        }.frame(width: 340, height: 480)
    }
    @ViewBuilder private var hairArt: some View {
        crown
        switch buddy.style {
        case .curls:
            ForEach(0..<9) { index in
                Circle().fill(hair).frame(width: 39, height: 37)
                    .position(x: 93 + Double(index) * 19, y: 39 - sin(Double(index) / 8 * .pi) * 21)
            }
        case .buns:
            Circle().fill(hair).frame(width: 49).position(x: 90, y: 32)
            Circle().fill(hair).frame(width: 49).position(x: 250, y: 32)
            fringe
        case .braid:
            ForEach(0..<6) { index in
                Ellipse().fill(hair).frame(width: 25, height: 30).rotationEffect(.degrees(index.isMultiple(of: 2) ? 20 : -20))
                    .position(x: 251, y: 158 + Double(index) * 20)
            }
            Capsule().fill(.orange).frame(width: 28, height: 8).position(x: 251, y: 265)
            fringe
        default: fringe
        }
    }
    // A solid crown joins the fringe to the scalp for every hairstyle.
    private var crown: some View {
        Path { p in
            p.move(to: CGPoint(x: 82, y: 72))
            p.addCurve(to: CGPoint(x: 258, y: 72), control1: CGPoint(x: 68, y: -22), control2: CGPoint(x: 271, y: -22))
            p.addQuadCurve(to: CGPoint(x: 234, y: 44), control: CGPoint(x: 250, y: 48))
            p.addQuadCurve(to: CGPoint(x: 105, y: 45), control: CGPoint(x: 169, y: 28))
            p.addQuadCurve(to: CGPoint(x: 82, y: 72), control: CGPoint(x: 93, y: 58))
            p.closeSubpath()
        }.fill(hair)
    }
    private var fringe: some View {
        Path { p in
            p.move(to: CGPoint(x: 91, y: 48))
            p.addQuadCurve(to: CGPoint(x: 240, y: 35), control: CGPoint(x: 169, y: 5))
            p.addQuadCurve(to: CGPoint(x: 109, y: 53), control: CGPoint(x: 173, y: 59))
            p.closeSubpath()
        }.fill(hair)
    }
}
