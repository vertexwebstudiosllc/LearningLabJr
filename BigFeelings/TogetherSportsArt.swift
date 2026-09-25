import SwiftUI

/// Code-drawn friends keep transparent backgrounds, crisp resizing and consistent appearances.
struct TogetherFriendArt: View {
    let friend: TogetherFriend
    var waving = false
    private var skin: Color { .sportsRGB(friend.skin) }
    private var hair: Color { .sportsRGB(friend.hair) }
    private var shirt: Color { .sportsRGB(friend.shirt) }
    var body: some View {
        GeometryReader { g in
            let scale = min(g.size.width / 100, g.size.height / 150)
            ZStack {
                if friend.style == .long || friend.style == .headscarf {
                    RoundedRectangle(cornerRadius: 25).fill(hair).frame(width: 63, height: 76).position(x: 50, y: 46)
                }
                if friend.style == .bun { Circle().fill(hair).frame(width: 30, height: 30).position(x: 50, y: 15) }
                // Legs and shoes; seated players have bent legs and a supported seat.
                if friend.wheelchair {
                    Path { p in p.move(to: CGPoint(x: 38, y: 102)); p.addLine(to: CGPoint(x: 71, y: 108)); p.addLine(to: CGPoint(x: 74, y: 130)) }
                        .stroke(.indigo, style: StrokeStyle(lineWidth: 13, lineCap: .round, lineJoin: .round))
                    Capsule().fill(.white).frame(width: 23, height: 9).position(x: 78, y: 133)
                } else {
                    ForEach([40.0, 60.0], id: \.self) { x in
                        Capsule().fill(.indigo).frame(width: 14, height: 34).position(x: x, y: 119)
                        Capsule().fill(.white).frame(width: 23, height: 11).position(x: x, y: 136)
                    }
                }
                RoundedRectangle(cornerRadius: 17).fill(shirt).frame(width: 44, height: 47).position(x: 50, y: 85)
                Image(systemName: "heart.fill").font(.system(size: 15)).foregroundStyle(.white).position(x: 50, y: 82)
                Capsule().fill(skin).frame(width: 12, height: 33).rotationEffect(.degrees(24)).position(x: 26, y: 86)
                Capsule().fill(skin).frame(width: 12, height: 33).rotationEffect(.degrees(waving ? -125 : -24)).position(x: 76, y: waving ? 64 : 86)
                Circle().fill(skin).frame(width: 12, height: 15).position(x: 23, y: 43)
                Circle().fill(skin).frame(width: 12, height: 15).position(x: 77, y: 43)
                Ellipse().fill(skin).frame(width: 55, height: 58).position(x: 50, y: 40)
                switch friend.style {
                case .curls:
                    ForEach(0..<7) { i in
                        Circle().fill(hair).frame(width: 22, height: 22)
                            .position(x: 25 + Double(i) * 8.3, y: 18 - sin(Double(i) / 6 * .pi) * 8)
                    }
                case .headscarf:
                    Path { p in
                        p.move(to: CGPoint(x: 19, y: 45)); p.addQuadCurve(to: CGPoint(x: 50, y: 7), control: CGPoint(x: 16, y: 4))
                        p.addQuadCurve(to: CGPoint(x: 82, y: 45), control: CGPoint(x: 86, y: 4))
                        p.addLine(to: CGPoint(x: 72, y: 29)); p.addQuadCurve(to: CGPoint(x: 30, y: 29), control: CGPoint(x: 50, y: 23)); p.closeSubpath()
                    }.fill(hair)
                    Capsule().fill(hair).frame(width: 57, height: 14).rotationEffect(.degrees(-8)).position(x: 50, y: 67)
                default:
                    Path { p in
                        p.move(to: CGPoint(x: 22, y: 35)); p.addQuadCurve(to: CGPoint(x: 76, y: 28), control: CGPoint(x: 20, y: -6))
                        p.addLine(to: CGPoint(x: 79, y: 37)); p.addLine(to: CGPoint(x: 64, y: 24)); p.addQuadCurve(to: CGPoint(x: 22, y: 35), control: CGPoint(x: 44, y: 34))
                    }.fill(hair)
                }
                ForEach([40.0, 60.0], id: \.self) { x in
                    Circle().fill(Color.sportsRGB(0x322822)).frame(width: 5, height: 6).position(x: x, y: 41)
                    Circle().fill(.white).frame(width: 1.5, height: 1.5).position(x: x - 0.7, y: 40)
                }
                Path { p in p.move(to: CGPoint(x: 42, y: 54)); p.addQuadCurve(to: CGPoint(x: 58, y: 54), control: CGPoint(x: 50, y: 64)) }
                    .stroke(Color.sportsRGB(0x633B2E), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                if friend.glasses {
                    HStack(spacing: 2) { ForEach(0..<2) { _ in RoundedRectangle(cornerRadius: 5).stroke(.indigo, lineWidth: 2).frame(width: 19, height: 15) } }.position(x: 50, y: 42)
                }
                if friend.hearingAid {
                    Capsule().stroke(.teal, lineWidth: 4).frame(width: 8, height: 16).position(x: 80, y: 44)
                }
                if friend.wheelchair {
                    Path { p in p.move(to: CGPoint(x: 24, y: 76)); p.addLine(to: CGPoint(x: 24, y: 109)); p.addLine(to: CGPoint(x: 70, y: 109)); p.addLine(to: CGPoint(x: 81, y: 136)) }
                        .stroke(.teal, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    Circle().fill(Color.sportsRGB(0xE2F5F5)).overlay(Circle().stroke(.indigo, lineWidth: 4)).frame(width: 39, height: 39).position(x: 32, y: 121)
                    ForEach(0..<4) { i in Rectangle().fill(.teal).frame(width: 2, height: 32).rotationEffect(.degrees(Double(i) * 45)).position(x: 32, y: 121) }
                    Circle().fill(.indigo).frame(width: 11, height: 11).position(x: 81, y: 137)
                }
            }.frame(width: 100, height: 150).scaleEffect(scale, anchor: .topLeading)
                .frame(width: g.size.width, height: g.size.height, alignment: .center)
        }.accessibilityElement(children: .ignore).accessibilityLabel(friend.appearance)
    }
}

struct TogetherBall: View {
    let sport: TogetherSport
    var body: some View {
        ZStack {
            switch sport {
            case .soccer:
                Circle().fill(.white).overlay(Circle().stroke(.black.opacity(0.6), lineWidth: 1))
                Image(systemName: "soccerball").resizable().scaledToFit().foregroundStyle(.black)
            case .basketball:
                Circle().fill(.orange)
                Image(systemName: "basketball.fill").resizable().scaledToFit().foregroundStyle(Color.sportsRGB(0xA34C20))
            case .catchBall:
                Circle().fill(.pink).overlay(Circle().stroke(.white, lineWidth: 3).padding(7))
                Image(systemName: "star.fill").resizable().scaledToFit().foregroundStyle(.white).padding(13)
            case .tennis:
                Circle().fill(Color.sportsRGB(0xBDD94B))
                Image(systemName: "tennisball.fill").resizable().scaledToFit().foregroundStyle(Color.sportsRGB(0x6C982B))
            case .bowling:
                Circle().fill(.purple)
                VStack(spacing: 3) { Circle().frame(width: 5, height: 5); HStack(spacing: 4) { Circle().frame(width: 5, height: 5); Circle().frame(width: 5, height: 5) } }.foregroundStyle(.white).offset(y: -4)
            case .hockey:
                Ellipse().fill(.black.opacity(0.8)).frame(height: 22).overlay(Ellipse().stroke(.gray, lineWidth: 2).frame(height: 14).offset(y: -4))
            }
        }.accessibilityLabel(sport == .hockey ? "Hockey puck" : sport.name + " ball")
    }
}

/// An animatable curved route rather than a straight teleport between the players.
private struct TogetherFlight: GeometryEffect {
    var progress: Double
    let size: CGSize
    let sport: TogetherSport
    var animatableData: Double { get { progress } set { progress = newValue } }
    func effectValue(size _: CGSize) -> ProjectionTransform {
        let x = 69 + (size.width - 138) * progress
        let lift: Double
        switch sport {
        case .catchBall, .tennis: lift = sin(progress * .pi) * 65
        case .basketball: lift = -sin(progress * .pi) * 24
        default: lift = 0
        }
        return ProjectionTransform(CGAffineTransform(translationX: x, y: 145 - lift))
    }
}

struct TogetherSportsCourt: View {
    let sport: TogetherSport
    let friend: TogetherFriend
    let progress: Double
    let waiting: Bool
    let shared: Bool
    var body: some View {
        GeometryReader { g in
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 24).fill(background)
                markings(width: g.size.width)
                RescueTeddy(fur: .brown, identity: .boy, items: []).frame(width: 83, height: 120).position(x: 46, y: 89)
                TogetherFriendArt(friend: friend, waving: waiting || shared).frame(width: 84, height: 126).position(x: g.size.width - 46, y: 85)
                if sport == .tennis || sport == .hockey {
                    equipment.frame(width: 25, height: 60).position(x: 73, y: 123)
                    equipment.rotationEffect(.degrees(20)).frame(width: 25, height: 60).position(x: g.size.width - 72, y: 123)
                }
                TogetherBall(sport: sport).frame(width: 38, height: 38)
                    .position(x: 0, y: 0).modifier(TogetherFlight(progress: progress, size: g.size, sport: sport))
                HStack {
                    Text("You").padding(.horizontal, 12).padding(.vertical, 5).background(.white, in: Capsule())
                    Spacer()
                    Text(friend.name).padding(.horizontal, 12).padding(.vertical, 5).background(.white, in: Capsule())
                }.font(.subheadline.bold()).padding(.horizontal, 12).offset(y: 192)
            }.frame(width: g.size.width, height: 235).clipped()
        }.frame(height: 235).accessibilityElement(children: .ignore)
            .accessibilityLabel(sport.name + " with " + friend.appearance)
            .accessibilityValue(waiting ? "Your friend's turn" : "Your turn")
    }
    private var background: Color {
        switch sport {
        case .soccer: return .sportsRGB(0xC5EAC1)
        case .basketball, .bowling: return .sportsRGB(0xF5D7A6)
        case .catchBall: return .sportsRGB(0xD6F0DA)
        case .tennis: return .sportsRGB(0xC6DFEC)
        case .hockey: return .sportsRGB(0xDDEFF9)
        }
    }
    @ViewBuilder private func markings(width: CGFloat) -> some View {
        switch sport {
        case .soccer, .tennis, .hockey:
            RoundedRectangle(cornerRadius: sport == .hockey ? 45 : 4).stroke(.white, lineWidth: 3).padding(.horizontal, 12).padding(.vertical, 17).frame(height: 184)
            Rectangle().fill(.white).frame(width: 3, height: 151).position(x: width / 2, y: 92)
            Circle().stroke(sport == .hockey ? .red.opacity(0.5) : .white, lineWidth: 3).frame(width: 55, height: 55).position(x: width / 2, y: 94)
            if sport == .tennis {
                ForEach(0..<9) { i in Rectangle().fill(.indigo.opacity(0.4)).frame(width: 16, height: 1).position(x: width / 2, y: 30 + Double(i) * 16) }
            }
        case .basketball:
            ForEach(0..<6) { i in Rectangle().fill(.brown.opacity(0.12)).frame(height: 2).offset(y: Double(i) * 30 + 15) }
            Circle().stroke(.white, lineWidth: 3).frame(width: 60, height: 60).position(x: width / 2, y: 90)
            ForEach([20.0, Double(width) - 20], id: \.self) { x in
                RoundedRectangle(cornerRadius: 3).fill(.white).frame(width: 28, height: 21).position(x: x, y: 20)
                Ellipse().stroke(.orange, lineWidth: 3).frame(width: 21, height: 9).position(x: x, y: 33)
            }
        case .bowling:
            ForEach(0..<4) { i in Rectangle().fill(.brown.opacity(0.13)).frame(width: 2, height: 170).position(x: width * Double(i + 1) / 5, y: 85) }
            ForEach(0..<3) { i in
                VStack(spacing: 0) { Circle().fill(.white).frame(width: 9, height: 9); Capsule().fill(.red).frame(width: 8, height: 4); Capsule().fill(.white).frame(width: 16, height: 23) }
                    .rotationEffect(.degrees(shared ? Double(i - 1) * 35 : 0)).position(x: width / 2 + Double(i - 1) * 24, y: 38)
            }
        case .catchBall:
            Circle().fill(.yellow.opacity(0.75)).frame(width: 35, height: 35).position(x: width / 2, y: 28)
            ForEach(0..<4) { i in Image(systemName: "leaf.fill").foregroundStyle(.green.opacity(0.4)).position(x: 25 + Double(i) * (width - 50) / 3, y: 179) }
        }
    }
    @ViewBuilder private var equipment: some View {
        if sport == .tennis {
            VStack(spacing: 0) { Ellipse().stroke(.indigo, lineWidth: 3).frame(width: 25, height: 32).background(Ellipse().fill(.white.opacity(0.5))); Capsule().fill(.brown).frame(width: 5, height: 23) }
        } else {
            Path { p in p.move(to: CGPoint(x: 10, y: 0)); p.addLine(to: CGPoint(x: 10, y: 50)); p.addLine(to: CGPoint(x: 25, y: 50)) }.stroke(.brown, style: StrokeStyle(lineWidth: 5, lineCap: .round))
        }
    }
}
