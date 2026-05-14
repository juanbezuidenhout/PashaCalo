import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            Color("AppBackground")
                .ignoresSafeArea()

            Group {
                if !appState.hasFinishedSplash {
                    SplashView {
                        appState.completeSplash()
                    }
                    .transition(rootTransition)
                } else if !appState.hasFinishedWelcome {
                    WelcomeView()
                        .transition(rootTransition)
                } else if !appState.isOnboardingComplete {
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
            .animation(.easeInOut(duration: 0.35), value: appState.hasFinishedSplash)
            .animation(.easeInOut(duration: 0.35), value: appState.hasFinishedWelcome)
            .animation(.easeInOut(duration: 0.35), value: appState.isOnboardingComplete)
            .animation(.easeInOut(duration: 0.35), value: appState.isAuthenticated)
            .animation(.easeInOut(duration: 0.35), value: appState.hasSeenPaywall)
        }
        .onAppear { Haptics.warmUp() }
        .onChange(of: scenePhase) { phase in
            // Re-prime the Taptic Engine when the app returns from
            // background so the first tap after foregrounding is instant.
            if phase == .active { Haptics.warmUp() }
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
