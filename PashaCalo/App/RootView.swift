import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()

            Group {
                if !appState.isOnboardingComplete {
                    OnboardingFlowView()
                        .transition(rootTransition)
                } else if !appState.isAuthenticated {
                    AuthView()
                        .transition(rootTransition)
                } else if !appState.hasSeenPaywall {
                    PaywallTrustSequenceView()
                        .transition(rootTransition)
                } else {
                    MainTabView()
                        .transition(rootTransition)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: appState.isOnboardingComplete)
            .animation(.easeInOut(duration: 0.35), value: appState.isAuthenticated)
            .animation(.easeInOut(duration: 0.35), value: appState.hasSeenPaywall)
        }
    }

    private var rootTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
