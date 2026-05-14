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

    // "lose" | "maintain" | "gain". Empty string means not yet selected.
    @Published var goalDirection: String = ""

    // Only collected when the user picks `maintain` as their goal direction.
    // Stores the stable English keys (see `Barrier`) so analytics stays
    // locale-independent.
    @Published var barriers: Set<String> = []

    // Stable English key from `DietStyle`. Empty string means not yet selected.
    @Published var dietStyle: String = ""

    enum GoalDirection {
        static let lose = "lose"
        static let maintain = "maintain"
        static let gain = "gain"
    }

    enum Barrier {
        static let consistency = "consistency"
        static let eatingHabits = "eating_habits"
        static let support = "support"
        static let busySchedule = "busy_schedule"
        static let mealInspiration = "meal_inspiration"
    }

    enum DietStyle {
        static let classic = "classic"
        static let pescatarian = "pescatarian"
        static let vegetarian = "vegetarian"
        static let vegan = "vegan"
    }
}
