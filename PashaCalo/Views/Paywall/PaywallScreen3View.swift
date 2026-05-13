import SwiftUI

struct PaywallScreen3View: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedPlan: Int = 0

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header
                        .padding(.top, 16)

                    VStack(spacing: 12) {
                        annualCard
                        monthlyCard
                        weeklyCard
                    }

                    Spacer(minLength: 8)

                    PrimaryButton(title: "3日間無料で試す") {
                        appState.setSubscribed(true)
                        appState.completePaywall()
                    }
                    .padding(.top, 4)

                    Button {
                        appState.completePaywall()
                    } label: {
                        Text("今はスキップ")
                            .font(.custom("NotoSansJP-Regular", size: 14))
                            .foregroundStyle(Color("TextSecondary"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)

                    Text("3日間の無料トライアル後、選択したプランで自動更新されます。")
                        .font(.custom("NotoSansJP-Regular", size: 11))
                        .foregroundStyle(Color("TextTertiary"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)

                    Text("プライバシーポリシー　利用規約　購入を復元")
                        .font(.custom("NotoSansJP-Regular", size: 11))
                        .foregroundStyle(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 28)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("プランを選択してください")
                .font(.custom("NotoSansJP-Bold", size: 24))
                .foregroundStyle(Color("TextPrimary"))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.yellow)
                    }
                }

                Text("4.8　10,000人以上が利用中")
                    .font(.custom("NotoSansJP-Regular", size: 13))
                    .foregroundStyle(Color("TextSecondary"))

                Spacer(minLength: 0)
            }
        }
    }

    private var annualCard: some View {
        planCard(index: 0) {
            ZStack(alignment: .topTrailing) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("年間プラン")
                            .font(.custom("NotoSansJP-SemiBold", size: 16))
                            .foregroundStyle(Color("TextPrimary"))

                        Text("月あたり約 ¥567")
                            .font(.custom("NotoSansJP-Regular", size: 12))
                            .foregroundStyle(Color("HealthyGreen"))
                    }

                    Spacer(minLength: 0)

                    Text("¥6,800 / 年")
                        .font(.custom("NotoSansJP-Bold", size: 18))
                        .foregroundStyle(Color("AccentBlack"))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)

                Text("最もお得")
                    .font(.custom("NotoSansJP-Bold", size: 10))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color("AccentBlack"))
                    )
                    .offset(x: -12, y: -8)
            }
        }
    }

    private var monthlyCard: some View {
        planCard(index: 1) {
            HStack(alignment: .center, spacing: 12) {
                Text("月間プラン")
                    .font(.custom("NotoSansJP-SemiBold", size: 16))
                    .foregroundStyle(Color("TextPrimary"))

                Spacer(minLength: 0)

                Text("¥980 / 月")
                    .font(.custom("NotoSansJP-Bold", size: 18))
                    .foregroundStyle(Color("AccentBlack"))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
        }
    }

    private var weeklyCard: some View {
        planCard(index: 2) {
            HStack(alignment: .center, spacing: 12) {
                Text("週間プラン")
                    .font(.custom("NotoSansJP-SemiBold", size: 16))
                    .foregroundStyle(Color("TextPrimary"))

                Spacer(minLength: 0)

                Text("¥380 / 週")
                    .font(.custom("NotoSansJP-Bold", size: 18))
                    .foregroundStyle(Color("AccentBlack"))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
        }
    }

    private func planCard<Content: View>(
        index: Int,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let isSelected = selectedPlan == index
        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedPlan = index
            }
        } label: {
            content()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isSelected ? Color("AccentBlack").opacity(0.06) : Color("CardBackground"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            isSelected ? Color("AccentBlack") : Color("BorderLight"),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PaywallScreen3View()
        .environmentObject(AppState())
}
