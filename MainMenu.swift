import SwiftUI

struct LearningLabHomeView: View {
    private let categories = HomeCategory.allCategories
    @ObservedObject private var store = StoreManager.shared
    @State private var route: HomeRoute?
    @State private var pendingRoute: HomeRoute?
    @State private var isWaitingForEntitlements = false
    @State private var showPremiumPrompt = false

    var body: some View {
        ZStack {
            BackgroundLayer()
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            GeometryReader { geo in
                if geo.size.width > geo.size.height {
                    landscapeHome(size: geo.size)
                } else {
                    portraitHome(geometry: geo)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { open(nil) }
        .disabled(isWaitingForEntitlements)
        .navigationDestination(item: $route) { destination in
            switch destination {
            case .category(let kind):
                if let category = categories.first(where: { $0.kind == kind }) {
                    category.destination
                }
            case .parents:
                ParentAccessView()
            }
        }
        .sheet(isPresented: $showPremiumPrompt, onDismiss: continueNavigation) {
            PremiumPromptView()
        }
        .onChange(of: store.hasLoadedEntitlements) { _, loaded in
            if loaded && isWaitingForEntitlements { finishInteraction() }
        }
    }

    private func open(_ destination: HomeRoute?) {
        guard route == nil, !showPremiumPrompt, !isWaitingForEntitlements else { return }
        pendingRoute = destination
        if store.hasLoadedEntitlements {
            finishInteraction()
        } else {
            // Preserve the first tap until StoreKit has checked existing access.
            isWaitingForEntitlements = true
        }
    }

    private func finishInteraction() {
        isWaitingForEntitlements = false
        if store.claimLaunchPrompt() {
            showPremiumPrompt = true
        } else {
            continueNavigation()
        }
    }

    private func continueNavigation() {
        route = pendingRoute
        pendingRoute = nil
    }

    private func landscapeHome(size: CGSize) -> some View {
        let width = min(max(0, size.width - 32), 1180)
        let height = max(0, size.height - 24)
        let gap: CGFloat = width >= 1000 ? 28 : 18
        let brandingWidth = min(310, width * 0.27)
        let gridWidth = max(0, width - brandingWidth - gap)
        let rowGap: CGFloat = height < 300 ? 10 : 14
        let tileHeight = min(210, max(44, (height - rowGap) / 2))
        let contentHeight = tileHeight * 2 + rowGap
        let artworkHeight = max(0, contentHeight - 64)
        let kidsHeight = min(brandingWidth * 0.74, artworkHeight * 0.66)
        let logoHeight = min(102, max(0, artworkHeight - kidsHeight))
        let columns = Array(repeating: GridItem(.flexible(), spacing: rowGap), count: 3)

        return HStack(alignment: .center, spacing: gap) {
            VStack(spacing: 8) {
                // These assets include generous empty margins. Frame the complete illustrated subjects.
                Image("learningLabLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: logoHeight / 1.14, height: logoHeight)
                    .clipped()
                    .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
                    .accessibilityHidden(true)

                Image("learningLabKids")
                    .resizable()
                    .scaledToFill()
                    .frame(width: kidsHeight / 0.74, height: kidsHeight)
                    .clipped()
                    .shadow(color: .black.opacity(0.16), radius: 6, y: 3)
                    .accessibilityHidden(true)

                Button {
                    open(.parents)
                } label: {
                    Label("Parents Corner", systemImage: "person.2.badge.gearshape.fill")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(.black.opacity(0.28), in: Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.4), lineWidth: 1.5))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("home.parents")
                .accessibilityHint("Opens settings and parent information")
            }
            .frame(width: brandingWidth)

            LazyVGrid(columns: columns, spacing: rowGap) {
                ForEach(categories) { category in
                    Button {
                        open(.category(category.kind))
                    } label: {
                        LandscapeHomeCategoryTile(category: category, height: tileHeight)
                            .frame(height: tileHeight)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Opens the \(category.title) games")
                }
            }
            .frame(width: gridWidth)
        }
        .frame(width: width, height: contentHeight)
        .frame(width: size.width, height: size.height)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("home.landscape")
    }

    @ViewBuilder
    private func portraitHome(geometry geo: GeometryProxy) -> some View {
        let horizontalPadding: CGFloat = 20
        let spacing: CGFloat = 10
        let columnCount = min(3, max(2, Int((geo.size.width - horizontalPadding * 2) / 150)))
        let compactHeight = geo.size.height < 750
        let rowCount = CGFloat((categories.count + columnCount - 1) / columnCount)
        let widthAvailable = geo.size.width - horizontalPadding * 2 - CGFloat(columnCount - 1) * spacing
        let widthBasedSize = widthAvailable / CGFloat(columnCount)
        let reservedHeight: CGFloat = compactHeight ? 335 : 390
        let heightAvailable = geo.size.height - reservedHeight - (rowCount - 1) * spacing
        let heightBasedSize = heightAvailable / rowCount
        let maximumTileSize: CGFloat = geo.size.width < 500 ? 145 : 160
        let tileSize = max(96, min(widthBasedSize, heightBasedSize, maximumTileSize))
        let logoSize: CGFloat = compactHeight ? 145 : 165
        let kidsSize: CGFloat = compactHeight ? 320 : 380
        let columns = Array(
            repeating: GridItem(.fixed(tileSize), spacing: spacing),
            count: columnCount
        )

        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 20)

                Image("learningLabLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: logoSize, maxHeight: logoSize)
                    .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
                    .offset(y: -8)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)

                Image("learningLabKids")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: kidsSize, maxHeight: kidsSize)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)
                    .padding(.top, compactHeight ? -130 : -145)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)

                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(categories) { category in
                        Button {
                            open(.category(category.kind))
                        } label: {
                            HomeCategoryTile(category: category, compact: compactHeight)
                                .aspectRatio(1, contentMode: .fit)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Opens the \(category.title) games")
                    }
                }
                .frame(maxWidth: CGFloat(columnCount) * tileSize + CGFloat(columnCount - 1) * spacing)
                .padding(.horizontal, horizontalPadding)
                .padding(.top, compactHeight ? -105 : -118)

                HStack {
                    Spacer()
                    Button {
                        open(.parents)
                    } label: {
                        Label("Parents Corner", systemImage: "person.2.badge.gearshape.fill")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 18)
                            .frame(minHeight: 48)
                            .background(.black.opacity(0.28), in: Capsule())
                            .overlay(Capsule().stroke(.white.opacity(0.4), lineWidth: 1.5))
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("home.parents")
                    .accessibilityHint("Opens settings and parent information")
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                .padding(.bottom, 24)
            }
            .frame(minHeight: geo.size.height, alignment: .top)
        }
        .scrollBounceBehavior(.basedOnSize)
        .ignoresSafeArea(edges: .top)
    }

}

