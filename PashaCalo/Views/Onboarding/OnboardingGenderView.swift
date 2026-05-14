import SwiftUI

struct OnboardingGenderView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    private let options = ["男性", "女性", "その他"]

    private var isSelectionValid: Bool {
        !data.sex.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("性別を選択してください")
                    .font(.custom("NotoSansJP-Bold", size: 26))
                    .foregroundStyle(Color("TextPrimary"))

                Text("あなたに合ったプランを作成します")
                    .font(.custom("NotoSansJP-Regular", size: 14))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .padding(.top, 28)

            VStack(spacing: 12) {
                ForEach(options, id: \.self) { option in
                    OnboardingSelectionCard(
                        isSelected: data.sex == option,
                        height: 64,
                        cornerRadius: 14
                    ) {
                        data.sex = option
                    } content: { selected in
                        HStack {
                            Text(option)
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
    OnboardingGenderView(onNext: {})
        .environmentObject(OnboardingData())
        .background(Color("AppBackground"))
}
