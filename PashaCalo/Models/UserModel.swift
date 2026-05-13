import Foundation

struct UserProfile: Codable {
    var id: String                  // Supabase user UUID
    var email: String?
    var displayName: String?
    var goal: UserGoal
    var gender: Gender
    var age: Int
    var weightKg: Double
    var heightCm: Double
    var targetWeightKg: Double
    var activityLevel: ActivityLevel
    var dailyCalorieTarget: Int
    var dailyProteinTarget: Int
    var dailyCarbTarget: Int
    var dailyFatTarget: Int
    var createdAt: Date
    var isPremium: Bool
    var streakDays: Int
    var subscriptionTier: SubscriptionTier
    var trialEndDate: Date?

    init(id: String, email: String? = nil) {
        self.id = id
        self.email = email
        self.displayName = nil
        self.goal = .loseWeight
        self.gender = .notSpecified
        self.age = 25
        self.weightKg = 60.0
        self.heightCm = 165.0
        self.targetWeightKg = 55.0
        self.activityLevel = .moderate
        self.dailyCalorieTarget = 1800
        self.dailyProteinTarget = 120
        self.dailyCarbTarget = 200
        self.dailyFatTarget = 60
        self.createdAt = Date()
        self.isPremium = false
        self.streakDays = 0
        self.subscriptionTier = .free
        self.trialEndDate = nil
    }
}

// MARK: - Subscription Tiers (RevenueCat product IDs)

enum SubscriptionTier: String, Codable {
    case free = "free"
    case weekly = "weekly"
    case monthly = "monthly"
    case annual = "annual"

    var isActive: Bool { self != .free }

    // RevenueCat product identifiers — update these in App Store Connect
    var productId: String {
        switch self {
        case .free: return ""
        case .weekly: return "pashacalo_weekly_599"
        case .monthly: return "pashacalo_monthly_1499"
        case .annual: return "pashacalo_annual_7999"
        }
    }

    var japanesePrice: String {
        switch self {
        case .free: return "無料"
        case .weekly: return "¥599/週"
        case .monthly: return "¥1,499/月"
        case .annual: return "¥7,999/年"
        }
    }

    var japaneseLabel: String {
        switch self {
        case .free: return "フリープラン"
        case .weekly: return "週間プラン"
        case .monthly: return "月間プラン"
        case .annual: return "年間プラン（最もお得）"
        }
    }

    var savingsLabel: String? {
        switch self {
        case .annual: return "月払いより57%お得"
        case .weekly: return nil
        case .monthly: return nil
        case .free: return nil
        }
    }
}
