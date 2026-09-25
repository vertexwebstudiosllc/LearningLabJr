import SwiftUI
import UIKit

struct WeatherWindowGame: View {
    @State private var play = WeatherWindowPlay()

    var body: some View {
        ToddlerGameScaffold(title: "Weather Window", prompt: play.current.narration, accent: .indigo) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                ForEach(WindowCondition.all) { condition in
                    Button { play.choose(condition.id) } label: {
                        VStack(spacing: 6) {
                            Image(systemName: condition.symbol).font(.title2)
                            Text(condition.title).font(.system(.subheadline, design: .rounded, weight: .bold))
                        }
                        .frame(maxWidth: .infinity, minHeight: 72)
                        .foregroundStyle(play.condition.id == condition.id ? .white : .indigo)
                        .background(play.condition.id == condition.id ? Color.indigo : Color.indigo.opacity(0.09), in: RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(play.condition.id == condition.id ? [.isSelected] : [])
                    .accessibilityIdentifier("weather.choose.\(condition.id)")
                }
            }
            VStack(spacing: 12) {
                WeatherWindowScene(condition: play.condition.id, discovery: play.current.id)
                    .aspectRatio(1.3, contentMode: .fit)
                    .frame(maxWidth: 520)
                    .contentShape(Rectangle())
                    .overlay {
                        WeatherSwipeSurface { play.move($0) }
                            .accessibilityHidden(true)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(play.condition.title). \(play.current.title). Discovery \(play.pageIndex + 1) of \(play.condition.pages.count)")
                    .accessibilityHint("Swipe left or right to explore the view")
                    .accessibilityAdjustableAction { direction in
                        switch direction { case .increment: play.move(1); case .decrement: play.move(-1); default: break }
                    }
                    .accessibilityIdentifier("weather.window")
                Text(play.current.title).font(.system(.title2, design: .rounded, weight: .bold))
                    .accessibilityIdentifier("weather.page")
                HStack(spacing: 22) {
                    pageButton("Previous discovery", symbol: "arrow.left", direction: -1)
                    VStack(spacing: 6) {
                        Text("\(play.pageIndex + 1) of \(play.condition.pages.count)").font(.headline)
                        HStack(spacing: 6) {
                            ForEach(0..<play.condition.pages.count, id: \.self) { index in
                                Circle().fill(index == play.pageIndex ? .indigo : .indigo.opacity(0.2)).frame(width: 8, height: 8)
                            }
                        }.accessibilityHidden(true)
                    }
                    pageButton("Next discovery", symbol: "arrow.right", direction: 1)
                }
                Text("Swipe the window to explore").font(.subheadline)
                Text("\(play.visited.count) of \(play.total) discoveries explored")
                    .font(.caption.bold()).accessibilityIdentifier("weather.progress")
            }
        }
    }

    private func pageButton(_ title: String, symbol: String, direction: Int) -> some View {
        Button { play.move(direction) } label: {
            Image(systemName: symbol).font(.title2.bold()).frame(width: 64, height: 60)
                .foregroundStyle(.white).background(.indigo, in: RoundedRectangle(cornerRadius: 18))
        }.buttonStyle(.plain).accessibilityLabel(title)
            .accessibilityIdentifier(direction == 1 ? "weather.next" : "weather.previous")
    }
}

/// The illustrations are vector compositions, so every scene has a clean background at any screen size.
private struct WeatherWindowScene: View {
    let condition: String
    let discovery: String
    private var night: Bool { condition == "night" }
    private var snow: Bool { condition == "snow" }
    private var autumn: Bool { condition == "fall" }
    private var overview: Bool { discovery == "overview" }
    private var sky: Color {
        switch condition {
        case "night": return Color(red: 0.1, green: 0.13, blue: 0.32)
        case "rain": return Color(red: 0.48, green: 0.65, blue: 0.77)
        case "snow": return Color(red: 0.66, green: 0.78, blue: 0.89)
        case "fall": return Color(red: 0.97, green: 0.81, blue: 0.59)
        default: return Color(red: 0.46, green: 0.8, blue: 0.96)
        }
    }
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            ZStack {
                LinearGradient(colors: [sky, sky.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                Ellipse().fill(snow ? Color.white : night ? Color(red: 0.15, green: 0.3, blue: 0.3) : autumn ? Color(red: 0.71, green: 0.66, blue: 0.3) : Color(red: 0.4, green: 0.71, blue: 0.39))
                    .frame(width: w * 1.7, height: h * 0.65).position(x: w / 2, y: h)
                if night {
                    ForEach(0..<12, id: \.self) { i in
                        Image(systemName: "star.fill").font(.system(size: CGFloat(5 + i % 3 * 3)))
                            .foregroundStyle(.yellow.opacity(0.9))
                            .position(x: w * CGFloat((i * 37 + 13) % 90 + 5) / 100, y: h * CGFloat((i * 19 + 7) % 40 + 6) / 100)
                    }
                }
                Image(systemName: night ? "moon.fill" : condition == "sunshine" || autumn ? "sun.max.fill" : "cloud.fill")
                    .font(.system(size: w * 0.16)).foregroundStyle(night || condition == "sunshine" || autumn ? .yellow : .white.opacity(0.95))
                    .position(x: w * 0.79, y: h * 0.2)
                tree.frame(width: w * 0.22, height: h * 0.4).position(x: w * 0.14, y: h * 0.68)
                house.frame(width: w * 0.2, height: h * 0.26).position(x: w * 0.84, y: h * 0.77)
                if condition == "rain" || snow {
                    ForEach(0..<18, id: \.self) { i in
                        Image(systemName: snow ? "snowflake" : "drop.fill")
                            .font(.system(size: snow ? 12 : 8)).foregroundStyle(snow ? .white : .blue.opacity(0.65))
                            .position(x: w * CGFloat((i * 29 + 7) % 90 + 5) / 100, y: h * CGFloat((i * 17 + 8) % 72 + 8) / 100)
                    }
                }
                if overview {
                    overviewDetail.frame(width: w * 0.4, height: h * 0.42).position(x: w * 0.5, y: h * 0.61)
                } else {
                    discoveryArt.frame(width: w * 0.48, height: h * 0.56).position(x: w * 0.5, y: h * 0.56)
                }
                // The frame sits around the scene without obscuring the discovery in its center.
                RoundedRectangle(cornerRadius: 25).strokeBorder(Color(red: 0.63, green: 0.38, blue: 0.23), lineWidth: 13)
                RoundedRectangle(cornerRadius: 22).strokeBorder(.white.opacity(0.65), lineWidth: 3).padding(13)
                Capsule().fill(Color(red: 0.8, green: 0.58, blue: 0.37)).frame(height: 15).frame(maxHeight: .infinity, alignment: .bottom)
            }.clipShape(RoundedRectangle(cornerRadius: 25))
        }
    }

