import SwiftUI

struct OnboardingCompleteView: View {
    @EnvironmentObject private var appState: AppState

    @State private var pulse: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72, weight: .regular))
                .foregroundStyle(Color("HealthyGreen"))
                .scaleEffect(pulse ? 1.08 : 1.0)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 1.2)
                            .repeatForever(autoreverses: true)
                    ) {
                        pulse = true
                    }
                }

            VStack(spacing: 12) {
                Text("準備完了です！")
                    .font(.custom("NotoSansJP-Bold", size: 28))
                    .foregroundStyle(Color("TextPrimary"))
                    .multilineTextAlignment(.center)

                Text("あなた専用のプランが完成しました")
                    .font(.custom("NotoSansJP-Regular", size: 16))
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
            }

            Spacer()

            PrimaryButton(title: "アカウントを作成する") {
                appState.completeOnboarding()
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingCompleteView()
        .environmentObject(AppState())
        .background(Color("AppBackground"))
}
