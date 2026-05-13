import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Date header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.todayFormatted)
                                .font(.system(size: 13))
                                .foregroundColor(Color("TextSecondary"))
                            Text("今日の記録")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(Color("TextPrimary"))
                        }
                        Spacer()

                        // Streak badge
                        if viewModel.streakDays > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("\(viewModel.streakDays)日連続")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Calorie ring card
                    CalorieRingCard(
                        consumed: viewModel.todayCalories,
                        target: appState.dailyCalorieTarget
                    )
                    .padding(.horizontal, 20)

                    // Macro bars
                    MacroProgressCard(
                        protein: viewModel.todayProtein,
                        proteinTarget: appState.dailyProteinTarget,
                        carbs: viewModel.todayCarbs,
                        carbsTarget: appState.dailyCarbTarget,
                        fat: viewModel.todayFat,
                        fatTarget: appState.dailyFatTarget
                    )
                    .padding(.horizontal, 20)

                    // Today's meals
                    if !viewModel.todayScans.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("今日の食事")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color("TextPrimary"))
                                .padding(.horizontal, 20)

                            ForEach(viewModel.todayScans) { scan in
                                ScanResultRow(scan: scan)
                                    .padding(.horizontal, 20)
                            }
                        }
                    } else {
                        EmptyMealState()
                            .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top, 16)
            }
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Calorie Ring Card

struct CalorieRingCard: View {
    let consumed: Int
    let target: Int

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(consumed) / Double(target), 1.0)
    }

    var remaining: Int { max(0, target - consumed) }

    var body: some View {
        HStack(spacing: 24) {
            // Ring
            ZStack {
                Circle()
                    .stroke(Color("ProgressBackground"), lineWidth: 12)
                    .frame(width: 110, height: 110)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color("AccentGreen"), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 110, height: 110)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: progress)

                VStack(spacing: 2) {
                    Text("\(consumed)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color("TextPrimary"))
                    Text("kcal")
                        .font(.system(size: 11))
                        .foregroundColor(Color("TextSecondary"))
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                CalorieStat(label: "目標", value: "\(target) kcal")
                CalorieStat(label: "摂取済み", value: "\(consumed) kcal")
                CalorieStat(label: "残り", value: "\(remaining) kcal")
            }

            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

struct CalorieStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color("TextSecondary"))
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))
        }
    }
}

// MARK: - Macro Progress Card

struct MacroProgressCard: View {
    let protein: Double
    let proteinTarget: Int
    let carbs: Double
    let carbsTarget: Int
    let fat: Double
    let fatTarget: Int

    var body: some View {
        VStack(spacing: 14) {
            MacroProgressRow(
                label: "タンパク質",
                current: protein,
                target: Double(proteinTarget),
                color: Color("MacroProtein")
            )
            MacroProgressRow(
                label: "炭水化物",
                current: carbs,
                target: Double(carbsTarget),
                color: Color("MacroCarb")
            )
            MacroProgressRow(
                label: "脂質",
                current: fat,
                target: Double(fatTarget),
                color: Color("MacroFat")
            )
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

struct MacroProgressRow: View {
    let label: String
    let current: Double
    let target: Double
    let color: Color

    var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextSecondary"))
                Spacer()
                Text("\(Int(current))g / \(Int(target))g")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("TextPrimary"))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("ProgressBackground"))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.easeInOut(duration: 0.6), value: progress)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Scan Result Row

struct ScanResultRow: View {
    let scan: ScanResult

    var body: some View {
        HStack(spacing: 12) {
            // Meal type icon
            ZStack {
                Circle()
                    .fill(Color("AccentGreen").opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: scan.mealType.icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color("AccentGreen"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(scan.mealType.japaneseLabel)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))

                Text(scan.foodItems.map { $0.nameJapanese }.joined(separator: "、"))
                    .font(.system(size: 12))
                    .foregroundColor(Color("TextSecondary"))
                    .lineLimit(1)
            }

            Spacer()

            Text("\(scan.totalCalories) kcal")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color("AccentGreen"))
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Empty State

struct EmptyMealState: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 40))
                .foregroundColor(Color("TextTertiary"))

            VStack(spacing: 6) {
                Text("まだ食事が記録されていません")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))

                Text("カメラボタンを押して食事を撮影してください")
                    .font(.system(size: 13))
                    .foregroundColor(Color("TextTertiary"))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.white)
        .cornerRadius(16)
    }
}
