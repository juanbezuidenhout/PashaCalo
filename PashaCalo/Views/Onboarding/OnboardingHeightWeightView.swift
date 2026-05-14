import SwiftUI

struct OnboardingHeightWeightView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    @State private var heightCm: Int = 168
    @State private var weightKg: Int = 60

    private let heightRange: ClosedRange<Int> = 100...230
    private let weightRange: ClosedRange<Int> = 30...200

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("身長と体重を入力してください")
                    .font(.custom("NotoSansJP-Bold", size: 26))
                    .foregroundStyle(Color("TextPrimary"))
                    .fixedSize(horizontal: false, vertical: true)

                Text("目標カロリーの計算に使用します")
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
        HStack(alignment: .top, spacing: 12) {
            wheelColumn(label: "身長") {
                NativeWheelPicker(
                    selection: $heightCm,
                    range: heightRange,
                    unit: "cm"
                )
            }
            wheelColumn(label: "体重") {
                NativeWheelPicker(
                    selection: $weightKg,
                    range: weightRange,
                    unit: "kg"
                )
            }
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
        if data.heightCm > 0 {
            heightCm = clamp(Int(data.heightCm.rounded()), to: heightRange)
        }
        if data.weightKg > 0 {
            weightKg = clamp(Int(data.weightKg.rounded()), to: weightRange)
        }
    }

    private func clamp(_ value: Int, to range: ClosedRange<Int>) -> Int {
        min(max(value, range.lowerBound), range.upperBound)
    }

    private func commit() {
        data.heightCm = Double(heightCm)
        data.weightKg = Double(weightKg)
    }
}

#Preview {
    OnboardingHeightWeightView(onNext: {})
        .environmentObject(OnboardingData())
        .background(Color("AppBackground"))
}
