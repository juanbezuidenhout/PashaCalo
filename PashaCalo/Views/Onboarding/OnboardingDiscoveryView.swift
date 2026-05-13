import SwiftUI

struct OnboardingDiscoveryView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    private struct DiscoveryOption: Identifiable {
        let id = UUID()
        let icon: String
        let label: String
    }

    private let options: [DiscoveryOption] = [
        .init(icon: "camera.fill", label: "Instagram"),
        .init(icon: "bird", label: "X / Twitter"),
        .init(icon: "music.note", label: "TikTok"),
        .init(icon: "hand.thumbsup.fill", label: "Facebook"),
        .init(icon: "play.rectangle.fill", label: "YouTube"),
        .init(icon: "person.2.fill", label: "友人・家族"),
        .init(icon: "applelogo", label: "App Store"),
        .init(icon: "ellipsis.circle", label: "その他")
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
                                Image(systemName: option.icon)
                                    .font(.system(size: 22, weight: .regular))
                                    .foregroundStyle(selected ? .white : Color("TextPrimary"))
                                    .frame(width: 28)

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
}

#Preview {
    OnboardingDiscoveryView(onNext: {})
        .environmentObject(OnboardingData())
        .background(Color("AppBackground"))
}