private enum HomeRoute: Hashable {
    case category(HomeCategory.Kind)
    case parents
}

private struct HomeCategory: Identifiable {
    enum Kind: Hashable { case phonics, shapes, counting, nature, stories, feelings }

    let kind: Kind
    let title: String
    let subtitle: String
    let icon: String
    let colors: [Color]
    var id: String { title }

    @ViewBuilder var destination: some View {
        switch kind {
        case .phonics: ABCsAndPhonicsMenu()
        case .shapes: ShapesAndColorsMenu()
        case .counting: CountingMenu()
        case .nature: NatureExplorersMenu()
        case .stories: StoryTimeMenu()
        case .feelings: BigFeelingsMenu()
        }
    }

    static let allCategories: [HomeCategory] = [
        .init(kind: .phonics, title: "ABCs & Phonics", subtitle: "Letters, sounds & words", icon: "character.book.closed.fill", colors: [.orange, .pink]),
        .init(kind: .shapes, title: "Shapes & Colors", subtitle: "Match, sort & create", icon: "paintpalette.fill", colors: [.blue, .cyan]),
        .init(kind: .counting, title: "123s & Counting", subtitle: "Count, share & compare", icon: "123.rectangle.fill", colors: [.green, .mint]),
        .init(kind: .nature, title: "Nature Explorers", subtitle: "Animals & discovery", icon: "leaf.fill", colors: [.teal, .blue]),
        .init(kind: .stories, title: "Story Time", subtitle: "Read, imagine & learn", icon: "book.fill", colors: [.purple, .indigo]),
        .init(kind: .feelings, title: "Big Feelings", subtitle: "Name, understand & grow", icon: "heart.fill", colors: [.pink, .purple])
    ]
}

