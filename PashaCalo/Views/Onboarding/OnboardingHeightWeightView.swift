import SwiftUI

struct OnboardingHeightWeightView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    @State private var heightText: String = ""
    @State private var weightText: String = ""

    private var heightValue: Double? {
        let value = Double(heightText)
        guard let value, value > 0 else { return nil }
        return value
    }

    private var weightValue: Double? {
        let value = Double(weightText)
        guard let value, value > 0 else { return nil }
        return value
    }

    private var isValid: Bool {
        heightValue != nil && weightValue != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("身長と体重を教えてください")
                    .font(.custom("NotoSansJP-Bold", size: 26))
                    .foregroundStyle(Color("TextPrimary"))
                    .fixedSize(horizontal: false, vertical: true)

                Text("目標kcalの計算に使います")
                    .font(.custom("NotoSansJP-Regular", size: 14))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .padding(.top, 28)

            VStack(spacing: 12) {
                inputRow(
                    label: "身長",
                    text: $heightText,
                    unit: "cm",
                    keyboard: .numberPad
                )

                inputRow(
                    label: "体重",
                    text: $weightText,
                    unit: "kg",
                    keyboard: .decimalPad
                )
            }

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

    private func inputRow(
        label: String,
        text: Binding<String>,
        unit: String,
        keyboard: UIKeyboardType
    ) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.custom("NotoSansJP-SemiBold", size: 16))
                .foregroundStyle(Color("TextPrimary"))
                .frame(width: 72, alignment: .leading)

            TextField("", text: text)
                .keyboardType(keyboard)
                .font(.custom("NotoSansJP-Regular", size: 18))
                .foregroundStyle(Color("TextPrimary"))
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity)

            Text(unit)
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
        if data.heightCm > 0 && heightText.isEmpty {
            heightText = formatNumber(data.heightCm, allowsDecimal: false)
        }
        if data.weightKg > 0 && weightText.isEmpty {
            weightText = formatNumber(data.weightKg, allowsDecimal: true)
        }
    }

    private func formatNumber(_ value: Double, allowsDecimal: Bool) -> String {
        if allowsDecimal {
            return value.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(value))
                : String(value)
        } else {
            return String(Int(value))
        }
    }

    private func commit() {
        if let height = heightValue {
            data.heightCm = height
        }
        if let weight = weightValue {
            data.weightKg = weight
        }
    }
}

#Preview {
    OnboardingHeightWeightView(onNext: {})
        .environmentObject(OnboardingData())
        .background(Color("AppBackground"))
}
