import Foundation

struct UserProfile: Codable, Identifiable {
    var id: UUID
    var sex: String
    var dateOfBirth: Date
    var heightCm: Double
    var weightKg: Double
    var goalWeightKg: Double
    var activityLevel: String
    var dailyKcalTarget: Int
    var dailyProteinTarget: Int
    var dailyCarbTarget: Int
    var dailyFatTarget: Int
    var streakDays: Int

    init(
        id: UUID = UUID(),
        sex: String = "",
        dateOfBirth: Date = Date(),
        heightCm: Double = 0,
        weightKg: Double = 0,
        goalWeightKg: Double = 0,
        activityLevel: String = "",
        dailyKcalTarget: Int = 0,
        dailyProteinTarget: Int = 0,
        dailyCarbTarget: Int = 0,
        dailyFatTarget: Int = 0,
        streakDays: Int = 0
    ) {
        self.id = id
        self.sex = sex
        self.dateOfBirth = dateOfBirth
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.goalWeightKg = goalWeightKg
        self.activityLevel = activityLevel
        self.dailyKcalTarget = dailyKcalTarget
        self.dailyProteinTarget = dailyProteinTarget
        self.dailyCarbTarget = dailyCarbTarget
        self.dailyFatTarget = dailyFatTarget
        self.streakDays = streakDays
    }

    enum CodingKeys: String, CodingKey {
        case id
        case sex
        case dateOfBirth = "date_of_birth"
        case heightCm = "height_cm"
        case weightKg = "weight_kg"
        case goalWeightKg = "goal_weight_kg"
        case activityLevel = "activity_level"
        case dailyKcalTarget = "daily_kcal_target"
        case dailyProteinTarget = "daily_protein_target"
        case dailyCarbTarget = "daily_carb_target"
        case dailyFatTarget = "daily_fat_target"
        case streakDays = "streak_days"
    }
}
