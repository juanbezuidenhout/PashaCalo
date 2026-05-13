import AuthenticationServices
import CryptoKit
import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var appState: AppState

    @State private var currentNonce: String? = nil
    @State private var isWorking: Bool = false
    @State private var errorMessage: String? = nil

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

                if let errorMessage {
                    Text(errorMessage)
                        .font(.custom("NotoSansJP-Regular", size: 12))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                }

                Spacer()

                VStack(spacing: 12) {
                    appleSignInButton
                    googleSignInButton
                    emailSignInButton
                }
                .disabled(isWorking)
                .opacity(isWorking ? 0.6 : 1.0)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 28)
        }
    }

    private var appleSignInButton: some View {
        SignInWithAppleButton(.signIn) { request in
            let nonce = randomNonceString()
            currentNonce = nonce
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
        } onCompletion: { result in
            handleAppleCompletion(result)
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var googleSignInButton: some View {
        Button {
            // Google Sign-In requires the GoogleSignIn SDK to obtain a real idToken.
            // Add GoogleSignIn-iOS via SPM, present GIDSignIn from this view,
            // then pass the resulting idToken to SupabaseManager.shared.signInWithGoogle.
            errorMessage = "Google サインインは準備中です"
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
            // Email auth needs a dedicated input screen (magic link or OTP).
            // Build EmailAuthView and call supabase.auth.signInWithOTP from there.
            errorMessage = "メールサインインは準備中です"
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

    // MARK: - Apple sign-in completion

    private func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idTokenString = String(data: tokenData, encoding: .utf8),
                let nonce = currentNonce
            else {
                errorMessage = "Apple サインインに失敗しました"
                return
            }

            isWorking = true
            errorMessage = nil
            Task {
                defer { isWorking = false }
                do {
                    try await SupabaseManager.shared.signInWithApple(
                        idToken: idTokenString,
                        nonce: nonce
                    )
                } catch {
                    errorMessage = "サインインエラー: \(error.localizedDescription)"
                }
            }

        case .failure(let error):
            // User cancellation has code .canceled; suppress that as it isn't an error.
            if (error as NSError).code == ASAuthorizationError.canceled.rawValue {
                return
            }
            errorMessage = "Apple サインインエラー: \(error.localizedDescription)"
        }
    }

    // MARK: - Nonce helpers

    /// Generates a cryptographically random nonce string.
    /// Apple requires the raw nonce passed through to the IdP, with its SHA256 hash
    /// included in the original authorization request.
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array(
            "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
        )
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                return random
            }
            for random in randoms where remainingLength > 0 {
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

#Preview {
    AuthView()
        .environmentObject(AppState())
}
