import SwiftUI

struct OnboardingGoalWeightView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    @State private var goalWeightKg: Int = 60

    private let goalRange: ClosedRange<Int> = 30...200

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("目標体重を入力してください")
                    .font(.custom("NotoSansJP-Bold", size: 26))
                    .foregroundStyle(Color("TextPrimary"))
                    .fixedSize(horizontal: false, vertical: true)

                Text("無理のない目標が長続きのコツです")
                    .font(.custom("NotoSansJP-Regular", size: 14))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .padding(.top, 28)

            pickerSection
                .padding(.top, 8)

            Spacer()

            PrimaryButton(title: "次へ") {
                commit()
                onNext()
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .onAppear { syncFromData() }
    }

    private var pickerSection: some View {
        wheelColumn(label: "目標体重") {
            NativeWheelPicker(
                selection: $goalWeightKg,
                range: goalRange,
                unit: "kg"
            )
        }
        .frame(height: 280)
    }

    @ViewBuilder
    private func wheelColumn<Picker: View>(
        label: String,
        @ViewBuilder picker: () -> Picker
    ) -> some View {
        VStack(spacing: 14) {
            Text(label)
                .font(.custom("NotoSansJP-Bold", size: 18))
                .foregroundStyle(Color("TextPrimary"))

            ZStack {
                Capsule(style: .continuous)
                    .fill(Color(.systemGray5))
                    .frame(height: 40)
                    .padding(.horizontal, 6)

                picker()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    private func syncFromData() {
        if data.goalWeightKg > 0 {
            goalWeightKg = clamp(Int(data.goalWeightKg.rounded()), to: goalRange)
        } else if data.weightKg > 0 {
            goalWeightKg = clamp(Int(data.weightKg.rounded()), to: goalRange)
        }
    }

    private func clamp(_ value: Int, to range: ClosedRange<Int>) -> Int {
        min(max(value, range.lowerBound), range.upperBound)
    }

    private func commit() {
        data.goalWeightKg = Double(goalWeightKg)
    }
}

#Preview {
    OnboardingGoalWeightView(onNext: {})
        .environmentObject(OnboardingData())
        .background(Color("AppBackground"))
}
