import SwiftUI

struct RescueItemArt: View {
    let item: RescueItem
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            ZStack {
                if item.slot == .hat { hat }
                else if item.slot == .outfit {
                    RoundedRectangle(cornerRadius: w * 0.15).fill(item.color)
                        .overlay(RoundedRectangle(cornerRadius: w * 0.15).stroke(.brown.opacity(0.3), lineWidth: 2))
                    Path { p in p.move(to: CGPoint(x: w * 0.3, y: 0)); p.addLine(to: CGPoint(x: w * 0.5, y: h * 0.25)); p.addLine(to: CGPoint(x: w * 0.7, y: 0)) }
                        .stroke(.white.opacity(0.9), lineWidth: max(2, w * 0.06))
                    Rectangle().fill(.white.opacity(0.8)).frame(width: w * 0.8, height: h * 0.08).offset(y: h * 0.27)
                    Image(systemName: badge).resizable().scaledToFit().foregroundStyle(item.paint == "white" ? .teal : .white)
                        .frame(width: w * 0.3, height: h * 0.3).offset(y: h * 0.03)
                } else { tool }
            }
        }.accessibilityHidden(true)
    }
    private var badge: String {
        switch item.role {
        case "cat": return "flame.fill"
        case "puppy", "kitten": return "heart.fill"
        case "garden", "duck", "beach": return "leaf.fill"
        case "bike": return "wrench.fill"
        case "snow": return "snowflake"
        case "books": return "book.fill"
        default: return "star.fill"
        }
    }
    @ViewBuilder private var hat: some View {
        if item.role == "books" {
            Image(systemName: "eyeglasses").resizable().scaledToFit().foregroundStyle(.indigo)
        } else if item.role == "bunny" {
            GeometryReader { g in
                ZStack {
                    HStack(spacing: -g.size.width * 0.12) {
                        ForEach(0..<3) { _ in Circle().fill(.white).overlay(Circle().stroke(.gray.opacity(0.4), lineWidth: 1)) }
                    }.frame(height: g.size.height * 0.8).offset(y: -g.size.height * 0.12)
                    RoundedRectangle(cornerRadius: 4).fill(.white).overlay(RoundedRectangle(cornerRadius: 4).stroke(.gray.opacity(0.4), lineWidth: 1))
                        .frame(width: g.size.width * 0.7, height: g.size.height * 0.45).offset(y: g.size.height * 0.27)
                }
            }
        } else {
            GeometryReader { g in
                let hatColor: Color = item.role == "garden" || item.role == "bridge" ? .yellow : item.role == "duck" ? .brown : item.color
                ZStack {
                    UnevenRoundedRectangle(topLeadingRadius: g.size.width * 0.3, topTrailingRadius: g.size.width * 0.3)
                        .fill(hatColor).frame(width: g.size.width * 0.76, height: g.size.height * 0.82)
                    Capsule().fill(hatColor).overlay(Capsule().stroke(.brown.opacity(0.3), lineWidth: 1))
                        .frame(width: g.size.width, height: g.size.height * 0.19).offset(y: g.size.height * 0.34)
                    if ["snow", "kitten"].contains(item.role) {
                        Circle().fill(hatColor).frame(width: g.size.height * 0.25).offset(y: -g.size.height * 0.43)
                        Rectangle().fill(.white.opacity(0.7)).frame(width: g.size.width * 0.7, height: 4).offset(y: g.size.height * 0.18)
                    } else {
                        Image(systemName: badge).resizable().scaledToFit().foregroundStyle(.white)
                            .frame(width: g.size.width * 0.23, height: g.size.height * 0.45)
                    }
                }
            }
        }
    }
    @ViewBuilder private var tool: some View {
        switch item.role {
        case "cat":
            GeometryReader { g in
                ZStack {
                    HStack { Capsule().fill(.brown).frame(width: 6); Spacer(); Capsule().fill(.brown).frame(width: 6) }.padding(.horizontal, g.size.width * 0.22)
                    VStack { ForEach(0..<5) { _ in Capsule().fill(.orange).frame(height: 5); Spacer(minLength: 1) } }.padding(.horizontal, g.size.width * 0.22).padding(.vertical, 5)
                }
            }
        case "bridge":
            VStack(spacing: 5) { ForEach(0..<3) { _ in RoundedRectangle(cornerRadius: 3).fill(.brown).overlay(Rectangle().fill(.orange.opacity(0.3)).frame(height: 2)) } }.padding(5)
        case "garden":
            GeometryReader { g in
                ZStack {
                    Circle().stroke(.teal, lineWidth: 5).frame(width: g.size.width * 0.42).offset(x: g.size.width * 0.23)
                    RoundedRectangle(cornerRadius: 6).fill(.teal).frame(width: g.size.width * 0.6, height: g.size.height * 0.6).offset(y: g.size.height * 0.15)
                    Rectangle().fill(.teal).frame(width: g.size.width * 0.45, height: g.size.height * 0.14).rotationEffect(.degrees(35)).offset(x: -g.size.width * 0.3)
                    Image(systemName: "drop.fill").foregroundStyle(.white).offset(y: g.size.height * 0.15)
                }
            }
        case "bunny":
            ZStack(alignment: .bottom) {
                GeometryReader { g in
                    ZStack {
                        Path { p in
                            p.move(to: CGPoint(x: g.size.width * 0.3, y: g.size.height * 0.28))
                            p.addQuadCurve(to: CGPoint(x: g.size.width * 0.7, y: g.size.height * 0.28), control: CGPoint(x: g.size.width * 0.5, y: g.size.height * 0.12))
                            p.addLine(to: CGPoint(x: g.size.width * 0.5, y: g.size.height * 0.92))
                            p.closeSubpath()
                        }.fill(.orange)
                        ForEach([-30.0, 0.0, 30.0], id: \.self) { angle in
                            Capsule().fill(.green).frame(width: g.size.width * 0.09, height: g.size.height * 0.28)
                                .rotationEffect(.degrees(angle), anchor: .bottom)
                                .position(x: g.size.width * 0.5, y: g.size.height * 0.14)
                        }
                    }
                }.padding(.bottom, 12)
                Image(systemName: "basket.fill").resizable().scaledToFit().foregroundStyle(.brown).frame(height: 25)
            }
        case "beach":
            GeometryReader { g in
                Path { p in
                    p.move(to: CGPoint(x: g.size.width * 0.5, y: 0)); p.addLine(to: CGPoint(x: g.size.width * 0.5, y: g.size.height * 0.7))
                    p.addLine(to: CGPoint(x: g.size.width * 0.2, y: g.size.height)); p.move(to: CGPoint(x: g.size.width * 0.5, y: g.size.height * 0.7)); p.addLine(to: CGPoint(x: g.size.width * 0.8, y: g.size.height))
                }.stroke(.teal, style: StrokeStyle(lineWidth: 6, lineCap: .round))
            }
        case "kitten":
            RoundedRectangle(cornerRadius: 9).fill(.purple.opacity(0.75)).overlay(Image(systemName: "heart.fill").foregroundStyle(.white))
        case "books":
            ZStack {
                Image(systemName: "cart.fill").resizable().scaledToFit().foregroundStyle(.brown)
                Image(systemName: "books.vertical.fill").resizable().scaledToFit().foregroundStyle(.purple).padding(.bottom, 20).padding(.horizontal, 14)
            }
        case "snow":
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 5).stroke(.brown, lineWidth: 4).frame(width: 22, height: 14)
                Rectangle().fill(.brown).frame(width: 6)
                RoundedRectangle(cornerRadius: 6).fill(.blue).frame(height: 25)
            }.padding(.horizontal, 12)
        default:
            Image(systemName: ["puppy": "bandage.fill", "duck": "map.fill", "bike": "wrench.fill", "rain": "umbrella.fill", "books": "books.vertical.fill"][item.role] ?? "heart.fill")
                .resizable().scaledToFit().foregroundStyle(item.color).padding(3)
        }
    }
}

