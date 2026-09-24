import SwiftUI

struct LittleGardenGame: View {
    @State private var play = LittleGardenPlay()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ToddlerGameScaffold(title: "Little Garden", prompt: play.prompt, accent: .green) {
            if play.flower == nil {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(GardenFlower.all) { flower in
                        Button { play.chooseFlower(flower) } label: {
                            VStack(spacing: 10) {
                                GardenBlossom(flower: flower).frame(width: 94, height: 94)
                                Text(flower.name).font(.headline)
                            }.frame(maxWidth: .infinity, minHeight: 148)
                                .background(.white, in: RoundedRectangle(cornerRadius: 22))
                                .overlay(RoundedRectangle(cornerRadius: 22).stroke(.green.opacity(0.25), lineWidth: 2))
                        }.buttonStyle(.plain).accessibilityLabel(flower.name)
                            .accessibilityIdentifier("garden.flower.\(flower.id)")
                    }
                }
            } else if let flower = play.flower, play.place == nil {
                GardenBlossom(flower: flower).frame(width: 120, height: 120)
                ForEach(GardenPlace.allCases, id: \.self) { place in
                    Button { play.choosePlace(place) } label: {
                        HStack(spacing: 20) {
                            Image(systemName: place == .inside ? "house.fill" : "sun.max.fill")
                                .font(.system(size: 48)).foregroundStyle(place == .inside ? .orange : .green)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(place == .inside ? "Inside" : "Outside").font(.title2.bold())
                                Text(place == .inside ? "A pot by the window" : "A sunny garden bed").font(.headline)
                            }
                            Spacer(minLength: 0)
                        }.padding(20).frame(maxWidth: .infinity, minHeight: 110)
                            .background(.white, in: RoundedRectangle(cornerRadius: 22))
                    }.buttonStyle(.plain).accessibilityIdentifier("garden.place.\(place.rawValue)")
                }
                Button("Choose another flower") { play.restart() }.frame(minHeight: 48)
            } else if let flower = play.flower, let place = play.place {
                Label("\(flower.name) · \(place == .inside ? "Inside" : "Outside")", systemImage: place == .inside ? "house.fill" : "sun.max.fill")
                    .font(.headline)
                GardenGrowingScene(flower: flower, place: place, step: play.step, growth: play.growth)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.45), value: play.step)
                    .aspectRatio(1.05, contentMode: .fit).frame(maxWidth: 470)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(flower.name), \(play.stageName), \(place == .inside ? "in a pot" : "in the garden")")
                    .accessibilityIdentifier("garden.scene")
                Text(play.stageName).font(.title2.bold()).accessibilityIdentifier("garden.stage")
                ProgressView(value: Double(play.step + 1), total: Double(play.steps.count))
                    .tint(.green).accessibilityLabel("Plant care progress")
                if let next = play.nextStep {
                    ToddlerActionButton(title: next.action, systemImage: next.symbol, color: .green) {
                        play.advance()
                    }.accessibilityIdentifier("garden.next")
                } else {
                    Label("You grew a flower!", systemImage: "checkmark.seal.fill").font(.headline)
                        .accessibilityIdentifier("garden.complete")
                    ToddlerActionButton(title: "Grow another flower", systemImage: "arrow.clockwise", color: .green) { play.restart() }
                        .accessibilityIdentifier("garden.replay")
                    Button("All done") { dismiss() }.font(.headline).frame(minHeight: 48)
                }
            }
        }
    }
}

