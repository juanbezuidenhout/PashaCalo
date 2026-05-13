import Foundation

struct FoodItem: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var kcal: Int
    var protein: Double
    var carbs: Double
    var fat: Double

    init(
        id: UUID = UUID(),
        name: String,
        kcal: Int,
        protein: Double,
        carbs: Double,
        fat: Double
    ) {
        self.id = id
        self.name = name
        self.kcal = kcal
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }
}
