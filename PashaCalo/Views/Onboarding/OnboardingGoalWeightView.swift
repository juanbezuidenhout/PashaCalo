import SwiftUI

struct OnboardingGoalWeightView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    @State private var goalWeightKg: Double = 60

    private let goalRange: ClosedRange<Double> = 30...200

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("目標体重を設定してください")
                .font(.custom("NotoSansJP-Bold", size: 26))
                .foregroundStyle(Color("TextPrimary"))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
                .padding(.top, 28)

            Spacer(minLength: 0)

            VStack(spacing: 8) {
                Text("体重を増やす")
                    .font(.custom("NotoSansJP-Regular", size: 16))
                    .foregroundStyle(Color("TextSecondary"))

                Text(formattedValue)
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(Color("TextPrimary"))
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 14)

            HorizontalRulerPicker(
                value: $goalWeightKg,
                range: goalRange
            )
            .frame(height: 120)

            Spacer(minLength: 0)

            if let warning = healthWarning {
                warningCard(title: warning.title, message: warning.message)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)
                    .transition(.opacity)
            }

            PrimaryButton(title: "次へ") {
                commit()
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .animation(.easeInOut(duration: 0.18), value: healthWarning?.title)
        .onAppear { syncFromData() }
    }

    // MARK: - Derived state

    private var formattedValue: String {
        String(format: "%.1f kg", goalWeightKg)
    }

    /// BMI based on the user's stored height and the currently picked goal
    /// weight. Returns `nil` if we don't yet have a height to compare against.
    private var goalBMI: Double? {
        guard data.heightCm > 0 else { return nil }
        let heightM = data.heightCm / 100.0
        return goalWeightKg / (heightM * heightM)
    }

    private var healthWarning: (title: String, message: String)? {
        guard let bmi = goalBMI else { return nil }
        if bmi < 18.5 {
            return (
                title: "目標が低すぎる可能性があります",
                message: "あなたの身長に対して健康的な範囲を下回っています"
            )
        }
        if bmi > 30 {
            return (
                title: "目標が高すぎる可能性があります",
                message: "あなたの身長に対して健康的な範囲を上回っています"
            )
        }
        return nil
    }

    // MARK: - Warning card

    private func warningCard(title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(red: 0.93, green: 0.62, blue: 0.16))
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom("NotoSansJP-Bold", size: 14))
                    .foregroundStyle(Color("TextPrimary"))
                Text(message)
                    .font(.custom("NotoSansJP-Regular", size: 13))
                    .foregroundStyle(Color("TextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(red: 1.0, green: 0.95, blue: 0.86))
        )
    }

    // MARK: - State sync

    private func syncFromData() {
        if data.goalWeightKg > 0 {
            goalWeightKg = clamp(data.goalWeightKg, to: goalRange)
            return
        }

        if data.weightKg > 0 {
            goalWeightKg = clamp(data.weightKg + 5, to: goalRange)
        }
    }

    private func clamp(_ value: Double, to range: ClosedRange<Double>) -> Double {
        min(max(value, range.lowerBound), range.upperBound)
    }

    private func commit() {
        data.goalWeightKg = (goalWeightKg * 10).rounded() / 10
    }
}

#Preview {
    let data = OnboardingData()
    data.goalDirection = OnboardingData.GoalDirection.gain
    data.heightCm = 172
    data.weightKg = 54
    return OnboardingGoalWeightView(onNext: {})
        .environmentObject(data)
        .background(Color("AppBackground"))
}
