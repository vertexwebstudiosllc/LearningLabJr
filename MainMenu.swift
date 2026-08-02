import SwiftUI

struct LearningLabHomeView: View {
    private let categories = HomeCategory.allCategories

    var body: some View {
        ZStack {
            BackgroundLayer()

            GeometryReader { geo in
                let horizontalPadding: CGFloat = 20
                let spacing: CGFloat = 12
                let columnCount = min(3, max(2, Int((geo.size.width - horizontalPadding * 2) / 150)))
                let columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 20)

                        Image("learningLabLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 198, maxHeight: 198)
                            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
                            .offset(y: -8)

                        Image("learningLabKids")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 490, maxHeight: 490)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)
                            .padding(.top, -170)

                        LazyVGrid(columns: columns, spacing: spacing) {
                            ForEach(categories) { category in
                                NavigationLink {
                                    category.destination
                                } label: {
                                    HomeCategoryTile(category: category)
                                        .aspectRatio(1, contentMode: .fit)
                                }
                                .buttonStyle(.plain)
                                .accessibilityHint("Opens the \(category.title) games")
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, -145)

                        HStack {
                            Spacer()
                            NavigationLink {
                                ParentsCornerMenu()
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
                            .accessibilityHint("Opens settings and parent information")
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 18)
                        .padding(.bottom, 36)
                    }
                    .frame(minHeight: geo.size.height, alignment: .top)
                }
                .scrollBounceBehavior(.basedOnSize)
                .ignoresSafeArea(edges: .top)
            }
        }
    }
}

private struct HomeCategory: Identifiable {
    enum Kind { case phonics, shapes, counting, nature, stories, feelings }

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
        .init(kind: .counting, title: "123s & Counting", subtitle: "Count, add & compare", icon: "123.rectangle.fill", colors: [.green, .mint]),
        .init(kind: .nature, title: "Nature Explorers", subtitle: "Animals & discovery", icon: "leaf.fill", colors: [.teal, .blue]),
        .init(kind: .stories, title: "Story Time", subtitle: "Read, imagine & learn", icon: "book.fill", colors: [.purple, .indigo]),
        .init(kind: .feelings, title: "Big Feelings", subtitle: "Name, understand & grow", icon: "heart.fill", colors: [.pink, .purple])
    ]
}

private struct HomeCategoryTile: View {
    let category: HomeCategory

    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(LinearGradient(colors: category.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                VStack(spacing: 9) {
                    Image(systemName: category.icon)
                        .font(.system(size: 29, weight: .bold))

                    Text(category.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .lineLimit(2)

                    Text(category.subtitle)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .opacity(0.9)
                        .lineLimit(2)
                }
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(10)
            }
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
            .contentShape(Rectangle())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(category.title). \(category.subtitle)")
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
                Image("learningLabBackground")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: totalHeight)
                    .clipped()
                    .ignoresSafeArea(.all)

                // Fallback to PlayfulBackground if that asset is present
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
