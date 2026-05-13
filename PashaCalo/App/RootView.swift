import SwiftUI

/// Top-level navigator: Onboarding → Paywall trust sequence → Main app
struct RootView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            switch appState.currentScreen {
            case .onboarding:
                OnboardingFlowView()
                    .transition(.opacity)
            case .paywall:
                PaywallTrustSequenceView()
                    .transition(.opacity)
            case .main:
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: appState.currentScreen)
    }
}
