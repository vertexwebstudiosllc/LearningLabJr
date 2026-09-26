import SwiftUI

struct SpaceDiscoveryView: View {
    let storyID: String
    let lesson: SpaceDiscovery
    @Binding var progress: SpaceDiscoveryProgress
    var review = false
    let explain: () -> Void
    @State private var feedback = ""
    @State private var answers: [String] = []
    var body: some View {
        VStack(spacing: 16) {
            Text(review ? "Show what you discovered" : lesson.title).font(.title3.bold())
            if review {
                Text(lesson.question).font(.headline).multilineTextAlignment(.center)
                HStack(spacing: 12) {
                    ForEach(answers, id: \.self) { answer in
                        Button {
                            if progress.answer(answer, in: lesson) { feedback = lesson.takeaway }
                            else { feedback = "Let's look and listen again. " + lesson.question }
                            explain()
                        } label: {
                            VStack {
                                Image("SpaceClean/" + answer).resizable().scaledToFit().frame(height: 95)
                                Text(answer).font(.headline)
                                if progress.answered && answer == lesson.answer { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                            }.frame(maxWidth: .infinity, minHeight: 150).padding(10)
                                .background(.white, in: RoundedRectangle(cornerRadius: 20))
                        }.buttonStyle(.plain).disabled(progress.answered)
                            .accessibilityIdentifier("space.answer." + answer)
                    }
                }
            } else {
                SpaceDiscoveryDiagram(storyID: storyID, visited: progress.visited).frame(height: 200)
                Text(progress.nextStep(in: lesson)?.instruction ?? lesson.takeaway)
                    .font(.headline).multilineTextAlignment(.center).accessibilityIdentifier("space.discovery.clue")
                HStack(alignment: .top, spacing: 8) {
                    ForEach(lesson.steps) { step in
                        Button {
                            if progress.explore(step.id, in: lesson) {
                                feedback = step.finding
                                if progress.nextStep(in: lesson) == nil { explain() }
                            } else {
                                feedback = progress.nextStep(in: lesson)?.instruction ?? lesson.takeaway
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: progress.visited.contains(step.id) ? "checkmark.circle.fill" : step.symbol).font(.system(size: 28))
                                Text(step.title).font(.system(.subheadline, design: .rounded, weight: .bold))
                                    .multilineTextAlignment(.center)
                            }.frame(maxWidth: .infinity, minHeight: 98).padding(5)
                                .background(progress.visited.contains(step.id) ? Color.green.opacity(0.16) : Color.white, in: RoundedRectangle(cornerRadius: 18))
                                .overlay(RoundedRectangle(cornerRadius: 18).stroke(.indigo.opacity(0.3), lineWidth: 2))
                        }.buttonStyle(.plain)
                            .accessibilityIdentifier("space.discovery." + step.id)
                            .accessibilityValue(progress.visited.contains(step.id) ? "Found" : progress.nextStep(in: lesson)?.id == step.id ? "Next discovery" : "Waiting")
                    }
                }
                Text("\(progress.visited.count) of \(lesson.steps.count) discoveries").font(.subheadline)
                    .accessibilityIdentifier("space.discovery.progress")
            }
            if !feedback.isEmpty { Text(feedback).multilineTextAlignment(.center).font(.subheadline).accessibilityIdentifier("space.discovery.feedback") }
        }
        .onAppear { if answers.isEmpty { answers = [lesson.answer, lesson.alternative].shuffled() } }
    }
}

