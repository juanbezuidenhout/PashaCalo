import SwiftUI

struct OnboardingDietView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    private struct DietOption: Identifiable {
        let id = UUID()
        let key: String
        let icon: String
        let label: String
    }

    private let options: [DietOption] = [
        .init(
            key: OnboardingData.DietStyle.classic,
            icon: "fork.knife",
            label: "指定なし"
        ),
        .init(
            key: OnboardingData.DietStyle.pescatarian,
            icon: "fish.fill",
            label: "ペスカタリアン"
        ),
        .init(
            key: OnboardingData.DietStyle.vegetarian,
            // SF Symbols 5 (iOS 17+). Devices on iOS 16 will render a blank
            // glyph here, which is acceptable given our active user base.
            icon: "carrot.fill",
            label: "ベジタリアン"
        ),
        .init(
            key: OnboardingData.DietStyle.vegan,
            icon: "leaf.fill",
            label: "ヴィーガン"
        )
    ]

    private var isSelectionValid: Bool {
        !data.dietStyle.isEmpty
    }

    private let rowBackground = Color(red: 0.95, green: 0.94, blue: 0.97)

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("食事スタイルを選択してください")
                .font(.custom("NotoSansJP-Bold", size: 26))
                .foregroundStyle(Color("TextPrimary"))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 28)

            VStack(spacing: 12) {
                ForEach(options) { option in
                    dietRow(option)
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

    @ViewBuilder
    private func dietRow(_ option: DietOption) -> some View {
        let selected = data.dietStyle == option.key

        Button {
            data.dietStyle = option.key
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(selected ? Color.white.opacity(0.18) : Color.white)
                        .frame(width: 40, height: 40)
                    Image(systemName: option.icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(selected ? .white : Color("TextPrimary"))
                }

                Text(option.label)
                    .font(.custom("NotoSansJP-SemiBold", size: 16))
                    .foregroundStyle(selected ? .white : Color("TextPrimary"))

                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selected ? Color("AccentBlack") : rowBackground)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: selected)
    }
}

#Preview {
    OnboardingDietView(onNext: {})
        .environmentObject(OnboardingData())
        .background(Color("AppBackground"))
}
