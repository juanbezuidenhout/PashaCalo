import SwiftUI

/// "A simpler way to stay on track" comparison screen, shown after the
/// pace picker (and only when the user has chosen to lose or gain — see
/// `OnboardingFlowView.advance()` for the routing). The screen is built
/// around a single hero illustration: two rounded "bars" that animate
/// upward from the bottom on appear, contrasting *without* the app
/// (a short bar) against *with* the app (a tall, accented bar that
/// keeps gently breathing once it settles).
///
/// The choreography is intentionally tuned to feel premium / native:
///
///   1. The whole illustration card softly fades + slides up.
///   2. The two bars start collapsed against the floor.
///   3. The "without" bar grows first to a modest height (ease-out).
///   4. ~120ms later the "with" bar launches upward on a spring with a
///      slight overshoot, settling at a much taller height — this is
///      the moment the comparison "reads".
///   5. A medium-weight haptic punctuates that overshoot.
///   6. Each bar's label (top) and icon (bottom) fade in once their
///      bar has reached its peak, so text never appears hovering in
///      mid-air during growth.
///   7. The bottom caption + CTA fade in last.
///   8. Once everything is settled, the "with" bar enters a subtle
///      sinusoidal-feel breathing loop (≈1.8% of its height) so the
///      eye keeps being drawn to it without ever feeling busy.
struct OnboardingSimplerWayView: View {
    let onNext: () -> Void

    @State private var hasAppeared = false
    @State private var didFireOvertakeHaptic = false
    @State private var captionVisible = false

    private let accent = Color(red: 0.93, green: 0.55, blue: 0.18)
    private let cardSurface = Color(red: 0.96, green: 0.96, blue: 0.94)
    private let withoutCardFill = Color.white
    private let withCardFill = Color(red: 0.10, green: 0.10, blue: 0.10)
    private let withoutBadgeFill = Color(red: 0.91, green: 0.91, blue: 0.89)
    private let inactiveLabel = Color(red: 0.45, green: 0.45, blue: 0.45)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 24)
                .padding(.top, 28)

            Spacer(minLength: 24)

            illustration
                .padding(.horizontal, 24)

            Spacer(minLength: 0)

            PrimaryButton(title: "次へ") {
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .opacity(captionVisible ? 1 : 0)
            .offset(y: captionVisible ? 0 : 12)
            .animation(.easeOut(duration: 0.45).delay(1.05), value: captionVisible)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear { startChoreography() }
    }

    // MARK: - Header copy

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("毎日を、もっとシンプルに")
                .font(.custom("NotoSansJP-Bold", size: 28))
                .foregroundStyle(Color("TextPrimary"))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            Text("食事の記録から計画の継続まで、パシャカロがあなたの毎日をサポートします。")
                .font(.custom("NotoSansJP-Regular", size: 15))
                .foregroundStyle(Color("TextSecondary"))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Illustration card

    private var illustration: some View {
        VStack(spacing: 18) {
            barsRow

            captionRow
                .opacity(captionVisible ? 1 : 0)
                .offset(y: captionVisible ? 0 : 6)
                .animation(.easeOut(duration: 0.45).delay(0.95), value: captionVisible)
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            cardSurface,
                            cardSurface.opacity(0.55)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                )
        )
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 18)
        .animation(.easeOut(duration: 0.55), value: hasAppeared)
    }

    // MARK: - Bars

    /// A fixed-height plot area so both bars share the same baseline.
    /// The "with" bar is intentionally given ~70% more vertical space
    /// than the "without" bar so the comparison reads instantly.
    private var barsRow: some View {
        GeometryReader { geo in
            let plotHeight = geo.size.height
            let columnWidth = (geo.size.width - 16) / 2

            HStack(alignment: .bottom, spacing: 16) {
                ComparisonBar(
                    title: "パシャカロなし",
                    iconName: "person.fill",
                    targetHeight: plotHeight * 0.55,
                    width: columnWidth,
                    fill: withoutCardFill,
                    titleColor: inactiveLabel,
                    iconForeground: Color(white: 0.42),
                    iconBackground: withoutBadgeFill,
                    showBadgeBackground: true,
                    showShadow: false,
                    breathing: false,
                    appear: hasAppeared,
                    appearDelay: 0.10,
                    appearDuration: 0.55,
                    overshoot: false
                )

                ComparisonBar(
                    title: "パシャカロあり",
                    iconName: "checkmark.seal.fill",
                    targetHeight: plotHeight * 0.95,
                    width: columnWidth,
                    fill: withCardFill,
                    titleColor: .white,
                    iconForeground: .white,
                    iconBackground: .clear,
                    showBadgeBackground: false,
                    showShadow: true,
                    breathing: hasAppeared,
                    appear: hasAppeared,
                    appearDelay: 0.32,
                    appearDuration: 0.78,
                    overshoot: true
                )
            }
            .frame(width: geo.size.width, height: plotHeight, alignment: .bottom)
        }
        .frame(height: 240)
    }

    private var captionRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(accent)
            Text("毎日の小さな積み重ねが、変化につながります")
                .font(.custom("NotoSansJP-SemiBold", size: 13))
                .foregroundStyle(Color("TextPrimary"))
        }
    }

    // MARK: - Choreography

    private func startChoreography() {
        guard !hasAppeared else { return }
        hasAppeared = true

        // Time the haptic to land on the visual peak of the "with" bar's
        // overshoot. Spring response 0.78s w/ 0.32s entrance delay puts
        // the apex roughly at delay + response * 0.55.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            guard !didFireOvertakeHaptic else { return }
            didFireOvertakeHaptic = true
            Haptics.impact(.medium, intensity: 0.7)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.10) {
            captionVisible = true
        }
    }
}

