import SwiftUI

/// Single-color, game-specific symbols that inherit the shared card's accent.
struct NatureMenuIcon: View {
    let activity: NatureActivity
    var body: some View {
        GeometryReader { geometry in
            drawing.frame(width: 100, height: 100)
                .scaleEffect(min(geometry.size.width, geometry.size.height) / 100)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
    @ViewBuilder private var drawing: some View {
        switch activity {
        case .habitats:
            ZStack {
                symbol("house.fill", size: 88)
                symbol("pawprint.fill", size: 32).foregroundStyle(.white).offset(y: 12)
            }
        case .tracks:
            ZStack {
                DinosaurMenuShape().fill().frame(width: 94, height: 88)
                Circle().fill(.white).frame(width: 5, height: 5).offset(x: 26, y: -27)
            }
        case .moon:
            ZStack {
                symbol("moon.stars.fill", size: 44).offset(x: 27, y: -23)
                ZStack {
                    Capsule().frame(width: 28, height: 63)
                    Circle().fill(.white).frame(width: 12, height: 12).offset(y: -9)
                    Path { p in
                        p.move(to: CGPoint(x: 15, y: 50)); p.addLine(to: CGPoint(x: 0, y: 77)); p.addLine(to: CGPoint(x: 18, y: 70))
                        p.move(to: CGPoint(x: 35, y: 50)); p.addLine(to: CGPoint(x: 50, y: 77)); p.addLine(to: CGPoint(x: 32, y: 70))
                    }.fill().frame(width: 50, height: 90)
                    Capsule().frame(width: 10, height: 18).offset(y: 42)
                }.frame(width: 50, height: 90).rotationEffect(.degrees(25)).offset(x: -15, y: 4)
            }
        case .families:
            ZStack {
                symbol("pawprint.fill", size: 63).offset(x: -17, y: -10)
                symbol("pawprint.fill", size: 35).offset(x: 31, y: 28)
            }
        case .barn:
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: 5, y: 39))
                    p.addLine(to: CGPoint(x: 24, y: 14))
                    p.addLine(to: CGPoint(x: 50, y: 3))
                    p.addLine(to: CGPoint(x: 76, y: 14))
                    p.addLine(to: CGPoint(x: 95, y: 39))
                    p.closeSubpath()
                }.fill()
                RoundedRectangle(cornerRadius: 4).frame(width: 78, height: 54).offset(y: 15)
                Rectangle().stroke(.white, lineWidth: 4).frame(width: 39, height: 37).offset(y: 23)
                Path { p in
                    p.move(to: CGPoint(x: 31, y: 55)); p.addLine(to: CGPoint(x: 69, y: 91))
                    p.move(to: CGPoint(x: 69, y: 55)); p.addLine(to: CGPoint(x: 31, y: 91))
                }.stroke(.white, lineWidth: 3)
                Circle().fill(.white).frame(width: 10, height: 10).offset(y: -24)
            }
        case .garden:
            ZStack {
                Capsule().frame(width: 6, height: 55).offset(y: 11)
                Ellipse().frame(width: 43, height: 22).rotationEffect(.degrees(35)).offset(x: -18, y: -12)
                Ellipse().frame(width: 43, height: 22).rotationEffect(.degrees(-35)).offset(x: 18, y: -27)
                Capsule().frame(width: 80, height: 8).offset(y: 40)
            }
        case .cleanup:
            ZStack {
                symbol("fish.fill", size: 57).offset(x: -17, y: -15)
                symbol("trash.fill", size: 37).offset(x: 29, y: 7)
                Image(systemName: "water.waves").resizable()
                    .frame(width: 80, height: 22).offset(y: 36)
            }
        case .weather:
            symbol("cloud.sun.rain.fill", size: 88)
        case .movement:
            ZStack {
                symbol("hare.fill", size: 75).offset(y: -10)
                symbol("arrow.right", size: 42).offset(x: 8, y: 35)
            }
        case .dayNight:
            ZStack {
                symbol("sun.max.fill", size: 54).offset(x: -24, y: -22)
                symbol("moon.fill", size: 52).offset(x: 25, y: 23)
            }
        case .clues:
            ZStack {
                Circle().stroke(lineWidth: 9).frame(width: 59, height: 59).offset(x: -12, y: -12)
                symbol("pawprint.fill", size: 32).offset(x: -12, y: -12)
                Capsule().frame(width: 12, height: 42).rotationEffect(.degrees(-45)).offset(x: 27, y: 27)
            }
        case .nest:
            ZStack {
                ForEach([-22.0, 0.0, 22.0], id: \.self) { x in
                    Ellipse().frame(width: 20, height: 29).offset(x: x, y: -10)
                }
                Path { p in
                    p.move(to: CGPoint(x: 6, y: 48)); p.addQuadCurve(to: CGPoint(x: 94, y: 48), control: CGPoint(x: 50, y: 115))
                    p.move(to: CGPoint(x: 7, y: 49)); p.addQuadCurve(to: CGPoint(x: 93, y: 49), control: CGPoint(x: 50, y: 72))
                    p.move(to: CGPoint(x: 18, y: 65)); p.addQuadCurve(to: CGPoint(x: 82, y: 65), control: CGPoint(x: 50, y: 90))
                }.stroke(style: StrokeStyle(lineWidth: 7, lineCap: .round))
            }
        }
    }
    private func symbol(_ name: String, size: CGFloat) -> some View {
        Image(systemName: name).resizable().scaledToFit().frame(width: size, height: size)
    }
}

private struct DinosaurMenuShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 5, y: 61))
        p.addQuadCurve(to: CGPoint(x: 38, y: 51), control: CGPoint(x: 24, y: 64))
        p.addQuadCurve(to: CGPoint(x: 57, y: 46), control: CGPoint(x: 43, y: 40))
        p.addLine(to: CGPoint(x: 59, y: 19))
        p.addQuadCurve(to: CGPoint(x: 91, y: 14), control: CGPoint(x: 69, y: 0))
        p.addQuadCurve(to: CGPoint(x: 91, y: 34), control: CGPoint(x: 103, y: 24))
        p.addLine(to: CGPoint(x: 76, y: 35))
        p.addLine(to: CGPoint(x: 76, y: 62))
        p.addQuadCurve(to: CGPoint(x: 66, y: 77), control: CGPoint(x: 78, y: 71))
        p.addLine(to: CGPoint(x: 69, y: 91)); p.addLine(to: CGPoint(x: 54, y: 91)); p.addLine(to: CGPoint(x: 51, y: 78))
        p.addLine(to: CGPoint(x: 43, y: 79)); p.addLine(to: CGPoint(x: 39, y: 91)); p.addLine(to: CGPoint(x: 25, y: 91)); p.addLine(to: CGPoint(x: 31, y: 73))
        p.addQuadCurve(to: CGPoint(x: 5, y: 61), control: CGPoint(x: 15, y: 72)); p.closeSubpath()
        return p.applying(CGAffineTransform(scaleX: rect.width / 100, y: rect.height / 100))
    }
}