private struct HomeCategoryTile: View {
    let category: HomeCategory
    let compact: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(LinearGradient(colors: category.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                VStack(spacing: compact ? 6 : 9) {
                    Image(systemName: category.icon)
                        .font(.system(size: compact ? 23 : 29, weight: .bold))

                    Text(category.title)
                        .font(.system(size: compact ? 14 : 16, weight: .bold, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)

                    Text(category.subtitle)
                        .font(.system(size: compact ? 9 : 11, weight: .semibold, design: .rounded))
                        .opacity(0.9)
                        .lineLimit(compact ? 1 : 2)
                        .minimumScaleFactor(0.7)
                }
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(compact ? 7 : 10)
            }
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
            .contentShape(Rectangle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(category.title). \(category.subtitle)")
            .accessibilityIdentifier("category.\(category.title)")
    }
}

/// Rectangular cards fill both landscape rows without pushing any category below the screen.
private struct LandscapeHomeCategoryTile: View {
    let category: HomeCategory
    let height: CGFloat

    private var tight: Bool { height < 125 }
    private var large: Bool { height >= 180 }

    var body: some View {
        RoundedRectangle(cornerRadius: tight ? 16 : 20, style: .continuous)
            .fill(LinearGradient(colors: category.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                VStack(spacing: tight ? 4 : 6) {
                    Image(systemName: category.icon)
                        .font(.system(size: tight ? 20 : (large ? 36 : 28), weight: .bold))
                    Text(category.title)
                        .font(.system(size: tight ? 13 : (large ? 18 : 15), weight: .bold, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                    Text(category.subtitle)
                        .font(.system(size: tight ? 10 : (large ? 13 : 11), weight: .semibold, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                        .opacity(0.95)
                }
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(tight ? 8 : 12)
            }
            .shadow(color: .black.opacity(0.18), radius: 6, y: 4)
            .contentShape(RoundedRectangle(cornerRadius: tight ? 16 : 20))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(category.title). \(category.subtitle)")
            .accessibilityIdentifier("category.\(category.title)")
    }
}

private struct BackgroundLayer: View {
    var body: some View {
        GeometryReader { proxy in
            let totalHeight = proxy.size.height + proxy.safeAreaInsets.top + proxy.safeAreaInsets.bottom

            ZStack(alignment: .center) {
                // Base color so we never see white even if assets fail to load
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.78, blue: 0.42),
                        Color(red: 1.0, green: 0.68, blue: 0.35)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(.all)

                // Preferred background art, full bleed without offsets
                // The bundled artwork is named PlayfulBackground.
                Image("PlayfulBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: totalHeight)
                    .clipped()
                    .ignoresSafeArea(.all)
            }
        }
    }
}

// MARK: - Buttons

struct MenuButton<Icon: View>: View {
    let title: String
    let subtitle: String?
    let background: Color
    var cornerRadius: CGFloat = 28
    var verticalPadding: CGFloat = 16
    var iconSize: CGFloat = 24
    let icon: () -> Icon

    var body: some View {
        HStack(spacing: 14) {
            icon()
                .font(.system(size: iconSize, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, verticalPadding)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(background)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
    }
}

struct CircleIconButton: View {
    let background: Color
    let icon: String
    var size: CGFloat = 78
    var iconSize: CGFloat = 24

    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .bold))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(Circle().fill(background))
                .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
        }
    }
}

struct HeartButton<Icon: View>: View {
    let title: String
    let background: Color
    var width: CGFloat = 130
    var iconSize: CGFloat = 20
    let icon: () -> Icon

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 10) {
                icon()
                    .font(.system(size: iconSize, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: width)
            .background(
                HeartShape()
                    .fill(background)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
        }
    }
}

struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        path.move(to: CGPoint(x: width / 2, y: height))
        path.addCurve(
            to: CGPoint(x: 0, y: height / 4),
            control1: CGPoint(x: width / 2, y: height * 0.75),
            control2: CGPoint(x: 0, y: height / 2)
        )
        path.addArc(
            center: CGPoint(x: width / 4, y: height / 4),
            radius: width / 4,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: width * 3 / 4, y: height / 4),
            radius: width / 4,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addCurve(
            to: CGPoint(x: width / 2, y: height),
            control1: CGPoint(x: width, y: height / 2),
            control2: CGPoint(x: width / 2, y: height * 0.75)
        )
        return path
    }
}

// MARK: - Colors

extension Color {
    static let llBlue = Color(red: 0.20, green: 0.60, blue: 0.95)
    static let llYellow = Color(red: 1.00, green: 0.85, blue: 0.40)
    static let llPink = Color(red: 1.00, green: 0.55, blue: 0.70)
    static let llHeart = Color(red: 1.00, green: 0.60, blue: 0.65)
    static let llPurple = Color(red: 0.70, green: 0.50, blue: 1.00)
    static let llGreen = Color(red: 0.45, green: 0.80, blue: 0.45)
    static let llParents = Color(red: 0.15, green: 0.55, blue: 0.95)
}

// MARK: - Preview

#Preview {
    LearningLabHomeView()
}
