import SwiftUI

/// Cal AI's exact 3-screen paywall trust sequence:
/// Screen 1: "Try free" (not the paywall yet)
/// Screen 2: "We'll remind you before trial ends" (trust building)
/// Screen 3: The actual paywall (now they're primed)
struct PaywallTrustSequenceView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentScreen: Int = 0

    var body: some View {
        ZStack {
            Color("BackgroundCream").ignoresSafeArea()

            Group {
                switch currentScreen {
                case 0:
                    PaywallScreen1View {
                        withAnimation { currentScreen = 1 }
                    }
                case 1:
                    PaywallScreen2View {
                        withAnimation { currentScreen = 2 }
                    }
                case 2:
                    PaywallScreen3View(
                        onSubscribe: { tier in
                            // TODO: Trigger RevenueCat purchase for tier
                            appState.setSubscribed(true)
                        },
                        onSkip: {
                            appState.completePaywall()
                        }
                    )
                default:
                    EmptyView()
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.easeInOut(duration: 0.35), value: currentScreen)
        }
    }
}

// MARK: - Screen 1: Free Trial Offer (NOT the paywall yet)

struct PaywallScreen1View: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color("AccentGreen"))

                VStack(spacing: 12) {
                    Text("パシャカロを\n無料でお試しください")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .multilineTextAlignment(.center)

                    Text("3日間の無料トライアルで\nすべての機能をご利用いただけます")
                        .font(.system(size: 16))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                VStack(spacing: 12) {
                    PaywallFeatureRow(icon: "camera.fill", text: "無制限の食事スキャン")
                    PaywallFeatureRow(icon: "chart.bar.fill", text: "詳細な栄養分析")
                    PaywallFeatureRow(icon: "checkmark.seal.fill", text: "コンビニ食品データベース")
                    PaywallFeatureRow(icon: "square.and.arrow.up", text: "バイラル共有カード")
                }
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 32)

            Spacer()

            PrimaryButton(title: "無料トライアルを開始する") {
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Screen 2: Trust Builder (reminder before trial ends)

struct PaywallScreen2View: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color("AccentGreen"))

                VStack(spacing: 12) {
                    Text("トライアル終了前に\nお知らせします")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                        .multilineTextAlignment(.center)

                    Text("無料期間が終わる2日前に\nリマインダーをお送りします\n\nいつでもキャンセル可能です")
                        .font(.system(size: 16))
                        .foregroundColor(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                // Trust indicators
                VStack(spacing: 12) {
                    TrustRow(icon: "lock.fill", text: "いつでもキャンセルできます")
                    TrustRow(icon: "bell.fill", text: "終了2日前にリマインダー送信")
                    TrustRow(icon: "creditcard.fill", text: "トライアル中は請求なし")
                }
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 32)

            Spacer()

            PrimaryButton(title: "了解しました") {
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Screen 3: The Actual Paywall

struct PaywallScreen3View: View {
    let onSubscribe: (SubscriptionTier) -> Void
    let onSkip: () -> Void

    @State private var selectedTier: SubscriptionTier = .annual

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("プランを選択してください")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))

                    // Social proof
                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                        }
                        Text("4.8  •  10,000人以上が利用中")
                            .font(.system(size: 13))
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
                .padding(.top, 32)

                // Pricing cards
                VStack(spacing: 12) {
                    PaywallPricingCard(
                        tier: .annual,
                        badge: "最もお得",
                        isSelected: selectedTier == .annual
                    ) { selectedTier = .annual }

                    PaywallPricingCard(
                        tier: .monthly,
                        badge: nil,
                        isSelected: selectedTier == .monthly
                    ) { selectedTier = .monthly }

                    PaywallPricingCard(
                        tier: .weekly,
                        badge: nil,
                        isSelected: selectedTier == .weekly
                    ) { selectedTier = .weekly }
                }
                .padding(.horizontal, 24)

                // CTA
                VStack(spacing: 12) {
                    PrimaryButton(title: "3日間無料で試す") {
                        onSubscribe(selectedTier)
                    }

                    Button("今はスキップ") {
                        onSkip()
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Color("TextSecondary"))
                }
                .padding(.horizontal, 24)

                // Legal
                VStack(spacing: 4) {
                    Text("3日間の無料トライアル後、選択したプランで自動更新されます。")
                        .font(.system(size: 11))
                        .foregroundColor(Color("TextTertiary"))
                        .multilineTextAlignment(.center)

                    HStack(spacing: 16) {
                        Button("プライバシーポリシー") { }
                            .font(.system(size: 11))
                            .foregroundColor(Color("TextSecondary"))

                        Button("利用規約") { }
                            .font(.system(size: 11))
                            .foregroundColor(Color("TextSecondary"))

                        Button("購入を復元") { }
                            .font(.system(size: 11))
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Paywall Pricing Card

struct PaywallPricingCard: View {
    let tier: SubscriptionTier
    let badge: String?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(tier.japaneseLabel)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("TextPrimary"))

                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color("AccentGreen"))
                                .cornerRadius(8)
                        }
                    }

                    if let savings = tier.savingsLabel {
                        Text(savings)
                            .font(.system(size: 12))
                            .foregroundColor(Color("AccentGreen"))
                    }
                }

                Spacer()

                Text(tier.japanesePrice)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isSelected ? Color("AccentGreen") : Color("TextPrimary"))
            }
            .padding(16)
            .background(isSelected ? Color("AccentGreen").opacity(0.08) : Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color("AccentGreen") : Color("BorderLight"), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Helper Views

struct PaywallFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color("AccentGreen"))
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Color("TextPrimary"))
            Spacer()
        }
    }
}

struct TrustRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(Color("AccentGreen"))
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Color("TextPrimary"))
            Spacer()
        }
    }
}
