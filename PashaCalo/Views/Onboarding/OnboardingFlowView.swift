import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Text("パシャカロ")
                        .font(.custom("NotoSansJP-Bold", size: 34))
                        .foregroundStyle(Color("TextPrimary"))

                    Text("カロリー管理を簡単に")
                        .font(.custom("NotoSansJP-Regular", size: 17))
                        .foregroundStyle(Color("TextSecondary"))
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 10)

                Spacer()

                PrimaryButton(title: "はじめる") {
                    appState.completeOnboarding()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    OnboardingFlowView()
        .environmentObject(AppState())
}
