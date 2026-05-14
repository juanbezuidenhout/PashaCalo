import SwiftUI

struct OnboardingGraphView: View {
    let onNext: () -> Void

    private var pashaCaloColor: Color { Color("AccentBlack") }
    private let noTrackingColor = Color(red: 0.95, green: 0.36, blue: 0.38)
    private let cardTint = Color(red: 0.95, green: 0.95, blue: 0.96)
    private let dashedColor = Color(red: 0.78, green: 0.78, blue: 0.80)
    private let labelGray = Color(red: 0.30, green: 0.30, blue: 0.32)

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("続けるほど、変化が見えてくる")
                .font(.custom("NotoSansJP-Bold", size: 26))
                .foregroundStyle(Color("TextPrimary"))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 28)

            chartCard

            Text("食習慣を記録して、長期的な変化を実感しましょう")
                .font(.custom("NotoSansJP-Regular", size: 14))
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Spacer()

            PrimaryButton(title: "次へ") {
                onNext()
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("体重")
                .font(.custom("NotoSansJP-Bold", size: 22))
                .foregroundStyle(Color("TextPrimary"))
                .padding(.leading, 2)
                .padding(.top, 4)

            CalAIStyleChart(
                pashaCaloColor: pashaCaloColor,
                noTrackingColor: noTrackingColor,
                cardColor: cardTint,
                dashedColor: dashedColor,
                labelGray: labelGray,
                textPrimary: Color("TextPrimary")
            )
            .frame(height: 220)

            HStack {
                Text("1ヶ月目")
                Spacer()
                Text("6ヶ月目")
            }
            .font(.custom("NotoSansJP-Regular", size: 14))
            .foregroundStyle(labelGray)
            .padding(.horizontal, 2)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(cardTint)
        )
    }
}

// MARK: - Cal AI-style chart

private struct CalAIStyleChart: View {
    let pashaCaloColor: Color
    let noTrackingColor: Color
    let cardColor: Color
    let dashedColor: Color
    let labelGray: Color
    let textPrimary: Color

    // Normalized coordinates (0...1, y goes top→bottom).
    private let startPoint = CGPoint(x: 0.04, y: 0.18)
    private let endBlack = CGPoint(x: 0.96, y: 0.88)
    private let endPink = CGPoint(x: 0.98, y: 0.04)

    // The two dashed reference lines.
    private let topDashedY: CGFloat = 0.18
    private let midDashedY: CGFloat = 0.62

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let topY = topDashedY * size.height
            let midY = midDashedY * size.height

            ZStack(alignment: .topLeading) {
                pinkAreaFill(in: size)

                dashedLine(width: size.width, y: topY)
                dashedLine(width: size.width, y: midY)

                pinkLinePath(in: size)
                    .stroke(
                        noTrackingColor,
                        style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round)
                    )

                blackLinePath(in: size)
                    .stroke(
                        textPrimary,
                        style: StrokeStyle(lineWidth: 3.2, lineCap: .round, lineJoin: .round)
                    )

                endpointDot
                    .position(point(startPoint.x, startPoint.y, in: size))

                endpointDot
                    .position(point(endBlack.x, endBlack.y, in: size))

                brandRow
                    .position(x: 0.18 * size.width + 4, y: midY)

                Text("記録なし")
                    .font(.custom("NotoSansJP-Bold", size: 14))
                    .foregroundStyle(labelGray)
                    .position(x: 0.75 * size.width, y: 0.22 * size.height)
            }
        }
    }

    private func point(_ x: CGFloat, _ y: CGFloat, in size: CGSize) -> CGPoint {
        CGPoint(x: x * size.width, y: y * size.height)
    }

    // MARK: Paths

    private func blackLinePath(in size: CGSize) -> Path {
        Path { path in
            path.move(to: point(startPoint.x, startPoint.y, in: size))
            // Stay nearly flat at the top, then curve down with an S
            path.addCurve(
                to: point(0.50, 0.52, in: size),
                control1: point(0.22, 0.18, in: size),
                control2: point(0.32, 0.30, in: size)
            )
            path.addCurve(
                to: point(endBlack.x, endBlack.y, in: size),
                control1: point(0.70, 0.74, in: size),
                control2: point(0.84, 0.88, in: size)
            )
        }
    }

    private func pinkLinePath(in size: CGSize) -> Path {
        Path { path in
            path.move(to: point(startPoint.x, startPoint.y, in: size))
            // Dip down deeper, stay low briefly, then sweep up sharply
            path.addCurve(
                to: point(0.38, 0.66, in: size),
                control1: point(0.14, 0.32, in: size),
                control2: point(0.24, 0.70, in: size)
            )
            path.addCurve(
                to: point(endPink.x, endPink.y, in: size),
                control1: point(0.58, 0.62, in: size),
                control2: point(0.74, 0.10, in: size)
            )
        }
    }

    private func pinkAreaFill(in size: CGSize) -> some View {
        // Fill from the pink line down, then mask to show only the portion
        // above the TOP dashed line (the rebound zone), like Cal AI.
        Path { path in
            path.move(to: point(startPoint.x, startPoint.y, in: size))
            path.addCurve(
                to: point(0.38, 0.66, in: size),
                control1: point(0.14, 0.32, in: size),
                control2: point(0.24, 0.70, in: size)
            )
            path.addCurve(
                to: point(endPink.x, endPink.y, in: size),
                control1: point(0.58, 0.62, in: size),
                control2: point(0.74, 0.10, in: size)
            )
            path.addLine(to: point(endPink.x, 1.0, in: size))
            path.addLine(to: point(startPoint.x, 1.0, in: size))
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                stops: [
                    .init(color: noTrackingColor.opacity(0.0), location: 0.0),
                    .init(color: noTrackingColor.opacity(0.04), location: 0.55),
                    .init(color: noTrackingColor.opacity(0.28), location: 1.0)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .mask(
            Rectangle()
                .frame(width: size.width, height: topDashedY * size.height)
                .frame(width: size.width, height: size.height, alignment: .top)
        )
    }

    private func dashedLine(width: CGFloat, y: CGFloat) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: width, y: y))
        }
        .stroke(
            dashedColor,
            style: StrokeStyle(lineWidth: 1, dash: [3, 4])
        )
    }

    // MARK: Components

    private var endpointDot: some View {
        Circle()
            .fill(cardColor)
            .frame(width: 14, height: 14)
            .overlay(
                Circle()
                    .stroke(textPrimary, lineWidth: 2.2)
            )
    }

    private var brandRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "camera.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(textPrimary)

            Text("パシャカロ")
                .font(.custom("NotoSansJP-Bold", size: 13))
                .foregroundStyle(textPrimary)

            Text("体重")
                .font(.custom("NotoSansJP-Bold", size: 12))
                .foregroundStyle(.white)
                .padding(.horizontal, 9)
                .padding(.vertical, 3)
                .background(
                    Capsule(style: .continuous)
                        .fill(textPrimary)
                )
        }
        .fixedSize()
    }
}

#Preview {
    OnboardingGraphView(onNext: {})
        .background(Color("AppBackground"))
}
