import SwiftUI

/// Small, transparent illustrations: the surrounding game supplies its own background.
struct LiteracyFoodArt: View {
    let food: String
    var body: some View {
        GeometryReader { geometry in
            drawing.frame(width: 100, height: 100)
                .scaleEffect(min(geometry.size.width, geometry.size.height) / 100)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }.accessibilityHidden(true)
    }
    @ViewBuilder private var drawing: some View {
        switch food {
        case "apple", "carrot": HuntItemArt(item: HuntItem.named(food)).padding(8)
        case "orange", "lemon", "kiwi":
            ZStack {
                Ellipse().fill(food == "orange" ? .orange : food == "lemon" ? .yellow : .brown)
                    .frame(width: food == "orange" ? 78 : 90, height: 73)
                if food == "kiwi" {
                    Ellipse().fill(.green).frame(width: 73, height: 61)
                    Ellipse().fill(.yellow.opacity(0.8)).frame(width: 23, height: 32)
                    ForEach(0..<10) { i in
                        Ellipse().fill(.black).frame(width: 3, height: 6)
                            .offset(y: -23).rotationEffect(.degrees(Double(i) * 36))
                    }
                } else {
                    Capsule().fill(.green).frame(width: 24, height: 12).rotationEffect(.degrees(-25)).offset(x: 11, y: -38)
                }
            }
        case "banana":
            Path { p in
                p.move(to: CGPoint(x: 14, y: 17))
                p.addCurve(to: CGPoint(x: 88, y: 25), control1: CGPoint(x: 10, y: 95), control2: CGPoint(x: 87, y: 98))
                p.addCurve(to: CGPoint(x: 14, y: 17), control1: CGPoint(x: 65, y: 65), control2: CGPoint(x: 29, y: 61))
            }.fill(.yellow).overlay(alignment: .topLeading) {
                Capsule().fill(.brown).frame(width: 10, height: 13).offset(x: 10, y: 10)
            }
        case "grapes":
            ZStack {
                ForEach(0..<4) { row in
                    ForEach(0..<(4-row), id: \.self) { column in
                        Circle().fill(row.isMultiple(of: 2) ? Color.purple : Color.indigo)
                            .frame(width: 25, height: 25).overlay(Circle().stroke(.white.opacity(0.25), lineWidth: 2))
                            .position(x: CGFloat(15 + row * 12 + column * 24), y: CGFloat(24 + row * 19))
                    }
                }
                Capsule().fill(.green).frame(width: 31, height: 10).rotationEffect(.degrees(-25)).position(x: 60, y: 9)
            }
        case "pear":
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: 43, y: 18)); p.addCurve(to: CGPoint(x: 18, y: 69), control1: CGPoint(x: 40, y: 45), control2: CGPoint(x: 16, y: 40))
                    p.addCurve(to: CGPoint(x: 83, y: 69), control1: CGPoint(x: 16, y: 104), control2: CGPoint(x: 87, y: 104))
                    p.addCurve(to: CGPoint(x: 57, y: 18), control1: CGPoint(x: 84, y: 41), control2: CGPoint(x: 60, y: 44)); p.closeSubpath()
                }.fill(Color(red: 0.66, green: 0.83, blue: 0.2))
                Capsule().fill(.brown).frame(width: 6, height: 18).rotationEffect(.degrees(15)).position(x: 51, y: 12)
            }
        case "strawberry":
            ZStack {
                Image(systemName: "heart.fill").resizable().scaledToFit().foregroundStyle(.red).frame(width: 78, height: 80).offset(y: 8)
                ForEach(0..<3) { row in
                    ForEach(0..<3) { column in
                        Ellipse().fill(.yellow).frame(width: 3, height: 6).position(x: CGFloat(31 + column * 18), y: CGFloat(40 + row * 14))
                    }
                }
                Image(systemName: "leaf.fill").font(.system(size: 33)).foregroundStyle(.green).offset(y: -34)
            }
        case "watermelon":
            ZStack {
                wedge.fill(.green)
                wedge.fill(.red).scaleEffect(0.83, anchor: .top)
                ForEach(0..<5) { i in
                    Ellipse().fill(.black).frame(width: 4, height: 7).position(x: CGFloat(26 + i * 12), y: CGFloat(i % 2 == 0 ? 48 : 63))
                }
            }
        case "bread", "sandwich":
            ZStack {
                RoundedRectangle(cornerRadius: 19).fill(.brown).frame(width: 82, height: 68).offset(y: 10)
                if food == "sandwich" {
                    RoundedRectangle(cornerRadius: 5).fill(.green).frame(width: 88, height: 12).offset(y: 24)
                    RoundedRectangle(cornerRadius: 5).fill(.red).frame(width: 82, height: 9).offset(y: 11)
                    RoundedRectangle(cornerRadius: 15).fill(Color(red: 0.94, green: 0.76, blue: 0.45)).frame(width: 84, height: 44).offset(y: -9)
                } else {
                    RoundedRectangle(cornerRadius: 14).fill(Color(red: 1, green: 0.88, blue: 0.64)).frame(width: 66, height: 53).offset(y: 9)
                }
            }
        case "cheese":
            ZStack {
                Path { p in p.move(to: CGPoint(x: 12, y: 75)); p.addLine(to: CGPoint(x: 80, y: 20)); p.addLine(to: CGPoint(x: 90, y: 80)); p.closeSubpath() }.fill(.yellow)
                ForEach(0..<3) { i in Circle().fill(.orange).frame(width: 10, height: 10).position(x: CGFloat(43+i*17), y: CGFloat(i == 1 ? 46 : 66)) }
            }
        case "milk", "yogurt":
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(Color(red: 0.92, green: 0.97, blue: 1)).frame(width: 60, height: 69)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.blue, lineWidth: 3)).offset(y: 9)
                RoundedRectangle(cornerRadius: 4).fill(.blue).frame(width: 66, height: 13).offset(y: -29)
                if food == "milk" {
                    Image(systemName: "drop.fill").font(.system(size: 29)).foregroundStyle(.blue).offset(y: 10)
                } else {
                    Image(systemName: "heart.fill").font(.system(size: 28)).foregroundStyle(.pink).offset(y: 10)
                    Capsule().fill(.gray).frame(width: 7, height: 40).rotationEffect(.degrees(20)).offset(x: 20, y: -37)
                }
            }
        case "noodles":
            ZStack {
                ForEach(0..<5) { i in
                    Path { p in
                        p.move(to: CGPoint(x: 18, y: CGFloat(30+i*7)))
                        p.addCurve(to: CGPoint(x: 82, y: CGFloat(30+i*7)), control1: CGPoint(x: 36, y: CGFloat(5+i*7)), control2: CGPoint(x: 64, y: CGFloat(55+i*7)))
                    }.stroke(.yellow, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                }
                wedge.fill(.teal).frame(height: 60).offset(y: 24)
            }
        case "zucchini":
            Capsule().fill(Color(red: 0.18, green: 0.46, blue: 0.17)).frame(width: 35, height: 86)
                .overlay(Capsule().fill(.green).frame(width: 5, height: 64).offset(x: -7))
                .overlay(alignment: .top) { Rectangle().fill(.brown).frame(width: 10, height: 11).offset(y: -7) }
                .rotationEffect(.degrees(35))
        case "egg":
            Ellipse().fill(Color(red: 1, green: 0.96, blue: 0.85)).frame(width: 60, height: 82)
                .overlay(Ellipse().stroke(.brown.opacity(0.45), lineWidth: 2))
        default: EmptyView()
        }
    }
    private var wedge: Path {
        Path { p in p.move(to: CGPoint(x: 8, y: 26)); p.addLine(to: CGPoint(x: 92, y: 26)); p.addQuadCurve(to: CGPoint(x: 8, y: 26), control: CGPoint(x: 50, y: 137)); p.closeSubpath() }
    }
}
