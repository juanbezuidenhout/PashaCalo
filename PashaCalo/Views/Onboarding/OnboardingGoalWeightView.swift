import SwiftUI

struct OnboardingGoalWeightView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    @State private var goalText: String = ""

    private var goalValue: Double? {
        let value = Double(goalText)
        guard let value, value > 0 else { return nil }
        return value
    }

    private var isValid: Bool {
        goalValue != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("目標体重を教えてください")
                    .font(.custom("NotoSansJP-Bold", size: 26))
                    .foregroundStyle(Color("TextPrimary"))
                    .fixedSize(horizontal: false, vertical: true)

                Text("無理のない目標が長続きのコツです")
                    .font(.custom("NotoSansJP-Regular", size: 14))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .padding(.top, 28)

            inputRow

            Spacer()

            PrimaryButton(title: "次へ") {
                commit()
                onNext()
            }
            .disabled(!isValid)
            .opacity(isValid ? 1.0 : 0.4)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .onAppear { syncFromData() }
    }

    private var inputRow: some View {
        HStack(spacing: 12) {
            Text("目標体重")
                .font(.custom("NotoSansJP-SemiBold", size: 16))
                .foregroundStyle(Color("TextPrimary"))
                .frame(width: 88, alignment: .leading)

            TextField("", text: $goalText)
                .keyboardType(.decimalPad)
                .font(.custom("NotoSansJP-Regular", size: 18))
                .foregroundStyle(Color("TextPrimary"))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity)

            Text("kg")
                .font(.custom("NotoSansJP-Regular", size: 14))
                .foregroundStyle(Color("TextSecondary"))
                .frame(width: 32, alignment: .trailing)
        }
        .padding(.horizontal, 18)
        .frame(height: 64)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color("BorderLight"), lineWidth: 1)
        )
    }

    private func syncFromData() {
        if data.goalWeightKg > 0 && goalText.isEmpty {
            goalText = data.goalWeightKg.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(data.goalWeightKg))
                : String(data.goalWeightKg)
        }
    }

    private func commit() {
        if let goal = goalValue {
            data.goalWeightKg = goal
        }
    }
}

#Preview {
    OnboardingGoalWeightView(onNext: {})
        .environmentObject(OnboardingData())
        .background(Color("AppBackground"))
}
