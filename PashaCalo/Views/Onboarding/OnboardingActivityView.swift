import SwiftUI

struct OnboardingActivityView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    private struct ActivityOption: Identifiable {
        let id = UUID()
        let icon: String
        let label: String
    }

    private let options: [ActivityOption] = [
        .init(icon: "figure.walk", label: "週0〜2回　たまに運動する"),
        .init(icon: "figure.run", label: "週3〜5回　定期的に運動する"),
        .init(icon: "figure.strengthtraining.traditional", label: "週6回以上　本格的に鍛えている")
    ]

    private var isSelectionValid: Bool {
        !data.activityLevel.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("週に何回運動しますか？")
                    .font(.custom("NotoSansJP-Bold", size: 26))
                    .foregroundStyle(Color("TextPrimary"))

                Text("目標カロリーの計算に使用します")
                    .font(.custom("NotoSansJP-Regular", size: 14))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .padding(.top, 28)

            VStack(spacing: 12) {
                ForEach(options) { option in
                    OnboardingSelectionCard(
                        isSelected: data.activityLevel == option.label,
                        height: 64,
                        cornerRadius: 14
                    ) {
                        data.activityLevel = option.label
                    } content: { selected in
                        HStack(spacing: 14) {
                            Image(systemName: option.icon)
                                .font(.system(size: 22, weight: .regular))
                                .foregroundStyle(selected ? .white : Color("TextPrimary"))
                                .frame(width: 28)

                            Text(option.label)
                                .font(.custom("NotoSansJP-SemiBold", size: 15))
                                .foregroundStyle(selected ? .white : Color("TextPrimary"))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)

                            Spacer()
                        }
                    }
                }
            }

            Spacer()

            PrimaryButton(title: "次へ") {
                onNext()
            }
            .disabled(!isSelectionValid)
            .opacity(isSelectionValid ? 1.0 : 0.4)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    OnboardingActivityView(onNext: {})
        .environmentObject(OnboardingData())
        .background(Color("AppBackground"))
}
