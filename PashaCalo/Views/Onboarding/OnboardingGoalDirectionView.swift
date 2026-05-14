import SwiftUI

struct OnboardingGoalDirectionView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    private struct GoalOption: Identifiable {
        let id = UUID()
        let value: String
        let label: String
    }

    private let options: [GoalOption] = [
        .init(value: OnboardingData.GoalDirection.lose, label: "体重を減らす"),
        .init(value: OnboardingData.GoalDirection.maintain, label: "体重を維持する"),
        .init(value: OnboardingData.GoalDirection.gain, label: "体重を増やす")
    ]

    private var isSelectionValid: Bool {
        !data.goalDirection.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("目標は何ですか？")
                    .font(.custom("NotoSansJP-Bold", size: 26))
                    .foregroundStyle(Color("TextPrimary"))
                    .fixedSize(horizontal: false, vertical: true)

                Text("あなたに合ったカロリープランの作成に使用します")
                    .font(.custom("NotoSansJP-Regular", size: 14))
                    .foregroundStyle(Color("TextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 28)

            VStack(spacing: 12) {
                ForEach(options) { option in
                    OnboardingSelectionCard(
                        isSelected: data.goalDirection == option.value,
                        height: 64,
                        cornerRadius: 14
                    ) {
                        data.goalDirection = option.value
                    } content: { selected in
                        HStack {
                            Text(option.label)
                                .font(.custom("NotoSansJP-SemiBold", size: 17))
                                .foregroundStyle(selected ? .white : Color("TextPrimary"))
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
    OnboardingGoalDirectionView(onNext: {})
        .environmentObject(OnboardingData())
        .background(Color("AppBackground"))
}
