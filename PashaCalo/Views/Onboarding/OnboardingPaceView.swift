import SwiftUI
import UIKit

/// Lets the user pick how aggressively they want to progress toward their
/// goal weight. The pace value (kg / week) is bound to a custom slider with
/// three discrete zones — slow / recommended / fast — visualised by three
/// SF Symbol animals that animate continuously at their own characteristic
/// rhythm. The active zone's animal is highlighted with the accent colour
/// and a subtle scale-up.
///
/// Below the slider sits a live result card that recomputes the projected
/// goal date and the daily calorie target as the user drags.
struct OnboardingPaceView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    /// 0.0 (slow end) … 1.0 (fast end). Default lands inside the
    /// "recommended" middle zone.
    @State private var fraction: Double = 0.5
    @State private var lastZone: Int = 1

    private let paceRange: ClosedRange<Double> = 0.1...1.0
    private let accent = Color(red: 0.93, green: 0.55, blue: 0.18)
    private let cardBackground = Color(red: 0.96, green: 0.96, blue: 0.94)
    private let inactiveColor = Color(red: 0.78, green: 0.78, blue: 0.78)
    private let feedback = UISelectionFeedbackGenerator()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("目標達成までのペースを\n選んでください")
                .font(.custom("NotoSansJP-Bold", size: 26))
                .foregroundStyle(Color("TextPrimary"))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
                .padding(.top, 28)

            Spacer(minLength: 0)

            VStack(spacing: 6) {
                Text(subtitleText)
                    .font(.custom("NotoSansJP-Regular", size: 15))
                    .foregroundStyle(Color("TextSecondary"))

                Text(formattedPace)
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(Color("TextPrimary"))
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 14)

            animalsRow
                .frame(height: 88)
                .padding(.horizontal, 32)

            slider
                .frame(height: 32)
                .padding(.horizontal, 28)
                .padding(.top, 4)

            Spacer(minLength: 16)

            resultCard
                .padding(.horizontal, 24)

            Spacer(minLength: 0)

            PrimaryButton(title: "次へ") {
                commit()
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .animation(.easeInOut(duration: 0.18), value: zoneIndex)
        .onAppear { feedback.prepare() }
    }

    // MARK: - Animals row

    private var animalsRow: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { context in
            let time = context.date.timeIntervalSince1970
            HStack(spacing: 0) {
                animalCell(.slow, time: time).frame(maxWidth: .infinity)
                animalCell(.recommended, time: time).frame(maxWidth: .infinity)
                animalCell(.fast, time: time).frame(maxWidth: .infinity)
            }
        }
    }

    private func animalCell(_ zone: PaceZone, time: TimeInterval) -> some View {
        let isActive = zone.rawValue == zoneIndex
        let motion = isActive ? zone.motion(at: time) : AnimalMotion.idle
        let activeScale: CGFloat = isActive ? 1.16 : 0.92

        return VStack(spacing: 8) {
            ZStack {
                // Ground shadow — tightens & fades while the animal is in
                // the air, which sells the height of the hop / gallop.
                Ellipse()
                    .fill(Color.black.opacity(0.18))
                    .frame(width: 26 * motion.shadowScale, height: 5 * motion.shadowScale)
                    .blur(radius: 2 + (1 - motion.shadowScale) * 2)
                    .offset(y: 20)
                    .animation(.linear(duration: 0), value: motion.shadowScale)

                Image(systemName: zone.iconName)
                    .font(.system(size: 30, weight: .regular))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(isActive ? accent : inactiveColor)
                    .scaleEffect(
                        x: activeScale * motion.scaleX,
                        y: activeScale * motion.scaleY,
                        anchor: .bottom
                    )
                    .rotationEffect(.degrees(motion.rotation), anchor: .bottom)
                    .offset(x: motion.offsetX, y: motion.offsetY)
            }
            .frame(height: 44)
            .animation(.spring(response: 0.42, dampingFraction: 0.72), value: isActive)

            Text(zone.label)
                .font(.custom("NotoSansJP-SemiBold", size: 13))
                .foregroundStyle(isActive ? accent : Color("TextSecondary"))
                .animation(.easeInOut(duration: 0.2), value: isActive)
        }
    }

    // MARK: - Slider

    private var slider: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let thumbDiameter: CGFloat = 26
            let trackHeight: CGFloat = 6
            let thumbX = max(thumbDiameter / 2, min(width - thumbDiameter / 2, width * CGFloat(fraction)))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(white: 0.88))
                    .frame(height: trackHeight)

                Capsule()
                    .fill(Color("TextPrimary"))
                    .frame(width: thumbX, height: trackHeight)

                Circle()
                    .fill(Color.white)
                    .frame(width: thumbDiameter, height: thumbDiameter)
                    .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 2)
                    .overlay(
                        Circle().stroke(Color(white: 0.92), lineWidth: 0.5)
                    )
                    .offset(x: thumbX - thumbDiameter / 2)
            }
            .frame(height: 32)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        updateFraction(from: value.location.x, width: width)
                    }
            )
        }
    }

    private func updateFraction(from rawX: CGFloat, width: CGFloat) {
        guard width > 0 else { return }
        let clamped = max(0, min(1, Double(rawX / width)))
        fraction = clamped
        let zone = zoneIndex
        if zone != lastZone {
            feedback.selectionChanged()
            feedback.prepare()
            lastZone = zone
        }
    }

    // MARK: - Result card

    private var resultCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            resultHeadline
                .font(.custom("NotoSansJP-Bold", size: 16))
                .foregroundStyle(Color("TextPrimary"))
                .fixedSize(horizontal: false, vertical: true)

            Text(zone.detailCopy)
                .font(.custom("NotoSansJP-Regular", size: 13))
                .foregroundStyle(Color("TextSecondary"))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)

            Text("1日のカロリー目標: \(formattedCalories) kcal")
                .font(.custom("NotoSansJP-SemiBold", size: 13))
                .foregroundStyle(Color("TextPrimary"))
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(cardBackground)
        )
    }

    private var resultHeadline: Text {
        let duration = formattedDuration
        let full = "目標達成まで \(duration)"
        var attributed = AttributedString(full)
        if let range = attributed.range(of: duration) {
            attributed[range].foregroundColor = accent
        }
        return Text(attributed)
    }

    // MARK: - Derived values

    private var zoneIndex: Int {
        if fraction < 1.0 / 3.0 { return 0 }
        if fraction < 2.0 / 3.0 { return 1 }
        return 2
    }

    private var zone: PaceZone { PaceZone(rawValue: zoneIndex) ?? .recommended }

    /// Continuous kg/week pace driven by the slider.
    private var paceKgPerWeek: Double {
        let span = paceRange.upperBound - paceRange.lowerBound
        return paceRange.lowerBound + fraction * span
    }

    private var formattedPace: String {
        String(format: "%.1f kg", paceKgPerWeek)
    }

    private var deltaKg: Double {
        max(abs(data.goalWeightKg - data.weightKg), 0.5)
    }

    private var subtitleText: String {
        switch data.goalDirection {
        case OnboardingData.GoalDirection.lose: return "週あたりの減量ペース"
        case OnboardingData.GoalDirection.gain: return "週あたりの増量ペース"
        default: return "目標達成までのペース"
        }
    }

    private var formattedDuration: String {
        let weeks = deltaKg / paceKgPerWeek
        if weeks < 6 {
            let rounded = max(1, Int(weeks.rounded()))
            return "約\(rounded)週間"
        }
        let months = max(1, Int((weeks / 4.345).rounded()))
        return "約\(months)ヶ月"
    }

    private var formattedCalories: String {
        let value = dailyCalorieTarget
        return numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private var dailyCalorieTarget: Int {
        let tdee = baseTDEE
        let weeklyKg = paceKgPerWeek * directionSign
        let dailyAdjust = (weeklyKg * 7700.0) / 7.0
        let raw = tdee + dailyAdjust
        let rounded = (raw / 10).rounded() * 10
        return max(1100, Int(rounded))
    }

    /// Signed direction for the calorie delta: gain adds, lose subtracts,
    /// maintain (defensive — shouldn't reach this view) leaves it untouched.
    private var directionSign: Double {
        switch data.goalDirection {
        case OnboardingData.GoalDirection.gain: return 1
        case OnboardingData.GoalDirection.lose: return -1
        default: return 0
        }
    }

    /// Mifflin-St Jeor BMR × activity factor.
    private var baseTDEE: Double {
        let age = currentAge
        let weight = data.weightKg > 0 ? data.weightKg : 70
        let height = data.heightCm > 0 ? data.heightCm : 170
        let base = 10 * weight + 6.25 * height - 5 * Double(age)
        let sexAdjust: Double
        switch data.sex {
        case "男性": sexAdjust = 5
        case "女性": sexAdjust = -161
        default: sexAdjust = -78
        }
        let bmr = base + sexAdjust
        return bmr * activityFactor
    }

    private var activityFactor: Double {
        switch data.activityLevel {
        case "週0〜2回　たまに運動する": return 1.375
        case "週3〜5回　定期的に運動する": return 1.55
        case "週6回以上　本格的に鍛えている": return 1.725
        default: return 1.55
        }
    }

    private var currentAge: Int {
        let comps = Calendar.current.dateComponents([.year], from: data.dateOfBirth, to: Date())
        return comps.year ?? 25
    }

    private var numberFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        return f
    }

    private func commit() {
        // No corresponding field on OnboardingData yet; intentionally a no-op
        // for now so the wheel value isn't lost between screens.
    }

    // MARK: - Animal motion

    /// One frame of per-animal motion state. All transforms compose on top
    /// of a baseline pose, so an "idle" instance is a no-op.
    fileprivate struct AnimalMotion {
        var offsetX: CGFloat
        var offsetY: CGFloat
        var rotation: Double
        var scaleX: CGFloat
        var scaleY: CGFloat
        /// 1.0 = full ground contact shadow, 0 = hovering high in the air.
        var shadowScale: CGFloat

        static let idle = AnimalMotion(
            offsetX: 0, offsetY: 0, rotation: 0,
            scaleX: 1, scaleY: 1, shadowScale: 1
        )
    }

    // MARK: - Pace zone

    fileprivate enum PaceZone: Int {
        case slow = 0
        case recommended = 1
        case fast = 2

        var iconName: String {
            switch self {
            case .slow: return "tortoise.fill"
            case .recommended: return "hare.fill"
            case .fast: return "cat.fill"
            }
        }

        var label: String {
            switch self {
            case .slow: return "ゆっくり"
            case .recommended: return "おすすめ"
            case .fast: return "速い"
            }
        }

        var detailCopy: String {
            switch self {
            case .slow:
                return "生活への負担が少なく、無理なく続けやすいペースです。"
            case .recommended:
                return "バランスの取れたペースで、多くの方におすすめです。"
            case .fast:
                return "短期間で結果を目指す方向け。負担が大きくなる場合があります。"
            }
        }

        /// Period of one full gait cycle, in seconds — i.e. how long a
        /// real animal of this kind takes to perform one full set of leg
        /// movements. Tuned to feel natural at the icon's display size.
        var cycleSeconds: Double {
            switch self {
            case .slow: return 2.5
            case .recommended: return 0.9
            case .fast: return 0.6
            }
        }

        /// Computes a frame of body-motion at absolute wall-clock `time`,
        /// shaped by a per-animal gait model. We can't animate the SF
        /// Symbol's internal limbs, so the whole-body motion has to *imply*
        /// the legs working — discrete impact beats, asymmetric profiles,
        /// proper gather/launch/suspension phases, etc.
        func motion(at time: TimeInterval) -> AnimalMotion {
            let cycle = cycleSeconds
            let phase = (time.truncatingRemainder(dividingBy: cycle)) / cycle  // 0..1
            let tau = 2 * Double.pi

            switch self {
            case .slow:
                // Tortoise — 4-beat lateral-sequence walk. Each leg lands
                // in turn, so the body drops four small times per cycle.
                // The roll comes from weight shifting onto the diagonal
                // pairs, and the head visibly bobs forward with each step.
                let stepDrops = abs(sin(phase * tau * 2))    // 4 micro-drops per cycle
                let bodyRoll = sin(phase * tau)              // 1 full sway per cycle
                let headBob = sin(phase * tau * 4 - .pi / 2) // 4 head pulses
                let creep = sin(phase * tau * 2 + .pi / 4)   // gentle forward nudge per pair

                return AnimalMotion(
                    offsetX: CGFloat(creep * 1.4),
                    offsetY: CGFloat(-stepDrops * 1.6),
                    rotation: bodyRoll * 2.4 + headBob * 0.4,
                    scaleX: 1.0,
                    scaleY: 1.0 - CGFloat(stepDrops) * 0.018,
                    shadowScale: 1.0
                )

            case .recommended:
                // Hare — a real lagomorph hop cycle. The phases below match
                // what an actual rabbit does:
                //   0.00–0.05  landing crouch (front paws absorbing impact)
                //   0.05–0.35  hind-leg thrust → body lengthens, lifts
                //   0.35–0.55  apex airtime, slight forward tilt
                //   0.55–0.85  descent, body recompresses
                //   0.85–1.00  pre-launch tuck (hind legs gather forward)
                let arc = max(0, sin(phase * .pi))           // airtime bell
                let landing = phase < 0.05 ? (1 - phase / 0.05) : 0
                let preLaunch = phase > 0.85 ? (phase - 0.85) / 0.15 : 0
                let crouch = max(landing, preLaunch)         // 0..1
                let extend = phase >= 0.05 && phase < 0.35
                    ? sin((phase - 0.05) / 0.30 * .pi)
                    : 0

                return AnimalMotion(
                    offsetX: 0,
                    offsetY: CGFloat(-arc * 16 + crouch * 1.4),
                    rotation: -arc * 9,                      // nose tips forward at apex
                    scaleX: 1.0 + CGFloat(crouch) * 0.10 - CGFloat(extend) * 0.05,
                    scaleY: 1.0 - CGFloat(crouch) * 0.14 + CGFloat(extend) * 0.12,
                    shadowScale: CGFloat(1.0 - arc * 0.70)
                )

            case .fast:
                // Cat — rotary gallop with four distinct beats and an
                // airborne suspension phase. Modelled as:
                //   0.00–0.08  lead forepaw impact (small body dip + tilt)
                //   0.08–0.20  trailing forepaw lands, back arches up
                //                (gather: spine compresses, body shortens)
                //   0.20–0.34  lead hindpaw lands → push-off
                //   0.34–0.95  airborne suspension (body elongates, low arc)
                //   0.95–1.00  setup for next forepaw strike
                let frontImpact = phase < 0.08
                    ? sin(phase / 0.08 * .pi)
                    : 0
                let gather = phase >= 0.08 && phase < 0.20
                    ? sin((phase - 0.08) / 0.12 * .pi)
                    : 0
                let hindImpact = phase >= 0.20 && phase < 0.34
                    ? sin((phase - 0.20) / 0.14 * .pi)
                    : 0
                let airborne = phase >= 0.34 && phase < 0.95
                    ? sin((phase - 0.34) / 0.61 * .pi)
                    : 0

                // The two impacts add tiny ground "punches"; the suspension
                // is the big stretchy arc; the gather is the spine arch
                // between impacts.
                let impactPunch = frontImpact + hindImpact

                return AnimalMotion(
                    offsetX: CGFloat(airborne * 4.5 - gather * 0.6),
                    offsetY: CGFloat(-airborne * 7 + impactPunch * 1.4 - gather * 1.6),
                    rotation: -airborne * 6 + gather * 4 + frontImpact * 2,
                    scaleX: 1.0 + CGFloat(airborne) * 0.16 - CGFloat(gather) * 0.06,
                    scaleY: 1.0 - CGFloat(airborne) * 0.07 + CGFloat(gather) * 0.09,
                    shadowScale: CGFloat(1.0 - airborne * 0.55)
                )
            }
        }
    }
}

#Preview("Gain") {
    let data = OnboardingData()
    data.sex = "男性"
    data.activityLevel = "週3〜5回　定期的に運動する"
    data.dateOfBirth = Calendar.current.date(byAdding: .year, value: -28, to: Date()) ?? Date()
    data.heightCm = 175
    data.weightKg = 65
    data.goalWeightKg = 71
    data.goalDirection = OnboardingData.GoalDirection.gain
    return OnboardingPaceView(onNext: {})
        .environmentObject(data)
        .background(Color("AppBackground"))
}

#Preview("Lose") {
    let data = OnboardingData()
    data.sex = "女性"
    data.activityLevel = "週0〜2回　たまに運動する"
    data.dateOfBirth = Calendar.current.date(byAdding: .year, value: -34, to: Date()) ?? Date()
    data.heightCm = 162
    data.weightKg = 72
    data.goalWeightKg = 64
    data.goalDirection = OnboardingData.GoalDirection.lose
    return OnboardingPaceView(onNext: {})
        .environmentObject(data)
        .background(Color("AppBackground"))
}
