import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showRemaining: Bool = true
    @State private var todayEntries: [FoodEntry] = []
    @State private var isLoadingEntries: Bool = false

    private let calendar = Calendar.current

    private var streakDays: Int {
        appState.userProfile?.streakDays ?? 0
    }

    private var carouselDates: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (-3...3).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        topBar
                        dateCarousel
                        mainCalorieCard
                        macroPager
                        recentMealsSection
                        healthScoreCard
                        waterCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
            }
            .navigationBarHidden(true)
            .task {
                await loadTodayEntries()
            }
            .refreshable {
                await loadTodayEntries()
            }
        }
    }

    private func loadTodayEntries() async {
        isLoadingEntries = true
        defer { isLoadingEntries = false }
        do {
            let entries = try await SupabaseManager.shared.loadTodayEntries()
            todayEntries = entries
        } catch {
            print("Failed to load today entries: \(error)")
        }
    }

    // MARK: - Section 1: Top bar

    private var topBar: some View {
        HStack {
            Text("パシャカロ")
                .font(.custom("NotoSansJP-Bold", size: 20))
                .foregroundStyle(Color("AccentBlack"))

            Spacer()

            NavigationLink {
                MilestonesView()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.orange)
                    Text("\(streakDays)")
                        .font(.custom("NotoSansJP-SemiBold", size: 13))
                        .foregroundStyle(Color("AccentBlack"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color("CardBackground"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color("BorderLight"), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Section 2: Date carousel

    private var dateCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(carouselDates, id: \.self) { date in
                    dayItem(for: date)
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func dayItem(for date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let day = calendar.component(.day, from: date)
        return VStack(spacing: 6) {
            Text(weekdayJP(for: date))
                .font(.custom("NotoSansJP-Regular", size: 11))
                .foregroundStyle(Color("TextSecondary"))

            ZStack {
                if isToday {
                    Circle()
                        .fill(Color("AccentBlack"))
                        .frame(width: 32, height: 32)
                    Text("\(day)")
                        .font(.custom("NotoSansJP-SemiBold", size: 15))
                        .foregroundStyle(.white)
                } else {
                    Text("\(day)")
                        .font(.custom("NotoSansJP-Regular", size: 15))
                        .foregroundStyle(Color("TextPrimary"))
                        .frame(width: 32, height: 32)
                }
            }
        }
        .frame(width: 40)
    }

    private func weekdayJP(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        let symbols = ["日", "月", "火", "水", "木", "金", "土"]
        return symbols[(weekday - 1) % 7]
    }

    // MARK: - Section 3: Main calorie card

    private var mainCalorieCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("3164")
                    .font(.custom("NotoSansJP-Bold", size: 42))
                    .foregroundStyle(Color("AccentBlack"))

                Button {
                    showRemaining.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Text(showRemaining ? "残りkcal" : "摂取kcal")
                            .font(.custom("NotoSansJP-Regular", size: 14))
                            .foregroundStyle(Color("TextSecondary"))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 11))
                            .foregroundStyle(Color("TextSecondary"))
                    }
                }
                .buttonStyle(.plain)
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color("BorderLight"), lineWidth: 12)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: 0.72)
                    .stroke(
                        Color("AccentBlack"),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "flame.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.orange)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: - Section 4: Macro ring cards pager

    private var macroPager: some View {
        TabView {
            HStack(spacing: 12) {
                MacroRingCard(
                    ringColor: "RingProtein",
                    iconName: "fork.knife",
                    label: "タンパク質",
                    amount: "175g",
                    suffix: "残り"
                )
                MacroRingCard(
                    ringColor: "RingCarbs",
                    iconName: "leaf.fill",
                    label: "炭水化物",
                    amount: "417g",
                    suffix: "残り"
                )
                MacroRingCard(
                    ringColor: "RingFat",
                    iconName: "drop.fill",
                    label: "脂質",
                    amount: "87g",
                    suffix: "残り"
                )
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 24)

            HStack(spacing: 12) {
                MacroRingCard(
                    ringColor: "RingFiber",
                    iconName: "leaf.circle.fill",
                    label: "食物繊維",
                    amount: "38g",
                    suffix: "残り"
                )
                MacroRingCard(
                    ringColor: "RingSugar",
                    iconName: "cube.fill",
                    label: "糖質",
                    amount: "118g",
                    suffix: "残り"
                )
                MacroRingCard(
                    ringColor: "RingSodium",
                    iconName: "circle.grid.2x2.fill",
                    label: "塩分",
                    amount: "2300mg",
                    suffix: "残り"
                )
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 24)

            HStack(spacing: 12) {
                appleHealthCard
                activityCard
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 24)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 110)
    }

    private var appleHealthCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: "heart.fill")
                .font(.system(size: 20))
                .foregroundStyle(.pink)

            Text("Apple Healthを連携")
                .font(.custom("NotoSansJP-SemiBold", size: 13))
                .foregroundStyle(Color("AccentBlack"))

            Text("歩数を記録する")
                .font(.custom("NotoSansJP-Regular", size: 11))
                .foregroundStyle(Color("TextSecondary"))

            Button {
                // Hook up Apple Health connect flow later.
            } label: {
                Text("連携する")
                    .font(.custom("NotoSansJP-SemiBold", size: 11))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(Color("AccentBlack"))
                    )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var activityCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: "figure.walk")
                .font(.system(size: 20))
                .foregroundStyle(Color("AccentBlack"))

            Text("消費カロリー")
                .font(.custom("NotoSansJP-Regular", size: 11))
                .foregroundStyle(Color("TextSecondary"))

            Text("0 kcal")
                .font(.custom("NotoSansJP-SemiBold", size: 13))
                .foregroundStyle(Color("AccentBlack"))

            Text("歩数 0")
                .font(.custom("NotoSansJP-Regular", size: 11))
                .foregroundStyle(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: - Section 5: Recently uploaded

    private var recentMealsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("最近の食事")
                    .font(.custom("NotoSansJP-SemiBold", size: 17))
                    .foregroundStyle(Color("AccentBlack"))
                Spacer()
                Text("すべて見る")
                    .font(.custom("NotoSansJP-Regular", size: 13))
                    .foregroundStyle(Color("TextSecondary"))
            }

            if todayEntries.isEmpty {
                emptyMealsCard
            } else {
                VStack(spacing: 10) {
                    ForEach(todayEntries) { entry in
                        mealEntryRow(entry: entry)
                    }
                }
            }
        }
    }

    private var emptyMealsCard: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color("AppBackground"))
                .frame(width: 80, height: 60)

            Text("＋ボタンで今日の食事を追加しましょう")
                .font(.custom("NotoSansJP-Regular", size: 13))
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    Color("BorderLight"),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                )
        )
    }

    private func mealEntryRow(entry: FoodEntry) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color("AppBackground"))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.system(size: 22))
                        .foregroundStyle(Color("TextSecondary"))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.items.first?.name ?? entry.mealType)
                    .font(.custom("NotoSansJP-SemiBold", size: 15))
                    .foregroundStyle(Color("AccentBlack"))
                    .lineLimit(1)
                Text(mealSubtitle(for: entry))
                    .font(.custom("NotoSansJP-Regular", size: 12))
                    .foregroundStyle(Color("TextSecondary"))
                    .lineLimit(1)
            }

            Spacer()

            Text("\(entry.totalKcal) kcal")
                .font(.custom("NotoSansJP-Bold", size: 15))
                .foregroundStyle(Color("AccentBlack"))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func mealSubtitle(for entry: FoodEntry) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let timeString = timeFormatter.string(from: entry.loggedAt)
        if entry.items.count > 1 {
            return "\(entry.mealType)　\(timeString)　他\(entry.items.count - 1)品"
        }
        return "\(entry.mealType)　\(timeString)"
    }

    // MARK: - Section 6: Health Score card

    private var healthScoreCard: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("健康スコア")
                    .font(.custom("NotoSansJP-SemiBold", size: 15))
                    .foregroundStyle(Color("AccentBlack"))
                Text("食事を記録するとスコアが表示されます")
                    .font(.custom("NotoSansJP-Regular", size: 12))
                    .foregroundStyle(Color("TextSecondary"))
            }
            Spacer()
            Text("N/A")
                .font(.custom("NotoSansJP-Bold", size: 28))
                .foregroundStyle(Color("AccentBlack"))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: - Section 7: Water card

    private var waterCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "drop.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color(red: 0x00/255, green: 0x7A/255, blue: 0xFF/255))

            VStack(alignment: .leading, spacing: 2) {
                Text("水分")
                    .font(.custom("NotoSansJP-SemiBold", size: 14))
                    .foregroundStyle(Color("AccentBlack"))
                Text("0 ml")
                    .font(.custom("NotoSansJP-Regular", size: 12))
                    .foregroundStyle(Color("TextSecondary"))
            }

            Spacer()

            Button {
                // Hook up water logging later.
            } label: {
                Text("水分を記録")
                    .font(.custom("NotoSansJP-SemiBold", size: 12))
                    .foregroundStyle(Color("AccentBlack"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color("CardBackground"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color("BorderLight"), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - MacroRingCard

private struct MacroRingCard: View {
    let ringColor: String
    let iconName: String
    let label: String
    let amount: String
    let suffix: String

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                Circle()
                    .stroke(Color(ringColor), lineWidth: 4)
                    .frame(width: 36, height: 36)
                Image(systemName: iconName)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(ringColor))
            }

            Text(label)
                .font(.custom("NotoSansJP-Regular", size: 11))
                .foregroundStyle(Color("TextSecondary"))

            Text(amount)
                .font(.custom("NotoSansJP-Bold", size: 13))
                .foregroundStyle(Color("AccentBlack"))

            Text(suffix)
                .font(.custom("NotoSansJP-Regular", size: 10))
                .foregroundStyle(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppState())
}
