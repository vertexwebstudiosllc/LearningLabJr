import SwiftUI

/// Small vector pictures stay crisp on phones and tablets without image backgrounds.
struct SolutionToolArt: View {
    let tool: SolutionTool
    private var color: Color {
        switch tool.id {
        case "water", "cup", "boots", "umbrella": return .blue
        case "can", "snack", "ball": return .green
        case "coat", "hat", "lamp": return .orange
        case "book", "glue", "paper", "blanket": return .purple
        case "basket", "box", "brush", "ramp": return .brown
        default: return .teal
        }
    }
    var body: some View {
        ZStack {
            switch tool.id {
            case "can":
                Ellipse().stroke(.teal, lineWidth: 6).frame(width: 25, height: 30).offset(x: -24, y: -3)
                Rectangle().fill(.teal).frame(width: 30, height: 10).rotationEffect(.degrees(-35)).offset(x: 28, y: -8)
                RoundedRectangle(cornerRadius: 8).fill(.teal).frame(width: 40, height: 32).offset(y: 9)
                Ellipse().fill(.mint).frame(width: 27, height: 8).offset(y: -9)
            case "hat":
                UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24).fill(.orange).frame(width: 55, height: 36)
                Capsule().fill(.yellow).frame(width: 61, height: 12).offset(y: 18)
                Circle().fill(.yellow).frame(width: 16).offset(y: -22)
            case "cloth", "towel":
                RoundedRectangle(cornerRadius: 7).fill(tool.id == "cloth" ? Color.mint : .cyan).frame(width: 57, height: 43).rotationEffect(.degrees(-8))
                HStack(spacing: 7) {
                    ForEach(0..<3) { _ in Rectangle().fill(.white.opacity(0.6)).frame(width: 4, height: 35) }
                }.rotationEffect(.degrees(-8))
            case "glue":
                RoundedRectangle(cornerRadius: 4).fill(.purple).frame(width: 25, height: 51)
                Rectangle().fill(.white).frame(width: 25, height: 24)
                Image(systemName: "heart.fill").font(.caption).foregroundStyle(.purple)
                Capsule().fill(.orange).frame(width: 29, height: 9).offset(y: -23)
            case "boots":
                HStack(spacing: 5) {
                    ForEach(0..<2) { _ in
                        ZStack(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: 4).fill(.blue).frame(width: 18, height: 43)
                            RoundedRectangle(cornerRadius: 6).fill(.blue).frame(width: 31, height: 15)
                            Capsule().fill(.yellow).frame(width: 32, height: 5).offset(y: 2)
                        }
                    }
                }
            case "crayons":
                HStack(spacing: 3) {
                    ForEach(Array([Color.pink, .orange, .teal].enumerated()), id: \.offset) { index, color in
                        VStack(spacing: 0) {
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: 12)); path.addLine(to: CGPoint(x: 7, y: 0)); path.addLine(to: CGPoint(x: 14, y: 12)); path.closeSubpath()
                            }.fill(color).frame(width: 14, height: 12)
                            RoundedRectangle(cornerRadius: 2).fill(color).frame(width: 14, height: 34)
                                .overlay(Rectangle().fill(.white.opacity(0.6)).frame(height: 15))
                        }.rotationEffect(.degrees(Double(index - 1) * 12))
                    }
                }
            default:
                Image(systemName: tool.symbol).font(.system(size: 45)).symbolRenderingMode(.hierarchical).foregroundStyle(color)
            }
        }.frame(width: 90, height: 60).accessibilityHidden(true)
    }
}

