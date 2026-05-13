import SwiftUI

struct PaywallTrustSequenceView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Text("プランを選択")
                        .font(.custom("NotoSansJP-Bold", size: 28))
                        .foregroundStyle(Color("TextPrimary"))

                    Text("3日間の無料トライアルですべての機能をお試しください")
                        .font(.custom("NotoSansJP-Regular", size: 15))
                        .foregroundStyle(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.regularMaterial)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 10)
                .padding(.horizontal, 24)

                Spacer()

                PrimaryButton(title: "続ける") {
                    appState.completePaywall()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    PaywallTrustSequenceView()
        .environmentObject(AppState())
}
