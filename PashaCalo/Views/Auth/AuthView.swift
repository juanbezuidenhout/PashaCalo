import AuthenticationServices
import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 0) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color("AccentBlack"))
                    .padding(.top, 80)

                Text("進行状況を保存する")
                    .font(.custom("NotoSansJP-Bold", size: 24))
                    .foregroundStyle(Color("AccentBlack"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)

                Text("アカウントを作成して記録を続けましょう")
                    .font(.custom("NotoSansJP-Regular", size: 15))
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                Spacer()

                VStack(spacing: 12) {
                    appleSignInButton
                    googleSignInButton
                    emailSignInButton
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 28)
        }
    }

    private var appleSignInButton: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { _ in
            // Real auth handling lands in a later prompt; for now accept any result.
            appState.setAuthenticated(true)
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var googleSignInButton: some View {
        Button {
            appState.setAuthenticated(true)
        } label: {
            providerLabel(
                systemImage: "g.circle.fill",
                title: "Googleでサインイン"
            )
        }
        .buttonStyle(.plain)
    }

    private var emailSignInButton: some View {
        Button {
            appState.setAuthenticated(true)
        } label: {
            providerLabel(
                systemImage: "envelope.fill",
                title: "メールで続ける"
            )
        }
        .buttonStyle(.plain)
    }

    private func providerLabel(systemImage: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color("AccentBlack"))

            Text(title)
                .font(.custom("NotoSansJP-SemiBold", size: 16))
                .foregroundStyle(Color("AccentBlack"))

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color("BorderLight"), lineWidth: 1)
        )
    }
}

#Preview {
    AuthView()
        .environmentObject(AppState())
}
