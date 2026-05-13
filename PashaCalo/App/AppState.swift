import SwiftUI
import Combine

/// Central app state — drives navigation between onboarding, paywall, and main app
final class AppState: ObservableObject {

    // MARK: - Navigation State
    @Published var hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @Published var hasSeenPaywall: Bool = UserDefaults.standard.bool(forKey: "hasSeenPaywall")
    @Published var isSubscribed: Bool = false

    enum AppScreen {
        case onboarding
        case paywall
        case main
    }

    var currentScreen: AppScreen {
        if !hasCompletedOnboarding { return .onboarding }
        if !hasSeenPaywall && !isSubscribed { return .paywall }
        return .main
    }

    // MARK: - User Profile (collected during onboarding)
    @Published var userGoal: UserGoal = .loseWeight
    @Published var userGender: Gender = .notSpecified
    @Published var userAge: Int = 25
    @Published var userWeightKg: Double = 60.0
    @Published var userHeightCm: Double = 165.0
    @Published var targetWeightKg: Double = 55.0
    @Published var activityLevel: ActivityLevel = .moderate

    // MARK: - Daily Targets (computed after onboarding)
    @Published var dailyCalorieTarget: Int = 1800
    @Published var dailyProteinTarget: Int = 120
    @Published var dailyCarbTarget: Int = 200
    @Published var dailyFatTarget: Int = 60

    // MARK: - Completion Handlers
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        computeDailyTargets()
    }

    func completePaywall() {
        hasSeenPaywall = true
        UserDefaults.standard.set(true, forKey: "hasSeenPaywall")
    }

    func setSubscribed(_ subscribed: Bool) {
        isSubscribed = subscribed
        if subscribed { completePaywall() }
    }

    // MARK: - Calorie Target Computation (Mifflin-St Jeor)
    func computeDailyTargets() {
        let bmr: Double
        switch userGender {
        case .male:
            bmr = (10 * userWeightKg) + (6.25 * userHeightCm) - (5 * Double(userAge)) + 5
        case .female:
            bmr = (10 * userWeightKg) + (6.25 * userHeightCm) - (5 * Double(userAge)) - 161
        case .notSpecified:
            bmr = (10 * userWeightKg) + (6.25 * userHeightCm) - (5 * Double(userAge)) - 78
        }

        let tdee = bmr * activityLevel.multiplier

        switch userGoal {
        case .loseWeight:
            dailyCalorieTarget = max(1200, Int(tdee - 500))
        case .maintainWeight:
            dailyCalorieTarget = Int(tdee)
        case .gainMuscle:
            dailyCalorieTarget = Int(tdee + 300)
        }

        dailyProteinTarget = Int(Double(userWeightKg) * 1.8)
        dailyFatTarget = Int(Double(dailyCalorieTarget) * 0.25 / 9)
        dailyCarbTarget = Int((Double(dailyCalorieTarget) - Double(dailyProteinTarget * 4) - Double(dailyFatTarget * 9)) / 4)
    }
}

// MARK: - Supporting Enums

enum UserGoal: String, CaseIterable, Codable {
    case loseWeight = "lose_weight"
    case maintainWeight = "maintain_weight"
    case gainMuscle = "gain_muscle"

    var japaneseLabel: String {
        switch self {
        case .loseWeight: return "体重を減らしたい"
        case .maintainWeight: return "体重を維持したい"
        case .gainMuscle: return "筋肉をつけたい"
        }
    }

    var icon: String {
        switch self {
        case .loseWeight: return "arrow.down.circle"
        case .maintainWeight: return "equal.circle"
        case .gainMuscle: return "bolt.circle"
        }
    }
}

enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case notSpecified = "not_specified"

    var japaneseLabel: String {
        switch self {
        case .male: return "男性"
        case .female: return "女性"
        case .notSpecified: return "回答しない"
        }
    }
}

enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "sedentary"
    case light = "light"
    case moderate = "moderate"
    case active = "active"
    case veryActive = "very_active"

    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }

    var japaneseLabel: String {
        switch self {
        case .sedentary: return "ほとんど動かない"
        case .light: return "軽い運動（週1〜2回）"
        case .moderate: return "適度な運動（週3〜5回）"
        case .active: return "活発（週6〜7回）"
        case .veryActive: return "非常に活発（毎日ハード）"
        }
    }
}
