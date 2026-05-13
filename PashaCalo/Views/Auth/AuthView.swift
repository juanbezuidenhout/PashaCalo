import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 10) {
                    Text("進行状況を保存")
                        .font(.custom("NotoSansJP-Bold", size: 28))
                        .foregroundStyle(Color("TextPrimary"))

                    Text("アカウントを作成して続けましょう")
                        .font(.custom("NotoSansJP-Regular", size: 15))
                        .foregroundStyle(Color("TextSecondary"))
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

                Spacer()

                PrimaryButton(title: "メールで続ける") {
                    appState.setAuthenticated(true)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AppState())
}