struct RescueTeddy: View {
    let fur: TeddyFur
    let identity: TeddyIdentity
    let items: [RescueItem]
    var body: some View {
        GeometryReader { g in
            let scale = min(g.size.width / 200, g.size.height / 250)
            ZStack {
                ForEach([CGFloat(68), 132], id: \.self) { x in
                    Ellipse().fill(fur.color).frame(width: 47, height: 56).position(x: x, y: 222)
                    Ellipse().fill(.white.opacity(0.2)).frame(width: 29, height: 32).position(x: x, y: 228)
                }
                Ellipse().fill(fur.color).frame(width: 100, height: 112).position(x: 100, y: 172)
                ForEach([CGFloat(43), 157], id: \.self) { x in
                    Ellipse().fill(fur.color).frame(width: 35, height: 79).rotationEffect(.degrees(x < 100 ? 22 : -22)).position(x: x, y: 175)
                }
                if let outfit = items.first(where: { $0.slot == .outfit }) {
                    RescueItemArt(item: outfit).frame(width: 87, height: 87).position(x: 100, y: 172)
                } else {
                    Ellipse().fill(.white.opacity(0.18)).frame(width: 62, height: 77).position(x: 100, y: 180)
                }
                ForEach([CGFloat(51), 149], id: \.self) { x in
                    Circle().fill(fur.color).frame(width: 48).position(x: x, y: 48)
                    Circle().fill(.pink.opacity(0.35)).frame(width: 28).position(x: x, y: 48)
                }
                Circle().fill(fur.color.gradient).frame(width: 119).position(x: 100, y: 91)
                Ellipse().fill(Color(red: 1, green: 0.9, blue: 0.72)).frame(width: 64, height: 45).position(x: 100, y: 112)
                ForEach([CGFloat(76), 124], id: \.self) { x in
                    Circle().fill(.black.opacity(0.8)).frame(width: 12).position(x: x, y: 87)
                    Circle().fill(.white).frame(width: 4).position(x: x - 2, y: 85)
                }
                Ellipse().fill(.brown.opacity(0.9)).frame(width: 20, height: 14).position(x: 100, y: 103)
                Path { p in p.move(to: CGPoint(x: 87, y: 119)); p.addQuadCurve(to: CGPoint(x: 113, y: 119), control: CGPoint(x: 100, y: 132)) }
                    .stroke(.brown, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                if identity == .girl {
                    HStack(spacing: -2) { Ellipse().fill(.teal).rotationEffect(.degrees(25)); Circle().fill(.cyan).frame(width: 9); Ellipse().fill(.teal).rotationEffect(.degrees(-25)) }
                        .frame(width: 40, height: 21).position(x: 146, y: 42)
                }
                if let hat = items.first(where: { $0.slot == .hat }) {
                    RescueItemArt(item: hat).frame(width: hat.role == "books" ? 80 : 132, height: hat.role == "books" ? 30 : 54)
                        .position(x: 100, y: hat.role == "books" ? 87 : 35)
                }
                if let tool = items.first(where: { $0.slot == .tool }) {
                    RescueItemArt(item: tool).frame(width: 54, height: 72).rotationEffect(.degrees(-12)).position(x: 166, y: 185)
                }
            }.frame(width: 200, height: 250).scaleEffect(scale, anchor: .topLeading)
                .offset(x: (g.size.width - 200 * scale) / 2)
        }.accessibilityElement(children: .ignore)
            .accessibilityLabel("\(identity.name), \(fur.name.lowercased()) fur")
            .accessibilityValue(items.isEmpty ? "Ready to dress" : items.map(\.name).joined(separator: ", "))
    }
}

struct TeddyRescueScene: View {
    let scene: TeddyRescue
    let rescued: Bool
    var fur: TeddyFur = .brown
    var identity: TeddyIdentity = .boy
    var body: some View {
        GeometryReader { g in
            let scale = min(g.size.width / 320, g.size.height / 200)
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(.cyan.opacity(0.10))
                Rectangle().fill(scene.id == "beach" ? .yellow.opacity(0.22) : .green.opacity(0.14)).frame(height: 44).position(x: 160, y: 178)
                details
                if rescued {
                    RescueTeddy(fur: fur, identity: identity, items: scene.items)
                        .frame(width: 75, height: 100).position(x: 43, y: 140)
                }
            }.frame(width: 320, height: 200).clipShape(RoundedRectangle(cornerRadius: 24))
                .scaleEffect(scale, anchor: .topLeading).offset(x: (g.size.width - 320 * scale) / 2)
        }.accessibilityElement(children: .ignore).accessibilityLabel(rescued ? scene.success : scene.problem)
    }
    private func animal(_ asset: String, x: CGFloat, y: CGFloat, size: CGFloat = 68) -> some View {
        Image(asset).resizable().scaledToFit().frame(width: size, height: size).position(x: x, y: y)
    }
    private func symbol(_ name: String, color: Color, x: CGFloat, y: CGFloat, size: CGFloat = 60) -> some View {
        Image(systemName: name).resizable().scaledToFit().foregroundStyle(color).frame(width: size, height: size).position(x: x, y: y)
    }
    @ViewBuilder private var details: some View {
        switch scene.id {
        case "cat":
            RoundedRectangle(cornerRadius: 8).fill(.brown).frame(width: 28, height: 130).position(x: 185, y: 119)
            ForEach([CGFloat(150), 192, 227], id: \.self) { x in Circle().fill(.green.opacity(0.7)).frame(width: 90).position(x: x, y: 61) }
            Rectangle().fill(.brown).frame(width: 76, height: 12).position(x: 226, y: 98)
            if rescued { RescueItemArt(item: scene.items[2]).frame(width: 45, height: 113).rotationEffect(.degrees(15)).position(x: 150, y: 125) }
            animal("FamilyClean/cat", x: rescued ? 260 : 233, y: rescued ? 165 : 76, size: 60)
        case "puppy":
            RoundedRectangle(cornerRadius: 15).fill(.white).frame(width: 200, height: 28).position(x: 160, y: 171)
            animal("FamilyClean/dog", x: 155, y: 122, size: 110)
            symbol(rescued ? "heart.fill" : "questionmark.bubble.fill", color: .pink, x: 246, y: 70, size: 40)
            if rescued { symbol("bandage.fill", color: .orange, x: 179, y: 158, size: 28) }
        case "bridge":
            Rectangle().fill(.cyan.opacity(0.6)).frame(width: 130, height: 70).position(x: 160, y: 170)
            ForEach(0..<7) { n in
                if rescued || n < 2 || n > 4 { RoundedRectangle(cornerRadius: 3).fill(.brown).frame(width: 32, height: 18).position(x: CGFloat(55 + n * 35), y: 147) }
            }
            symbol("person.fill", color: .purple, x: rescued ? 270 : 45, y: 111, size: 45)
        case "garden":
            ForEach(0..<3) { n in
                Rectangle().fill(.green).frame(width: 7, height: 65).position(x: CGFloat(85 + n * 75), y: 143)
                Image(systemName: "camera.macro").resizable().scaledToFit().foregroundStyle([Color.pink, .purple, .orange][n])
                    .frame(width: rescued ? 62 : 38, height: rescued ? 62 : 38).rotationEffect(.degrees(rescued ? 0 : 35))
                    .position(x: CGFloat(85 + n * 75), y: rescued ? 98 : 126)
            }
            if rescued { symbol("drop.fill", color: .blue, x: 280, y: 76, size: 30) }
        case "bunny":
            animal("BarnClean/rabbit", x: 103, y: 137, size: 100)
            RoundedRectangle(cornerRadius: 8).fill(.pink.opacity(0.3)).frame(width: 120, height: 25).position(x: 228, y: 166)
            if rescued { RescueItemArt(item: scene.items[2]).frame(width: 65, height: 68).position(x: 228, y: 132) }
        case "duck":
            Ellipse().fill(.cyan.opacity(0.6)).frame(width: 125, height: 48).position(x: 240, y: 161)
            Path { p in p.move(to: CGPoint(x: 60, y: 174)); p.addQuadCurve(to: CGPoint(x: 235, y: 150), control: CGPoint(x: 155, y: 100)) }.stroke(.brown.opacity(0.4), style: StrokeStyle(lineWidth: 3, dash: [5, 6]))
            animal("BarnClean/duck", x: rescued ? 235 : 70, y: rescued ? 143 : 149, size: 63)
        case "beach":
            Ellipse().fill(.cyan.opacity(0.4)).frame(width: 350, height: 65).position(x: 160, y: 205)
            symbol("trash.fill", color: .teal, x: 270, y: 143, size: 58)
            if !rescued { ForEach(0..<3) { n in RoundedRectangle(cornerRadius: 3).fill([Color.orange, .purple, .blue][n]).frame(width: 22, height: 30).rotationEffect(.degrees(Double(n * 35))).position(x: CGFloat(65 + n * 57), y: 163) } }
            animal("BarnClean/duck", x: rescued ? 160 : 70, y: 111, size: 48)
        case "bike":
            Circle().stroke(.indigo, lineWidth: 6).frame(width: 65).position(x: 85, y: 151)
            Circle().stroke(.indigo, lineWidth: 6).frame(width: 65).position(x: rescued ? 236 : 270, y: rescued ? 151 : 174)
            Path { p in
                p.move(to: CGPoint(x: 85, y: 151)); p.addLine(to: CGPoint(x: 126, y: 94)); p.addLine(to: CGPoint(x: 164, y: 151)); p.closeSubpath()
                p.move(to: CGPoint(x: 126, y: 94)); p.addLine(to: CGPoint(x: 206, y: 94)); p.addLine(to: CGPoint(x: 164, y: 151))
                p.move(to: CGPoint(x: 236, y: 151)); p.addLine(to: CGPoint(x: 197, y: 65)); p.addLine(to: CGPoint(x: 223, y: 65))
            }.stroke(.orange, style: StrokeStyle(lineWidth: 7, lineCap: .round))
            Capsule().fill(.indigo).frame(width: 42, height: 10).position(x: 126, y: 85)
        case "rain":
            symbol("cloud.rain.fill", color: .blue.opacity(0.4), x: 160, y: 48, size: 95)
            symbol("person.fill", color: .purple, x: 170, y: 145, size: 68)
            if rescued { symbol("umbrella.fill", color: .yellow, x: 178, y: 94, size: 103) }
        case "kitten":
            if rescued { RoundedRectangle(cornerRadius: 16).fill(.purple.opacity(0.6)).frame(width: 185, height: 44).position(x: 160, y: 167) }
            animal("FamilyClean/cat", x: 160, y: 133, size: 105)
            symbol(rescued ? "heart.fill" : "moon.fill", color: .purple, x: 245, y: 68, size: 35)
        case "snow":
            symbol("house.fill", color: .orange, x: 252, y: 83, size: 108)
            RoundedRectangle(cornerRadius: 12).fill(.brown.opacity(0.4)).frame(width: 240, height: 31).position(x: 167, y: 160)
            if !rescued { ForEach(0..<5) { n in Ellipse().fill(.white).frame(width: 52, height: 42).position(x: CGFloat(68 + n * 43), y: 153) } }
            symbol("person.fill", color: .teal, x: rescued ? 245 : 45, y: 130, size: 48)
            symbol("snowflake", color: .blue.opacity(0.4), x: 110, y: 50, size: 37)
        default:
            RoundedRectangle(cornerRadius: 8).stroke(.brown, lineWidth: 7).frame(width: 195, height: 115).position(x: 180, y: 107)
            ForEach(0..<2) { n in Rectangle().fill(.brown).frame(width: 195, height: 6).position(x: 180, y: CGFloat(96 + n * 45)) }
            ForEach(0..<5) { n in
                RoundedRectangle(cornerRadius: 3).fill([Color.teal, .pink, .orange, .purple, .blue][n]).frame(width: 20, height: 34)
                    .rotationEffect(.degrees(rescued ? 0 : Double(n * 24)))
                    .position(x: CGFloat(rescued ? 115 + n * 30 : 75 + n * 40), y: rescued ? 120 : 179)
            }
        }
    }
}