/// Simplified teaching models, deliberately separate from the smiling planet illustrations.
struct SpaceDiscoveryDiagram: View {
    let storyID: String
    let visited: Set<String>
    private var count: Int { visited.count }
    var body: some View {
        GeometryReader { g in
            ZStack {
                RoundedRectangle(cornerRadius: 24).fill(Color(red: 0.06, green: 0.1, blue: 0.24))
                diagram.frame(width: 300, height: 180)
                    .scaleEffect(min(g.size.width / 320, g.size.height / 200))
                    .position(x: g.size.width / 2, y: g.size.height / 2)
            }
        }.accessibilityElement(children: .ignore)
            .accessibilityLabel(SpaceDiscovery.bank[storyID]?.takeaway ?? "Space discovery model")
    }
    private func planet(_ name: String, size: CGFloat = 90) -> some View {
        Image("SpaceClean/" + name).resizable().scaledToFit().frame(width: size, height: size)
    }
    @ViewBuilder private var diagram: some View {
        switch storyID {
        case "moon-craters":
            ZStack {
                Circle().fill(.gray).frame(width: 162)
                if count > 0 {
                    Circle().fill(.black.opacity(0.4)).overlay(Circle().stroke(visited.contains("big") ? .yellow : .white.opacity(0.5), lineWidth: 4))
                        .frame(width: 55).offset(x: -30, y: -10)
                    Circle().fill(.black.opacity(0.4)).overlay(Circle().stroke(visited.contains("little") ? .yellow : .white.opacity(0.5), lineWidth: 3))
                        .frame(width: 27).offset(x: 37, y: 35)
                    Circle().fill(.black.opacity(0.25)).frame(width: 20).offset(x: 27, y: -40)
                }
                Image(systemName: "mountain.2.fill").font(.system(size: 30)).foregroundStyle(.brown).offset(x: -108, y: count > 0 ? 30 : -65)
            }
        case "moon-shine", "sun-star":
            HStack(spacing: 5) {
                planet("Sun", size: 73)
                Image(systemName: "arrow.right").foregroundStyle(count > 0 ? .yellow : .gray)
                planet(storyID == "moon-shine" ? "Moon" : "Earth", size: 73)
                Image(systemName: "arrow.right").foregroundStyle(count > 1 ? .yellow : .gray)
                if storyID == "moon-shine" { planet("Earth", size: 73) }
                else { Image(systemName: "leaf.fill").font(.system(size: count > 2 ? 58 : 27)).foregroundStyle(.green).frame(width: 65) }
            }
        case "earth-blue":
            ZStack {
                Circle().fill(.blue).frame(width: 160)
                Ellipse().fill(.green).frame(width: 58, height: 88).rotationEffect(.degrees(-25)).offset(x: -25)
                Ellipse().fill(.green).frame(width: 37, height: 55).offset(x: 40, y: 33)
                if visited.contains("ocean") { Image(systemName: "water.waves").foregroundStyle(.cyan).font(.system(size: 30)).offset(x: 30, y: -40) }
                if visited.contains("land") { Image(systemName: "tree.fill").foregroundStyle(.yellow).font(.system(size: 27)).offset(x: -25) }
                if visited.contains("cloud") { Image(systemName: "cloud.fill").foregroundStyle(.white).font(.system(size: 55)).offset(x: 27, y: -65) }
            }
        case "earth-day":
            HStack(spacing: 25) {
                planet("Sun", size: 75)
                ZStack {
                    Circle().fill(.blue).frame(width: 130)
                    HStack(spacing: 0) { Color.yellow.opacity(count > 0 ? 0.55 : 0); Color.black.opacity(0.65) }.frame(width: 130, height: 130).clipShape(Circle())
                    Image(systemName: "house.fill").foregroundStyle(.white).font(.system(size: 23)).offset(x: visited.contains("night") ? 37 : -37)
                    Image(systemName: "arrow.clockwise").font(.system(size: 24)).foregroundStyle(.white).offset(y: 80)
                }
            }
        case "mars-moons":
            ZStack {
                Ellipse().stroke(.white.opacity(0.35), lineWidth: 2).frame(width: 265, height: 128)
                planet("Mars")
                ForEach(["Phobos", "Deimos"], id: \.self) { name in
                    VStack(spacing: 4) {
                        Ellipse().fill(visited.contains(name) ? Color.yellow : .gray).frame(width: name == "Phobos" ? 26 : 18, height: 22)
                        Text(name).font(.caption).foregroundStyle(.white)
                    }.offset(x: name == "Phobos" ? -108 : 108, y: name == "Phobos" ? -42 : 42)
                }
            }
        case "mars-rover":
            ZStack {
                RoundedRectangle(cornerRadius: 20).fill(.orange.opacity(0.45)).frame(width: 280, height: 35).offset(y: 60)
                Image(systemName: "mountain.2.fill").font(.system(size: 50)).foregroundStyle(.brown).offset(x: 90, y: 28)
                VStack(spacing: 0) {
                    Image(systemName: "camera.fill").font(.system(size: 30)).foregroundStyle(visited.contains("camera") ? .yellow : .white)
                    RoundedRectangle(cornerRadius: 8).fill(.orange).frame(width: 65, height: 25)
                    HStack { Circle().frame(width: 20); Circle().frame(width: 20) }.foregroundStyle(.gray)
                }.offset(x: count > 0 ? 0 : -90, y: 23)
                if visited.contains("rock") { Image(systemName: "magnifyingglass").font(.system(size: 40)).foregroundStyle(.yellow).offset(x: 92, y: -18) }
            }
        case "jupiter-stripes", "jupiter-storm":
            ZStack {
                VStack(spacing: 0) { ForEach(0..<7) { i in Rectangle().fill(i.isMultiple(of: 2) ? Color.orange.opacity(0.65) : Color(red: 0.92, green: 0.8, blue: 0.57)) } }
                    .frame(width: 170, height: 170).clipShape(Circle())
                if storyID == "jupiter-storm" {
                    Ellipse().fill(.red.opacity(0.8)).frame(width: 60, height: 33).offset(x: 26, y: 25)
                    Image(systemName: "hurricane").font(.system(size: 29)).foregroundStyle(.yellow)
                        .rotationEffect(.degrees(visited.contains("wind") ? 120 : 0)).offset(x: 26, y: 25)
                } else {
                    if visited.contains("light") { Capsule().stroke(.yellow, lineWidth: 3).frame(width: 135, height: 20).offset(y: -48) }
                    if visited.contains("dark") { Capsule().stroke(.white, lineWidth: 3).frame(width: 160, height: 20).offset(y: -24) }
                }
                if visited.contains("ship") { planet("Rocket", size: 55).offset(x: 110, y: -60) }
            }
        case "saturn-rings", "saturn-postcard":
            ZStack {
                Circle().fill(.orange.opacity(0.9)).frame(width: 100)
                Ellipse().stroke(.white.opacity(0.3), lineWidth: 2).frame(width: 265, height: 90)
                ForEach(0..<24) { i in
                    let angle = Double(i) * .pi / 12
                    Image(systemName: i.isMultiple(of: 2) ? "snowflake" : "diamond.fill")
                        .font(.system(size: 11)).foregroundStyle(i.isMultiple(of: 2) ? .cyan : .gray)
                        .opacity(visited.contains(i.isMultiple(of: 2) ? "ice" : "rock") || visited.contains("ring") ? 1 : 0.16)
                        .offset(x: cos(angle) * 132, y: sin(angle) * 45)
                }
                if storyID == "saturn-postcard" { RoundedRectangle(cornerRadius: 14).stroke(.white, lineWidth: 3).frame(width: 292, height: 171) }
            }
        default:
            ZStack {
                Ellipse().fill(.brown).frame(width: 160, height: 32).offset(y: 65)
                Image(systemName: "leaf.fill").font(.system(size: count == 3 ? 76 : 23)).foregroundStyle(.green).offset(y: count == 3 ? 7 : 42)
                if visited.contains("water") { Image(systemName: "drop.fill").font(.system(size: 30)).foregroundStyle(.cyan).offset(x: -90, y: -4) }
                if visited.contains("air") { Image(systemName: "wind").font(.system(size: 30)).foregroundStyle(.white).offset(x: 90, y: 0) }
                if visited.contains("Sun") { planet("Sun", size: 65).offset(x: 95, y: -60) }
            }
        }
    }
}
