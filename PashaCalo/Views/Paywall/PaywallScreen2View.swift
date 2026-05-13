import SwiftUI

struct PaywallScreen2View: View {
    let onNext: () -> Void

    private let trustRows: [(icon: String, text: String)] = [
        ("lock.fill", "いつでもキャンセル可能"),
        ("bell.fill", "終了2日前にリマインダー送信"),
        ("creditcard.fill", "トライアル中は請求なし")
    ]

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundStyle(Color("AccentBlack"))

                    Text("終了の2日前にお知らせします")
                        .font(.custom("NotoSansJP-Bold", size: 26))
                        .foregroundStyle(Color("TextPrimary"))
                        .multilineTextAlignment(.center)

                    Text("無料期間中はいつでもキャンセルできます。請求は発生しません。")
                        .font(.custom("NotoSansJP-Regular", size: 14))
                        .foregroundStyle(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 18) {
                    ForEach(trustRows, id: \.icon) { row in
                        HStack(spacing: 14) {
                            Image(systemName: row.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color("AccentBlack"))
                                .frame(width: 28, alignment: .center)

                            Text(row.text)
                                .font(.custom("NotoSansJP-Regular", size: 15))
                                .foregroundStyle(Color("TextPrimary"))

                            Spacer(minLength: 0)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 36)

                Spacer()

                PrimaryButton(title: "わかりました", action: onNext)
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, 28)
        }
    }
}

#Preview {
    PaywallScreen2View(onNext: {})
}
