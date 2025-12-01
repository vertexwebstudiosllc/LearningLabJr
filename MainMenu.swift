import SwiftUI

struct LearningLabHomeView: View {
    var body: some View {
        ZStack {
            BackgroundLayer()

            VStack {
                Spacer().frame(height: 20)

                // Logo at top center; replace name with your asset name
                Image("learningLabLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 198, maxHeight: 198) // ~10% smaller
                    .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
                    .offset(y: -8)

                // Kids artwork beneath logo; replace name with your asset name
                Image("learningLabKids")
                    .resizable()
                    .scaledToFit()
                    
                    .frame(maxWidth: 490, maxHeight: 490) // ~20% larger again
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 6)
                    .padding(.top, -170) // nudged slightly down (~2.5-3% shift)

                // Menu row with two buttons side by side (tap area matches image size)
                HStack(spacing: -10) {
                    NavigationLink {
                        ABCsAndPhonicsMenu()
                    } label: {
                        Image("Button-ABCs-Phonics")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 280, maxHeight: 170)
                            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
                            .contentShape(Rectangle())
                    }

                    NavigationLink {
                        ShapesAndColorsMenu()
                    } label: {
                        Image("Button-Shapes-Colors")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 280, maxHeight: 170)
                            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
                            .contentShape(Rectangle())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 10)
                .padding(.top, -230)

                // Second row of buttons
                HStack(spacing: -10) {
                    NavigationLink {
                        CountingMenu()
                    } label: {
                        Image("Button-123s-Counting")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 280, maxHeight: 170)
                            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
                            .contentShape(Rectangle())
                    }

                    NavigationLink {
                        NatureExplorersMenu()
                    } label: {
                        Image("Button-Nature-Explorers")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 280, maxHeight: 170)
                            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
                            .contentShape(Rectangle())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 10)
                .padding(.top, -110) // moved up another ~15%

                // Third row of buttons
                HStack(spacing: -10) {
                    NavigationLink {
                        StoryTimeMenu()
                    } label: {
                        Image("Button-Story-Time")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 196, maxHeight: 120) // ~30% smaller
                            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
                            .contentShape(Rectangle())
                    }

                    NavigationLink {
                        BigFeelingsMenu()
                    } label: {
                        Image("Button-Big-Feelings")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 188, maxHeight: 115) // ~33% smaller
                            .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 6)
                            .contentShape(Rectangle())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 10)
                .padding(.top, -40) // moved up ~40% relative to previous spacing

                // Parents Corner button, small and anchored to the bottom trailing area
                HStack {
                    Spacer()
                    NavigationLink {
                        ParentsCornerMenu()
                    } label: {
                        Image("Button-Parents-Corner")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 60)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.trailing, 24)
                .padding(.top, 12)

                Spacer()
            }
            .ignoresSafeArea(edges: .top)
        }
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