// MARK: - Comparison bar

/// A single rounded bar that grows upward from the bottom on appear.
/// Title (top) and icon (bottom) live inside the bar and only fade in
/// once the bar has reached its peak height, so nothing ever appears
/// hovering in mid-air mid-growth. The "with" variant additionally
/// enters a slow 0↔1 breathing loop after settling.
private struct ComparisonBar: View {
    let title: String
    let iconName: String
    let targetHeight: CGFloat
    let width: CGFloat
    let fill: Color
    let titleColor: Color
    let iconForeground: Color
    let iconBackground: Color
    let showBadgeBackground: Bool
    let showShadow: Bool
    let breathing: Bool
    let appear: Bool
    let appearDelay: Double
    let appearDuration: Double
    /// When true, uses an underdamped spring with a visible overshoot.
    /// When false, a perfectly clean ease-out (no bounce).
    let overshoot: Bool

    @State private var grown: Bool = false
    @State private var contentVisible: Bool = false
    @State private var breathing01: CGFloat = 0

    var body: some View {
        // `grown` controls the entrance growth (0 → targetHeight).
        // `breathing01` is a slow 0↔1 oscillator (autoreverses) that
        // adds ±1.8% of `targetHeight` once the bar has settled — a
        // barely-perceptible "in and out" breath.
        let baseHeight = grown ? targetHeight : 0
        let breathOffset: CGFloat = breathing && grown
            ? (breathing01 - 0.5) * 2 * (targetHeight * 0.018)
            : 0
        let animatedHeight = max(0, baseHeight + breathOffset)

        return ZStack(alignment: .bottom) {
            // Reserves the full final height so the row layout is
            // stable from frame 1.
            Color.clear
                .frame(width: width, height: targetHeight)

            // The bar fill grows from the floor.
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(fill)
                .frame(width: width, height: animatedHeight)
                .shadow(
                    color: showShadow ? Color.black.opacity(0.22) : .clear,
                    radius: 22, x: 0, y: 12
                )

            // Title + icon overlay. Sized to the FULL target height so
            // the title sits at the *intended* top of the bar (not the
            // top of the partially-grown bar). Hidden until the bar
            // has reached its peak.
            VStack(spacing: 0) {
                Text(title)
                    .font(.custom("NotoSansJP-Bold", size: 14))
                    .foregroundStyle(titleColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 22)

                Spacer(minLength: 0)

                iconBadge
                    .padding(.bottom, 16)
            }
            .frame(width: width, height: targetHeight)
            .opacity(contentVisible ? 1 : 0)
            .scaleEffect(contentVisible ? 1 : 0.92, anchor: .center)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.8),
                value: contentVisible
            )
        }
        .frame(width: width, height: targetHeight, alignment: .bottom)
        .onChange(of: appear) { newValue in
            guard newValue else { return }
            launch()
        }
        .onAppear {
            if appear { launch() }
        }
    }

    @ViewBuilder
    private var iconBadge: some View {
        if showBadgeBackground {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconBackground)
                    .frame(width: 56, height: 44)
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconForeground)
            }
        } else {
            Image(systemName: iconName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(iconForeground)
                .frame(width: 56, height: 44)
        }
    }

    private func launch() {
        let response = appearDuration
        let damping: Double = overshoot ? 0.62 : 0.92
        let timing = Animation.spring(response: response, dampingFraction: damping)

        DispatchQueue.main.asyncAfter(deadline: .now() + appearDelay) {
            withAnimation(timing) {
                grown = true
            }
            // Reveal content slightly past the bar's apex so labels
            // never look like they're "swimming up" through the bar.
            withAnimation(.easeOut(duration: 0.35).delay(response * 0.6)) {
                contentVisible = true
            }
            if breathing {
                startBreathing(after: response + 0.15)
            }
        }
    }

    private func startBreathing(after delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(
                .easeInOut(duration: 3.4).repeatForever(autoreverses: true)
            ) {
                breathing01 = 1
            }
        }
    }
}

#Preview {
    OnboardingSimplerWayView(onNext: {})
        .background(Color("AppBackground"))
}
