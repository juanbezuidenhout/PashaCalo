import SwiftUI

struct OnboardingPreviousAppView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    private var isSelectionValid: Bool {
        data.hasTriedOtherApps != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("他のカロリー管理アプリを使ったことはありますか？")
                    .font(.custom("NotoSansJP-Bold", size: 26))
                    .foregroundStyle(Color("TextPrimary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 28)

            HStack(spacing: 12) {
                choiceCard(
                    icon: "hand.thumbsup.fill",
                    label: "はい",
                    isSelected: data.hasTriedOtherApps == true
                ) {
                    data.hasTriedOtherApps = true
                }

                choiceCard(
                    icon: "hand.thumbsdown.fill",
                    label: "いいえ",
                    isSelected: data.hasTriedOtherApps == false
                ) {
                    data.hasTriedOtherApps = false
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

    private func choiceCard(
        icon: String,
        label: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        OnboardingSelectionCard(
            isSelected: isSelected,
            height: 100,
            cornerRadius: 14,
            action: action
        ) { selected in
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(selected ? .white : Color("TextPrimary"))

                Text(label)
                    .font(.custom("NotoSansJP-SemiBold", size: 16))
                    .foregroundStyle(selected ? .white : Color("TextPrimary"))
            }
        }
    }
}

#Preview {
    OnboardingPreviousAppView(onNext: {})
        .environmentObject(OnboardingData())
        .background(Color("AppBackground"))
}
