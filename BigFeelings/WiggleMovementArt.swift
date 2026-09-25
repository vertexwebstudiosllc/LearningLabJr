import SwiftUI

struct WiggleMovementBear: View {
    var pose: Double
    var body: some View {
        GeometryReader { g in
            let scale = min(g.size.width / 220, g.size.height / 250)
            ZStack {
                Ellipse().fill(.brown.opacity(0.1)).frame(width: 180, height: 22).position(x: 110, y: 234)
                ForEach([70.0, 150.0], id: \.self) { x in
                    Ellipse().fill(Color.sportsRGB(0xA8774D)).frame(width: 44, height: 64)
                        .rotationEffect(.degrees(pose * (x < 110 ? 10 : -10))).position(x: x, y: 210)
                }
                Ellipse().fill(Color.sportsRGB(0xA8774D)).frame(width: 117, height: 127).position(x: 110, y: 160)
                Ellipse().fill(Color.sportsRGB(0xDDB68A)).frame(width: 73, height: 86).position(x: 110, y: 169)
                ForEach([38.0, 182.0], id: \.self) { x in
                    Ellipse().fill(Color.sportsRGB(0xA8774D)).frame(width: 35, height: 80)
                        .rotationEffect(.degrees((x < 110 ? 32 : -32) + pose * (x < 110 ? 24 : -24)))
                        .position(x: x, y: 145 - abs(pose) * 8)
                }
                ForEach([64.0, 156.0], id: \.self) { x in
                    Circle().fill(Color.sportsRGB(0xA8774D)).frame(width: 43, height: 43)
                        .overlay(Circle().fill(Color.sportsRGB(0xD99379)).padding(10)).position(x: x, y: 34)
                }
                Ellipse().fill(Color.sportsRGB(0xB3845B)).frame(width: 122, height: 108).position(x: 110, y: 76)
                Ellipse().fill(Color.sportsRGB(0xF1D1A0)).frame(width: 60, height: 43).position(x: 110, y: 98)
                ForEach([87.0, 133.0], id: \.self) { x in
                    Circle().fill(Color.sportsRGB(0x34291F)).frame(width: 10, height: 10).position(x: x, y: 72)
                    Circle().fill(.white).frame(width: 3, height: 3).position(x: x - 1.5, y: 70)
                }
                Ellipse().fill(Color.sportsRGB(0x69442D)).frame(width: 20, height: 14).position(x: 110, y: 90)
                Path { p in p.move(to: CGPoint(x: 97, y: 104)); p.addQuadCurve(to: CGPoint(x: 123, y: 104), control: CGPoint(x: 110, y: 118)) }.stroke(Color.sportsRGB(0x69442D), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            }.frame(width: 220, height: 250).scaleEffect(scale, anchor: .topLeading)
                .frame(width: g.size.width, height: g.size.height, alignment: .center)
        }.accessibilityHidden(true)
    }
}

struct WiggleMovementStage: View {
    let cue: WiggleCue
    let moving: Bool
    let reduceMotion: Bool
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                ForEach(WiggleCue.allCases, id: \.rawValue) { option in light(option) }
            }.accessibilityElement(children: .ignore).accessibilityLabel(cue.title)
            animatedBear
        }.padding(16).background(cue.color.opacity(0.09), in: RoundedRectangle(cornerRadius: 26))
    }
    private func light(_ option: WiggleCue) -> some View {
        let selected = option == cue
        return VStack(spacing: 7) {
            Image(systemName: option.symbol).font(.system(size: 28, weight: .bold))
                .foregroundStyle(selected ? Color.white : option.color)
                .frame(width: 64, height: 64)
                .background(selected ? option.color : option.color.opacity(0.1), in: Circle())
                .overlay(Circle().stroke(selected ? Color.primary : Color.clear, lineWidth: 3))
            Text(option.title).font(.subheadline.bold())
        }.frame(maxWidth: .infinity)
    }
    private var animatedBear: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: !moving || reduceMotion || cue == .stop)) { context in
            let t: Double = context.date.timeIntervalSinceReferenceDate
            let frequency: Double = cue == .wiggle ? 5.0 : 1.5
            let pose: Double = moving && !reduceMotion && cue != .stop ? sin(t * frequency) : 0.0
            WiggleMovementBear(pose: pose).frame(width: 190, height: 216)
                .rotationEffect(.degrees(pose * 4)).frame(maxWidth: .infinity)
        }
    }
}
