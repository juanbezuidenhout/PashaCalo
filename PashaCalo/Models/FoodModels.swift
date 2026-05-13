import Foundation

// MARK: - Food Item

struct FoodItem: Identifiable, Codable {
    let id: UUID
    var nameJapanese: String        // e.g. "チーズツナおにぎり"
    var nameEnglish: String?
    var brand: String?              // e.g. "セブンイレブン"
    var source: FoodSource
    var calories: Int               // kcal
    var protein: Double             // grams
    var carbohydrates: Double       // grams
    var fat: Double                 // grams
    var fiber: Double?
    var sodium: Double?             // mg
    var servingSize: String         // e.g. "1個 (105g)"
    var imageURL: String?

    init(
        id: UUID = UUID(),
        nameJapanese: String,
        nameEnglish: String? = nil,
        brand: String? = nil,
        source: FoodSource = .aiEstimate,
        calories: Int,
        protein: Double,
        carbohydrates: Double,
        fat: Double,
        fiber: Double? = nil,
        sodium: Double? = nil,
        servingSize: String = "1食分",
        imageURL: String? = nil
    ) {
        self.id = id
        self.nameJapanese = nameJapanese
        self.nameEnglish = nameEnglish
        self.brand = brand
        self.source = source
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.fiber = fiber
        self.sodium = sodium
        self.servingSize = servingSize
        self.imageURL = imageURL
    }
}

// MARK: - Food Source

enum FoodSource: String, Codable {
    case sevenEleven = "seven_eleven"
    case lawson = "lawson"
    case familyMart = "family_mart"
    case restaurantChain = "restaurant"
    case mextDatabase = "mext"
    case aiEstimate = "ai_estimate"

    var isVerified: Bool { self != .aiEstimate }

    var displayLabel: String {
        switch self {
        case .sevenEleven: return "セブンイレブン 確認済み"
        case .lawson: return "ローソン 確認済み"
        case .familyMart: return "ファミリーマート 確認済み"
        case .restaurantChain: return "レストラン 確認済み"
        case .mextDatabase: return "文部科学省データ"
        case .aiEstimate: return "AI推定値"
        }
    }
}

// MARK: - Scan Result

struct ScanResult: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    var imageData: Data?
    var foodItems: [FoodItem]
    var mealType: MealType
    var notes: String?

    var totalCalories: Int { foodItems.reduce(0) { $0 + $1.calories } }
    var totalProtein: Double { foodItems.reduce(0) { $0 + $1.protein } }
    var totalCarbs: Double { foodItems.reduce(0) { $0 + $1.carbohydrates } }
    var totalFat: Double { foodItems.reduce(0) { $0 + $1.fat } }

    // Viral share copy — changes based on calorie total
    var shareMessageJapanese: String {
        switch totalCalories {
        case 0..<500:
            return "神食事！\(totalCalories)kcalしかなかった"
        case 500..<800:
            return "バランス完璧！\(totalCalories)kcalでした"
        default:
            return "今日はちょっと食べすぎた \(totalCalories)kcal"
        }
    }

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        imageData: Data? = nil,
        foodItems: [FoodItem] = [],
        mealType: MealType = .lunch,
        notes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.imageData = imageData
        self.foodItems = foodItems
        self.mealType = mealType
        self.notes = notes
    }
}

// MARK: - Meal Type

enum MealType: String, Codable, CaseIterable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"

    var japaneseLabel: String {
        switch self {
        case .breakfast: return "朝食"
        case .lunch: return "昼食"
        case .dinner: return "夕食"
        case .snack: return "間食"
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "sunrise"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        case .snack: return "cup.and.saucer"
        }
    }
}

// MARK: - Daily Log

struct DailyLog: Identifiable, Codable {
    let id: UUID
    let date: Date
    var scans: [ScanResult]

    var totalCalories: Int { scans.reduce(0) { $0 + $1.totalCalories } }
    var totalProtein: Double { scans.reduce(0) { $0 + $1.totalProtein } }
    var totalCarbs: Double { scans.reduce(0) { $0 + $1.totalCarbs } }
    var totalFat: Double { scans.reduce(0) { $0 + $1.totalFat } }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }

    init(id: UUID = UUID(), date: Date = Date(), scans: [ScanResult] = []) {
        self.id = id
        self.date = date
        self.scans = scans
    }
}
