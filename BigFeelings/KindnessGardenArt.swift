import SwiftUI

struct KindGardenFlower: View {
    let index: Int
    private var petalColor: Color { [Color.pink, .purple, .orange, .blue, .red][index % 5] }
    var body: some View {
        ZStack {
            Capsule().fill(.green).frame(width: 4, height: 34).offset(y: 12)
            Ellipse().fill(.green).frame(width: 17, height: 8).rotationEffect(.degrees(-30)).offset(x: 8, y: 15)
            ForEach(0..<6) { petal in
                Ellipse().fill(petalColor).frame(width: 12, height: 21).offset(y: -11).rotationEffect(.degrees(Double(petal) * 60)).offset(y: -10)
            }
            Circle().fill(.yellow).frame(width: 13, height: 13).offset(y: -10)
        }.frame(width: 48, height: 62)
    }
}
struct KindGardenPlot: View {
    let flowers: Int
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "sun.max.fill").font(.title).foregroundStyle(.orange)
                Text("Our pretend garden").font(.headline)
                Spacer()
                Image(systemName: "cloud.fill").foregroundStyle(.white)
            }.padding(.horizontal, 12)
            ForEach(0..<3) { row in
                HStack(spacing: 2) {
                    ForEach(0..<5) { column in
                        let index = row * 5 + column
                        ZStack {
                            Ellipse().fill(Color.brown.opacity(0.25)).frame(width: 42, height: 12).offset(y: 22)
                            if index < flowers {
                                KindGardenFlower(index: index).transition(.scale(scale: 0.2, anchor: .bottom).combined(with: .opacity))
                            } else {
                                Capsule().fill(.brown.opacity(0.5)).frame(width: 7, height: 4).offset(y: 20)
                            }
                        }.frame(maxWidth: .infinity).frame(height: 62)
                    }
                }.padding(.horizontal, 8).background(.brown.opacity(0.08), in: RoundedRectangle(cornerRadius: 18))
            }
        }.padding(12).background(Color.sportsRGB(0xE0F1D7), in: RoundedRectangle(cornerRadius: 25))
            .accessibilityElement(children: .ignore).accessibilityLabel("Our pretend garden")
            .accessibilityValue("\(flowers) flowers").accessibilityIdentifier("kindness.garden")
    }
}
struct KindGardenScene: View {
    let story: KindGardenStory
    var body: some View {
        HStack(spacing: 14) {
            TogetherFriendArt(friend: TogetherFriend.bank[KindGardenStory.bank.firstIndex(where: { $0.id == story.id })! % 8], waving: true)
                .frame(width: 100, height: 150).scaleEffect(0.7).frame(width: 70, height: 105).accessibilityHidden(true)
            VStack(spacing: 8) {
                if story.id == "shovel" {
                    KindGardenShovel().frame(width: 50, height: 52)
                } else if story.id == "snail" {
                    KindGardenSnail().frame(width: 65, height: 48)
                } else {
                    Image(systemName: story.symbol).font(.system(size: 42)).foregroundStyle(.teal)
                }
                Text(story.title).font(.headline).multilineTextAlignment(.center)
            }.frame(maxWidth: .infinity)
        }.padding(14).background(.white, in: RoundedRectangle(cornerRadius: 22))
            .accessibilityElement(children: .ignore).accessibilityLabel(story.title)
    }
}

private struct KindGardenSnail: View {
    var body: some View {
        ZStack {
            Capsule().fill(.green).frame(width: 60, height: 13).offset(y: 15)
            Capsule().fill(.green).frame(width: 12, height: 28).offset(x: 23, y: 6)
            Circle().fill(.brown).frame(width: 35, height: 35).offset(x: -6, y: -1)
            Path { p in
                for i in 0..<40 {
                    let angle = Double(i) * 0.3
                    let radius = Double(i) * 0.32
                    let point = CGPoint(x: 26 + cos(angle) * radius, y: 23 + sin(angle) * radius)
                    if i == 0 { p.move(to: point) } else { p.addLine(to: point) }
                }
            }.stroke(.orange, lineWidth: 2)
            Circle().fill(.black).frame(width: 3, height: 3).offset(x: 24, y: -2)
        }
    }
}

private struct KindGardenShovel: View {
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 5).stroke(.orange, lineWidth: 4).frame(width: 20, height: 13)
            Rectangle().fill(.orange).frame(width: 5, height: 18)
            UnevenRoundedRectangle(topLeadingRadius: 2, bottomLeadingRadius: 13, bottomTrailingRadius: 13, topTrailingRadius: 2)
                .fill(.teal).frame(width: 26, height: 21)
        }.rotationEffect(.degrees(18))
    }
}