private struct GardenBlossom: View {
    let flower: GardenFlower
    private var color: Color {
        switch flower.id {
        case "sunflower": .yellow
        case "daisy": .white
        case "zinnia": Color(red: 0.92, green: 0.22, blue: 0.48)
        default: .orange
        }
    }
    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            ZStack {
                ForEach(0..<flower.petals, id: \.self) { index in
                    Ellipse().fill(color)
                        .overlay(Ellipse().stroke(flower.id == "daisy" ? Color.gray.opacity(0.3) : Color.brown.opacity(0.12), lineWidth: 1))
                        .frame(width: d * (flower.id == "marigold" ? 0.29 : 0.19), height: d * 0.44)
                        .offset(y: -d * 0.25)
                        .rotationEffect(.degrees(Double(index) * 360 / Double(flower.petals)))
                }
                if flower.id == "marigold" || flower.id == "zinnia" {
                    ForEach(0..<8, id: \.self) { index in
                        Ellipse().fill(color.opacity(0.85)).frame(width: d * 0.19, height: d * 0.29)
                            .overlay(Ellipse().stroke(.yellow.opacity(0.4), lineWidth: 1))
                            .offset(y: -d * 0.13).rotationEffect(.degrees(Double(index) * 45 + 20))
                    }
                }
                Circle().fill(flower.id == "sunflower" ? Color(red: 0.38, green: 0.20, blue: 0.10) : .yellow)
                    .frame(width: d * (flower.id == "sunflower" ? 0.36 : 0.23))
            }.frame(width: geo.size.width, height: geo.size.height)
        }.accessibilityHidden(true)
    }
}

