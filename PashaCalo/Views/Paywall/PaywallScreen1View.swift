import SwiftUI

struct PaywallScreen1View: View {
    let onNext: () -> Void

    private let features: [(icon: String, text: String)] = [
        ("photo.on.rectangle", "写真から栄養を自動計算"),
        ("chart.bar.fill", "詳細な栄養バランス分析"),
        ("fork.knife", "コンビニ・外食データベース"),
        ("square.and.arrow.up", "バイラル共有カード")
    ]

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundStyle(Color("AccentBlack"))

                    Text("3日間、すべて無料でお試しください")
                        .font(.custom("NotoSansJP-Bold", size: 26))
                        .foregroundStyle(Color("TextPrimary"))
                        .multilineTextAlignment(.center)

                    Text("いつでもキャンセルできます")
                        .font(.custom("NotoSansJP-Regular", size: 14))
                        .foregroundStyle(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 18) {
                    ForEach(features, id: \.icon) { feature in
                        HStack(spacing: 14) {
                            Image(systemName: feature.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color("AccentBlack"))
                                .frame(width: 28, alignment: .center)

                            Text(feature.text)
                                .font(.custom("NotoSansJP-Regular", size: 15))
                                .foregroundStyle(Color("TextPrimary"))

                            Spacer(minLength: 0)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 36)

                Spacer()

                PrimaryButton(title: "無料トライアルを始める", action: onNext)
                    .padding(.bottom, 32)
            }
            .padding(.horizontal, 28)
        }
    }
}

#Preview {
    PaywallScreen1View(onNext: {})
}
