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
}
