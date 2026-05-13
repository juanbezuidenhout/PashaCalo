import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var isOnboardingComplete: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var hasSeenPaywall: Bool = false
    @Published var isSubscribed: Bool = false

    func completeOnboarding() {
        isOnboardingComplete = true
    }

    func completePaywall() {
        hasSeenPaywall = true
    }

    func setAuthenticated(_ value: Bool) {
        isAuthenticated = value
    }

    func setSubscribed(_ value: Bool) {
        isSubscribed = value
    }
}