    private var tree: some View {
        GeometryReader { g in
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4).fill(.brown).frame(width: g.size.width * 0.16, height: g.size.height * 0.4)
                Image(systemName: "tree.fill").resizable().scaledToFit()
                    .foregroundStyle(snow ? .white : autumn ? .orange : night ? .teal.opacity(0.8) : .green)
            }
        }
    }
    private var house: some View {
        GeometryReader { g in
            ZStack {
                Image(systemName: "house.fill").resizable().scaledToFit().foregroundStyle(night ? .indigo : .orange.opacity(0.85))
                HStack(spacing: g.size.width * 0.16) {
                    ForEach(0..<2, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2).fill(night ? .yellow : .cyan.opacity(0.7))
                            .frame(width: g.size.width * 0.18, height: g.size.height * 0.22)
                    }
                }.offset(y: g.size.height * 0.12)
            }
        }
    }
    @ViewBuilder private var overviewDetail: some View {
        switch condition {
        case "sunshine": flower
        case "rain": puddle
        case "wind": symbol("wind", color: .white)
        case "night": house
        case "snow": snowman
        default: leaves
        }
    }
    @ViewBuilder private var discoveryArt: some View {
        switch discovery {
        case "flower": flower
        case "butterfly": ZStack { flower.scaleEffect(0.55).offset(x: -25, y: 35); butterfly.scaleEffect(0.65).offset(x: 20, y: -20) }
        case "shadow": ZStack { Ellipse().fill(.black.opacity(0.23)).frame(height: 24).rotationEffect(.degrees(-15)).offset(x: 30, y: 65); tree }
        case "bird": symbol("bird.fill", color: .blue)
        case "umbrella": symbol("umbrella.fill", color: .pink)
        case "puddle": puddle
        case "boots": boots
        case "wetleaves": ZStack { leaves; HStack { symbol("drop.fill", color: .cyan); symbol("drop.fill", color: .cyan) }.scaleEffect(0.3).offset(y: -10) }
        case "kite": kite
        case "flag": symbol("flag.fill", color: .pink)
        case "leaves": leaves
        case "pinwheel": pinwheel
        case "moon": Image("SpaceClean/Moon").resizable().scaledToFit()
        case "stars": symbol("sparkles", color: .yellow)
        case "cat": Image("FamilyClean/cat").resizable().scaledToFit()
        case "windows": house
        case "snowman": snowman
        case "sled": sled
        case "tracks": tracks
        case "snowflake": symbol("snowflake", color: .blue)
        case "acorn": acorn
        case "pumpkin": pumpkin
        case "squirrel": squirrel
        default: EmptyView()
        }
    }
    private func symbol(_ name: String, color: Color) -> some View {
        Image(systemName: name).resizable().scaledToFit().foregroundStyle(color).padding(8)
    }
    private var butterfly: some View {
        ZStack {
            ForEach([-1, 1], id: \.self) { side in
                Ellipse().fill(.purple).frame(width: 67, height: 91)
                    .rotationEffect(.degrees(Double(side) * 30)).offset(x: CGFloat(side) * 34, y: -20)
                Ellipse().fill(.pink).frame(width: 49, height: 58)
                    .rotationEffect(.degrees(Double(side) * -25)).offset(x: CGFloat(side) * 26, y: 31)
                Capsule().fill(.indigo).frame(width: 3, height: 29)
                    .rotationEffect(.degrees(Double(side) * 30)).offset(x: CGFloat(side) * 9, y: -52)
            }
            Capsule().fill(.indigo).frame(width: 14, height: 83)
        }
    }
    private var flower: some View {
        GeometryReader { g in
            ZStack {
                Capsule().fill(.green).frame(width: 9, height: g.size.height * 0.6).offset(y: g.size.height * 0.22)
                ForEach(0..<8, id: \.self) { i in
                    Ellipse().fill(.pink).frame(width: g.size.width * 0.2, height: g.size.height * 0.34)
                        .offset(y: -g.size.height * 0.17).rotationEffect(.degrees(Double(i) * 45))
                }
                Circle().fill(.yellow).frame(width: g.size.width * 0.28)
            }.frame(width: g.size.width, height: g.size.height)
        }
    }
    private var puddle: some View {
        ZStack {
            Ellipse().fill(.cyan.opacity(0.7))
            ForEach(1..<4, id: \.self) { i in Ellipse().stroke(.white.opacity(0.75), lineWidth: 2).padding(CGFloat(i) * 10) }
        }.frame(height: 65).offset(y: 40)
    }
    private var boots: some View {
        HStack(spacing: 14) {
            ForEach(0..<2, id: \.self) { _ in
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 9).fill(.yellow).frame(width: 45, height: 100)
                    RoundedRectangle(cornerRadius: 13).fill(.yellow).frame(width: 67, height: 33)
                    Capsule().fill(.orange).frame(width: 67, height: 9)
                    Rectangle().fill(.orange).frame(width: 45, height: 10).offset(y: -88)
                }
            }
        }
    }
    private var leaves: some View {
        HStack(spacing: -8) {
            ForEach(0..<3, id: \.self) { i in
                symbol("leaf.fill", color: condition == "rain" ? [Color.green, .mint, .green][i] : [.orange, .yellow, .red][i]).rotationEffect(.degrees(Double(i - 1) * 40)).offset(y: i == 1 ? -20 : 20)
            }
        }
    }
    private var kite: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle().fill(.pink)
                Rectangle().fill(.yellow).frame(width: 3)
                Rectangle().fill(.yellow).frame(height: 3)
            }.frame(width: 74, height: 74).rotationEffect(.degrees(45))
            Text("〰\n🎀\n〰").font(.system(size: 24)).offset(x: 10, y: 12)
        }
    }
    private var pinwheel: some View {
        ZStack {
            Capsule().fill(.brown).frame(width: 7, height: 115).offset(y: 44)
            ForEach(0..<4, id: \.self) { i in
                Ellipse().fill([Color.pink, .yellow, .cyan, .purple][i]).frame(width: 38, height: 65)
                    .rotationEffect(.degrees(30)).offset(y: -30).rotationEffect(.degrees(Double(i) * 90))
            }
            Circle().fill(.white).frame(width: 16)
        }
    }
    private var snowman: some View {
        VStack(spacing: -8) {
            ZStack {
                Circle().fill(.white).shadow(color: .blue.opacity(0.2), radius: 2).frame(width: 58, height: 58)
                HStack(spacing: 14) { Circle().frame(width: 5); Circle().frame(width: 5) }.foregroundStyle(.black).offset(y: -6)
                Capsule().fill(.orange).frame(width: 18, height: 7).offset(x: 7, y: 5)
            }
            Capsule().fill(.red).frame(width: 56, height: 10).zIndex(1)
            ZStack {
                Circle().fill(.white).shadow(color: .blue.opacity(0.2), radius: 2).frame(width: 91, height: 91)
                VStack(spacing: 12) { ForEach(0..<3, id: \.self) { _ in Circle().fill(.indigo).frame(width: 6, height: 6) } }
            }
        }
    }
    private var sled: some View {
        ZStack {
            HStack(spacing: 55) {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16).stroke(.red, lineWidth: 7).frame(width: 22, height: 110)
                }
            }.rotationEffect(.degrees(65)).offset(y: 23)
            VStack(spacing: 5) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4).fill(.brown).frame(width: 130, height: 14)
                }
            }.rotationEffect(.degrees(-12))
        }
    }
    private var tracks: some View {
        VStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { i in
                Capsule().fill(Color.blue.opacity(0.3)).frame(width: 19, height: 33).rotationEffect(.degrees(i % 2 == 0 ? -20 : 20)).offset(x: i % 2 == 0 ? -20 : 20)
            }
        }.rotationEffect(.degrees(20))
    }
    private var acorn: some View {
        ZStack(alignment: .top) {
            Ellipse().fill(Color(red: 0.66, green: 0.38, blue: 0.15)).frame(width: 85, height: 115)
            Capsule().fill(.brown).frame(width: 12, height: 32).offset(y: -19)
            Ellipse().fill(Color(red: 0.4, green: 0.24, blue: 0.12)).frame(width: 102, height: 40)
        }
    }
    private var squirrel: some View {
        ZStack {
            // A curled bushy tail, rounded body, pointed ears, and a seed held in its paws.
            Ellipse().fill(.brown).frame(width: 65, height: 119).rotationEffect(.degrees(25)).offset(x: 45, y: -10)
            Ellipse().fill(Color(red: 0.8, green: 0.57, blue: 0.34)).frame(width: 35, height: 80).rotationEffect(.degrees(25)).offset(x: 49, y: -17)
            Ellipse().fill(.brown).frame(width: 73, height: 93).offset(y: 27)
            Ellipse().fill(Color(red: 0.91, green: 0.76, blue: 0.55)).frame(width: 40, height: 65).offset(x: -10, y: 30)
            Ellipse().fill(.brown).frame(width: 19, height: 39).rotationEffect(.degrees(-15)).offset(x: -9, y: -61)
            Ellipse().fill(.brown).frame(width: 69, height: 55).offset(x: -17, y: -35)
            Circle().fill(.black).frame(width: 8).offset(x: -23, y: -40)
            Circle().fill(.black).frame(width: 9).offset(x: -50, y: -29)
            acorn.scaleEffect(0.27).offset(x: -40, y: 14)
            Capsule().fill(.brown).frame(width: 35, height: 13).rotationEffect(.degrees(-15)).offset(x: -27, y: 17)
            Capsule().fill(.brown).frame(width: 41, height: 16).offset(x: -16, y: 68)
        }
    }
    private var pumpkin: some View {
        ZStack {
            Capsule().fill(.green).frame(width: 18, height: 42).rotationEffect(.degrees(15)).offset(y: -55)
            ForEach(-2...2, id: \.self) { i in
                Ellipse().fill(i % 2 == 0 ? Color.orange : Color(red: 1, green: 0.66, blue: 0.14))
                    .frame(width: 62, height: 98).offset(x: CGFloat(i) * 19)
            }
            Ellipse().fill(.orange).frame(width: 39, height: 98)
        }
    }
}

