import SwiftUI

@main
struct PashaCaloApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
                .task {
                    SupabaseManager.shared.appState = appState
                    if SupabaseManager.shared.isSignedIn {
                        appState.setAuthenticated(true)
                    }
                }
        }
    }
}
