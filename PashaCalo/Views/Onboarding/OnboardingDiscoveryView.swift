import SwiftUI

struct OnboardingDiscoveryView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    private enum DiscoveryIcon {
        case asset(String)
        case symbol(String)
    }

    private struct DiscoveryOption: Identifiable {
        let id = UUID()
        let icon: DiscoveryIcon
        let label: String
    }

    private let options: [DiscoveryOption] = [
        .init(icon: .asset("InstagramLogo"), label: "Instagram"),
        .init(icon: .asset("XLogo"), label: "X / Twitter"),
        .init(icon: .asset("TikTokLogo"), label: "TikTok"),
        .init(icon: .asset("FacebookLogo"), label: "Facebook"),
        .init(icon: .asset("YouTubeLogo"), label: "YouTube"),
        .init(icon: .symbol("person.2.fill"), label: "友人・家族"),
        .init(icon: .asset("AppStoreLogo"), label: "App Store"),
        .init(icon: .symbol("ellipsis.circle"), label: "その他")
    ]

    private var isSelectionValid: Bool {
        !data.discoverySource.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("パシャカロをどこで知りましたか？")
                    .font(.custom("NotoSansJP-Bold", size: 26))
                    .foregroundStyle(Color("TextPrimary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 28)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(options) { option in
                        OnboardingSelectionCard(
                            isSelected: data.discoverySource == option.label,
                            height: 56,
                            cornerRadius: 14
                        ) {
                            data.discoverySource = option.label
                        } content: { selected in
                            HStack(spacing: 14) {
                                iconView(for: option.icon, selected: selected)
                                    .frame(width: 28, height: 28)

                                Text(option.label)
                                    .font(.custom("NotoSansJP-SemiBold", size: 16))
                                    .foregroundStyle(selected ? .white : Color("TextPrimary"))

                                Spacer()
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            PrimaryButton(title: "次へ") {
                onNext()
            }
            .disabled(!isSelectionValid)
            .opacity(isSelectionValid ? 1.0 : 0.4)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func iconView(for icon: DiscoveryIcon, selected: Bool) -> some View {
        switch icon {
        case .asset(let name):
            Image(name)
                .resizable()
                .interpolation(.high)
                .aspectRatio(contentMode: .fit)
        case .symbol(let name):
            // SF Symbols at 22pt visually overshoot the brand icons (which fill
            // ~96% of a 28pt frame). 18pt brings them to the same optical size.
            Image(systemName: name)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(selected ? .white : Color("TextPrimary"))
        }
    }
}

#Preview {
    OnboardingDiscoveryView(onNext: {})
        .environmentObject(OnboardingData())
        .background(Color("AppBackground"))
}