/// A horizontal pan inside the picture takes precedence over iOS's navigation-back pans.
/// Vertical pans still belong to the containing scroll view; swiping outside the picture is unchanged.
private struct WeatherSwipeSurface: UIViewRepresentable {
    let move: (Int) -> Void
    func makeUIView(context: Context) -> SwipeView { SwipeView(move: move) }
    func updateUIView(_ uiView: SwipeView, context: Context) { uiView.move = move }

    final class SwipeView: UIView, UIGestureRecognizerDelegate {
        var move: (Int) -> Void
        private lazy var pan = UIPanGestureRecognizer(target: self, action: #selector(swiped))
        init(move: @escaping (Int) -> Void) {
            self.move = move
            super.init(frame: .zero)
            backgroundColor = .clear
            pan.delegate = self
            addGestureRecognizer(pan)
        }
        required init?(coder: NSCoder) { nil }
        override func didMoveToWindow() {
            super.didMoveToWindow()
            guard window != nil else { return }
            // The hosting controller's navigation parent can be attached after the representable view.
            DispatchQueue.main.async { [weak self] in self?.prioritizePicturePan() }
        }
        private func prioritizePicturePan() {
            var responder: UIResponder? = self
            while let current = responder {
                if let controller = current as? UIViewController, let navigation = controller.navigationController {
                    navigation.interactivePopGestureRecognizer?.require(toFail: pan)
                    if #available(iOS 26.0, *) {
                        navigation.interactiveContentPopGestureRecognizer?.require(toFail: pan)
                    }
                    break
                }
                responder = current.next
            }
        }
        override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            let velocity = pan.velocity(in: self)
            return abs(velocity.x) > abs(velocity.y) * 1.3
        }
        @objc private func swiped() {
            guard pan.state == .ended else { return }
            let distance = pan.translation(in: self)
            guard abs(distance.x) >= 25, abs(distance.x) > abs(distance.y) * 1.3 else { return }
            move(distance.x < 0 ? 1 : -1)
        }
    }
}
