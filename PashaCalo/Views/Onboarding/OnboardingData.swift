import Foundation
import SwiftUI

@MainActor
final class OnboardingData: ObservableObject {
    @Published var sex: String = ""
    @Published var activityLevel: String = ""
    @Published var dateOfBirth: Date = {
        var components = DateComponents()
        components.year = 2000
        components.month = 1
        components.day = 1
        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }()
    @Published var heightCm: Double = 0
    @Published var weightKg: Double = 0
    @Published var goalWeightKg: Double = 0
    @Published var discoverySource: String = ""
    @Published var hasTriedOtherApps: Bool? = nil
}
