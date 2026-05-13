import Foundation

struct FoodEntry: Codable, Identifiable, Equatable {
    var id: UUID
    var userID: UUID
    var items: [FoodItem]
    var mealType: String
    var totalKcal: Int
    var loggedAt: Date

    init(
        id: UUID = UUID(),
        userID: UUID,
        items: [FoodItem],
        mealType: String,
        totalKcal: Int,
        loggedAt: Date = Date()
    ) {
        self.id = id
        self.userID = userID
        self.items = items
        self.mealType = mealType
        self.totalKcal = totalKcal
        self.loggedAt = loggedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case items
        case mealType = "meal_type"
        case totalKcal = "total_kcal"
        case loggedAt = "logged_at"
    }
}
