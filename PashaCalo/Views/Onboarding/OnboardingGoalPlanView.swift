import SwiftUI

/// Goal-summary teaser shown directly after the step that captures the
/// user's target weight (or, for maintain, the barriers list). Reads back
/// the chosen direction with the delta highlighted in an accent colour, and
/// previews the personalised plan we'll build next.
struct OnboardingGoalPlanView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    private let accent = Color(red: 0.93, green: 0.55, blue: 0.18)

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            VStack(spacing: 16) {
                titleText
                    .font(.custom("NotoSansJP-Bold", size: 26))
                    .foregroundStyle(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)

                Text("あなたの習慣・目標・期間に合わせて、あなた専用のプランを作成します。着実に進められるようサポートします。")
                    .font(.custom("NotoSansJP-Regular", size: 15))
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 12)
            }

            Spacer(minLength: 0)

            PrimaryButton(title: "次へ") {
                onNext()
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Title (dynamic per goal direction)

    /// Builds the headline as `AttributedString` so we can colour the
    /// "{delta}kg" segment without concatenating multiple `Text` views
    /// (which breaks line-wrapping).
    private var titleText: Text {
        switch data.goalDirection {
        case OnboardingData.GoalDirection.lose:
            return directionalTitle(verb: "減量")
        case OnboardingData.GoalDirection.gain:
            return directionalTitle(verb: "増量")
        default:
            return Text("今の体重を維持するために、\nまずは計画を立てましょう")
        }
    }

    private func directionalTitle(verb: String) -> Text {
        let delta = formattedDelta
        let highlighted = "\(delta)kg"
        let full = "\(highlighted)の\(verb)に向けて、\nまずは計画を立てましょう"

        var attributed = AttributedString(full)
        if let range = attributed.range(of: highlighted) {
            attributed[range].foregroundColor = accent
        }
        return Text(attributed)
    }

    private var formattedDelta: String {
        let raw = abs(data.goalWeightKg - data.weightKg)
        let positive = max(raw, 1)
        if abs(positive - positive.rounded()) < 0.05 {
            return String(format: "%.0f", positive)
        }
        return String(format: "%.1f", positive)
    }
}

#Preview("Gain") {
    let data = OnboardingData()
    data.goalDirection = OnboardingData.GoalDirection.gain
    data.weightKg = 54
    data.goalWeightKg = 60
    return OnboardingGoalPlanView(onNext: {})
        .environmentObject(data)
        .background(Color("AppBackground"))
}

#Preview("Lose") {
    let data = OnboardingData()
    data.goalDirection = OnboardingData.GoalDirection.lose
    data.weightKg = 72
    data.goalWeightKg = 66
    return OnboardingGoalPlanView(onNext: {})
        .environmentObject(data)
        .background(Color("AppBackground"))
}

#Preview("Maintain") {
    let data = OnboardingData()
    data.goalDirection = OnboardingData.GoalDirection.maintain
    data.weightKg = 65
    return OnboardingGoalPlanView(onNext: {})
        .environmentObject(data)
        .background(Color("AppBackground"))
}