struct SolutionSituationArt: View {
    let problem: SolutionProblem
    let solved: Bool
    var body: some View {
        ZStack {
            switch problem.id {
            case "toy", "bridge":
                if problem.id == "bridge" {
                    HStack(spacing: solved ? 0 : 32) {
                        RoundedRectangle(cornerRadius: 3).fill(.brown).frame(width: 45, height: 13)
                        RoundedRectangle(cornerRadius: 3).fill(.brown).frame(width: 45, height: 13)
                    }.offset(y: 29)
                    if solved { Rectangle().fill(.orange).frame(width: 70, height: 8).offset(y: 23) }
                }
                RoundedRectangle(cornerRadius: 10).fill(.red).frame(width: 90, height: 29)
                RoundedRectangle(cornerRadius: 8).fill(.orange).frame(width: 52, height: 23).offset(y: -21)
                RoundedRectangle(cornerRadius: 3).fill(.cyan.opacity(0.7)).frame(width: 30, height: 16).offset(y: -21)
                Circle().fill(.indigo).frame(width: 22).offset(x: -27, y: 18)
                Circle().fill(.indigo).frame(width: 22).offset(x: solved || problem.id == "bridge" ? 27 : 51, y: solved || problem.id == "bridge" ? 18 : 32)
            case "plant":
                RoundedRectangle(cornerRadius: 5).fill(.orange).frame(width: 45, height: 35).offset(y: 25)
                Rectangle().fill(.green).frame(width: 5, height: 51).rotationEffect(.degrees(solved ? 0 : 16)).offset(y: -7)
                Image(systemName: "leaf.fill").font(.system(size: 35)).foregroundStyle(solved ? .green : .brown).rotationEffect(.degrees(solved ? -35 : 50)).offset(x: -12, y: -22)
                Image(systemName: "leaf.fill").font(.system(size: 30)).foregroundStyle(solved ? .green : .brown).offset(x: 15, y: -10)
            case "spill":
                RoundedRectangle(cornerRadius: 5).fill(.brown).frame(width: 112, height: 15).offset(y: 25)
                Image(systemName: "cup.and.saucer.fill").font(.system(size: 35)).foregroundStyle(.orange).rotationEffect(.degrees(solved ? 0 : 65)).offset(x: -29, y: 1)
                if !solved { Ellipse().fill(.cyan.opacity(0.75)).frame(width: 60, height: 12).offset(x: 20, y: 13) }
                else { Image(systemName: "sparkles").font(.largeTitle).foregroundStyle(.teal).offset(x: 25, y: -9) }
            case "toys":
                if solved { SolutionToolArt(tool: .named("box")) }
                else {
                    Image(systemName: "soccerball").font(.system(size: 36)).foregroundStyle(.teal).offset(x: -25, y: 20)
                    Image(systemName: "car.side.fill").font(.system(size: 38)).foregroundStyle(.orange).rotationEffect(.degrees(-25)).offset(x: 24, y: -15)
                    Rectangle().fill(.purple).frame(width: 24, height: 24).rotationEffect(.degrees(15)).offset(x: 30, y: 30)
                }
            case "winter":
                VStack(spacing: 0) {
                    if solved { SolutionToolArt(tool: .named("hat")).scaleEffect(0.65).frame(height: 33) }
                    Image(systemName: solved ? "jacket.fill" : "tshirt.fill").font(.system(size: 62)).foregroundStyle(solved ? .orange : .cyan)
                }
                if !solved {
                    Image(systemName: "snowflake").foregroundStyle(.blue).offset(x: -46, y: -25)
                    Image(systemName: "snowflake").foregroundStyle(.blue).offset(x: 46, y: 25)
                }
            case "dark":
                if solved { Circle().fill(.yellow.opacity(0.25)).frame(width: 115) }
                Image(systemName: "book.fill").font(.system(size: 65)).foregroundStyle(solved ? .purple : .indigo.opacity(0.45))
                if solved { Image(systemName: "lamp.desk.fill").font(.system(size: 40)).foregroundStyle(.orange).offset(x: 35, y: -30) }
            case "paper":
                HStack(spacing: solved ? 0 : 12) {
                    Rectangle().fill(.white).frame(width: 35, height: 70).overlay(Image(systemName: "sun.max.fill").foregroundStyle(.orange))
                    Rectangle().fill(.white).frame(width: 35, height: 70).overlay(Image(systemName: "leaf.fill").foregroundStyle(.green))
                }.rotationEffect(.degrees(solved ? 0 : -8))
                if solved { Rectangle().fill(.yellow.opacity(0.5)).frame(width: 17, height: 60) }
            default:
                Image(systemName: solved ? problem.after : problem.before).font(.system(size: 70)).foregroundStyle(solved ? .teal : .indigo)
            }
        }.frame(width: 125, height: 95).accessibilityHidden(true)
    }
}