private struct GardenGrowingScene: View {
    let flower: GardenFlower
    let place: GardenPlace
    let step: Int
    let growth: Int
    private var indoors: Bool { place == .inside }
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let ground = h * 0.70
            let stem = h * [0.0, 0.0, 0.15, 0.29, 0.39, 0.43][growth]
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(indoors ? Color(red: 1, green: 0.93, blue: 0.79) : Color(red: 0.70, green: 0.91, blue: 1))
                if indoors {
                    RoundedRectangle(cornerRadius: 14).fill(Color.cyan.opacity(0.18))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white, lineWidth: 9))
                        .frame(width: w * 0.74, height: h * 0.55).position(x: w / 2, y: h * 0.34)
                    Rectangle().fill(.white).frame(width: 7, height: h * 0.55).position(x: w / 2, y: h * 0.34)
                    Rectangle().fill(.white).frame(width: w * 0.74, height: 7).position(x: w / 2, y: h * 0.34)
                    RoundedRectangle(cornerRadius: 8).fill(Color.brown.opacity(0.5)).frame(width: w * 0.92, height: 15).position(x: w / 2, y: h * 0.94)
                } else {
                    Ellipse().fill(Color.green.opacity(0.35)).frame(width: w * 1.5, height: h * 0.38).position(x: w * 0.4, y: h * 0.81)
                    HStack(spacing: w * 0.12) {
                        ForEach(0..<6, id: \.self) { _ in RoundedRectangle(cornerRadius: 5).fill(.white.opacity(0.8)).frame(width: 12, height: h * 0.16) }
                    }.position(x: w / 2, y: h * 0.66)
                }
                Image(systemName: "sun.max.fill").font(.system(size: w * 0.13)).foregroundStyle(.orange)
                    .position(x: w * 0.78, y: h * 0.16)
                if step >= 0 {
                    if indoors {
                        Path { p in
                            p.move(to: CGPoint(x: w * 0.25, y: ground)); p.addLine(to: CGPoint(x: w * 0.32, y: h * 0.92))
                            p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.92)); p.addLine(to: CGPoint(x: w * 0.75, y: ground)); p.closeSubpath()
                        }.fill(Color(red: 0.81, green: 0.37, blue: 0.22))
                        Capsule().fill(Color(red: 0.94, green: 0.52, blue: 0.32)).frame(width: w * 0.55, height: h * 0.055).position(x: w / 2, y: ground)
                        HStack(spacing: 10) { ForEach(0..<3, id: \.self) { _ in Circle().fill(.brown).frame(width: 5, height: 5) } }.position(x: w / 2, y: h * 0.90)
                    } else {
                        RoundedRectangle(cornerRadius: 18).fill(Color(red: 0.57, green: 0.34, blue: 0.19))
                            .frame(width: w * 0.90, height: h * 0.25).position(x: w / 2, y: h * 0.80)
                    }
                }
                if step >= 1 {
                    RoundedRectangle(cornerRadius: 14).fill(Color(red: 0.30, green: 0.18, blue: 0.10))
                        .frame(width: w * (indoors ? 0.38 : 0.80), height: h * 0.15).position(x: w / 2, y: h * 0.79)
                }
                if step >= 2 && growth == 0 {
                    Ellipse().fill(Color(red: 0.91, green: 0.73, blue: 0.40)).frame(width: 13, height: 19)
                        .rotationEffect(.degrees(30)).position(x: w / 2, y: step == 2 ? ground - 8 : h * 0.76)
                }
                if growth >= 1 {
                    Path { p in
                        p.move(to: CGPoint(x: w / 2, y: ground))
                        p.addQuadCurve(to: CGPoint(x: w * 0.49, y: h * 0.86), control: CGPoint(x: w * 0.55, y: h * 0.8))
                        for side in [-1.0, 1.0] {
                            p.move(to: CGPoint(x: w / 2, y: h * 0.77))
                            p.addQuadCurve(to: CGPoint(x: w * (0.5 + side * 0.10), y: h * 0.84), control: CGPoint(x: w * (0.5 + side * 0.07), y: h * 0.78))
                        }
                    }.stroke(Color(red: 0.96, green: 0.85, blue: 0.63), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                }
                if growth >= 2 {
                    Capsule().fill(Color(red: 0.16, green: 0.49, blue: 0.22)).frame(width: 7, height: stem).position(x: w / 2, y: ground - stem / 2)
                    ForEach(0..<(growth >= 3 ? 4 : 2), id: \.self) { leaf in
                        let side = leaf.isMultiple(of: 2) ? -1.0 : 1.0
                        Ellipse().fill(leaf < 2 ? Color.green : Color(red: 0.22, green: 0.65, blue: 0.30))
                            .frame(width: w * 0.16, height: h * 0.065).rotationEffect(.degrees(side * -30))
                            .position(x: w / 2 + side * w * 0.065, y: ground - stem * (leaf < 2 ? 0.35 : 0.65))
                    }
                }
                if growth == 4 {
                    Ellipse().fill(.green).frame(width: w * 0.09, height: h * 0.12).position(x: w / 2, y: ground - stem)
                }
                if growth == 5 {
                    GardenBlossom(flower: flower).frame(width: w * 0.34, height: w * 0.34).position(x: w / 2, y: ground - stem)
                }
                if !indoors && step >= 5 {
                    Rectangle().fill(Color.brown).frame(width: 5, height: h * 0.20).position(x: w * 0.83, y: h * 0.66)
                    GardenBlossom(flower: flower).frame(width: w * 0.1, height: w * 0.1).padding(5).background(.white, in: RoundedRectangle(cornerRadius: 6)).position(x: w * 0.83, y: h * 0.55)
                }
                if step == 4 || step == 8 {
                    ForEach(0..<3, id: \.self) { i in
                        Image(systemName: "drop.fill").foregroundStyle(.blue).font(.system(size: 16))
                            .position(x: w * (0.26 + Double(i) * 0.08), y: h * (0.48 + Double(i % 2) * 0.08))
                    }
                }
                if !indoors && step == 8 {
                    ForEach(0..<2, id: \.self) { i in
                        Image(systemName: "leaf.fill").font(.system(size: 24)).foregroundStyle(Color(red: 0.35, green: 0.42, blue: 0.16))
                            .rotationEffect(.degrees(i == 0 ? -35 : 35))
                            .position(x: w * (i == 0 ? 0.23 : 0.76), y: ground - 12)
                    }
                }
                if step >= 3 {
                    Text("A peek under the soil").font(.caption2.bold()).foregroundStyle(.primary)
                        .position(x: w / 2, y: h * 0.965)
                        .padding(.bottom, 2)
                }
            }.clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}
