import SwiftUI

struct ProgressView: View {
    @EnvironmentObject private var appState: AppState

    @State private var selectedWeek: Int = 0
    @State private var showBMIInfo: Bool = false

    private let weekOptions: [String] = ["今週", "先週", "2週前", "3週前"]
    private let timeframes: [String] = ["3日", "7日", "14日", "30日", "90日"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        titleHeader
                            .padding(.top, 16)

                        weekSelector
                            .padding(.top, 16)

                        weeklyEnergyCard
                        consumptionChangeCard
                        bmiCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
            .navigationBarHidden(true)
            .alert("BMIとは", isPresented: $showBMIInfo) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("BMI（体格指数）は体重(kg)を身長(m)の2乗で割った値です。健康的な範囲は18.5〜24.9です。")
            }
        }
    }

    // MARK: - Title

    private var titleHeader: some View {
        Text("進捗")
            .font(.custom("NotoSansJP-Bold", size: 22))
            .foregroundStyle(Color("AccentBlack"))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Week selector

    private var weekSelector: some View {
        HStack(spacing: 8) {
            ForEach(Array(weekOptions.enumerated()), id: \.offset) { index, label in
                weekPill(label: label, index: index)
            }
        }
    }

    private func weekPill(label: String, index: Int) -> some View {
        let isSelected = selectedWeek == index
        return Button {
            selectedWeek = index
        } label: {
            Text(label)
                .font(.custom(isSelected ? "NotoSansJP-SemiBold" : "NotoSansJP-Regular", size: 13))
                .foregroundStyle(isSelected ? Color.white : Color("AccentBlack"))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(isSelected ? Color("AccentBlack") : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color("BorderLight"), lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(.pressable(.selection))
    }

    // MARK: - Card 1: Weekly energy

    private var weeklyEnergyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("週間エネルギー")
                .font(.custom("NotoSansJP-SemiBold", size: 15))
                .foregroundStyle(Color("AccentBlack"))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 10) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color("TextTertiary"))

                Text("食事を記録するとデータが表示されます")
                    .font(.custom("NotoSansJP-Regular", size: 13))
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 120)
        }
        .padding(16)
        .background(cardBackground)
    }

    // MARK: - Card 2: Consumption change

    private var consumptionChangeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("消費変化")
                .font(.custom("NotoSansJP-SemiBold", size: 15))
                .foregroundStyle(Color("AccentBlack"))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                ForEach(Array(timeframes.enumerated()), id: \.offset) { index, label in
                    consumptionRow(label: label)
                    if index < timeframes.count - 1 {
                        Rectangle()
                            .fill(Color("BorderLight"))
                            .frame(height: 1)
                    }
                }
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private func consumptionRow(label: String) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.custom("NotoSansJP-SemiBold", size: 13))
                .foregroundStyle(Color("AccentBlack"))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("準備中")
                .font(.custom("NotoSansJP-Regular", size: 12))
                .foregroundStyle(Color("TextSecondary"))
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Pending")
                .font(.custom("NotoSansJP-Regular", size: 11))
                .foregroundStyle(Color("TextSecondary"))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(red: 0xF0/255, green: 0xF0/255, blue: 0xF0/255))
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 12)
    }

    // MARK: - Card 3: BMI

    private var bmiCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("BMI")
                    .font(.custom("NotoSansJP-SemiBold", size: 15))
                    .foregroundStyle(Color("AccentBlack"))

                Spacer()

                Button {
                    showBMIInfo = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 18))
                        .foregroundStyle(Color("TextSecondary"))
                }
                .buttonStyle(.pressable(.subtle))
            }

            Text(bmiDisplay)
                .font(.custom("NotoSansJP-Bold", size: 36))
                .foregroundStyle(Color("AccentBlack"))
                .frame(maxWidth: .infinity, alignment: .center)

            if let category = bmiCategory {
                Text(category.label)
                    .font(.custom("NotoSansJP-SemiBold", size: 12))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(category.color)
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            bmiBar

            Text("低体重 18.5未満　健康的 18.5〜24.9　過体重 25.0〜29.9　肥満 30.0以上")
                .font(.custom("NotoSansJP-Regular", size: 10))
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .background(cardBackground)
    }

    private var bmiBar: some View {
        GeometryReader { geo in
            let position = bmiBarPosition(for: bmiValue ?? 0)
            let triangleSize: CGFloat = 6
            let barHeight: CGFloat = 8
            let indicatorX = geo.size.width * position

            ZStack(alignment: .topLeading) {
                HStack(spacing: 0) {
                    segmentColor(0)
                    segmentColor(1)
                    segmentColor(2)
                    segmentColor(3)
                }
                .frame(height: barHeight)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .offset(y: triangleSize + 2)

                if bmiValue != nil {
                    DownwardTriangle()
                        .fill(Color("AccentBlack"))
                        .frame(width: triangleSize * 2, height: triangleSize)
                        .offset(x: indicatorX - triangleSize, y: 0)
                        .animation(.easeInOut, value: bmiValue ?? 0)
                }
            }
        }
        .frame(height: 8 + 6 + 2)
    }

    @ViewBuilder
    private func segmentColor(_ index: Int) -> some View {
        switch index {
        case 0:
            Color(red: 0x00/255, green: 0x7A/255, blue: 0xFF/255)
        case 1:
            Color("HealthyGreen")
        case 2:
            Color(red: 0xFF/255, green: 0x95/255, blue: 0x00/255)
        default:
            Color(red: 0xFF/255, green: 0x3B/255, blue: 0x30/255)
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color("CardBackground"))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: - BMI helpers

    private var bmiValue: Double? {
        guard let profile = appState.userProfile,
              profile.heightCm > 0,
              profile.weightKg > 0 else { return nil }
        let heightM = profile.heightCm / 100.0
        return profile.weightKg / (heightM * heightM)
    }

    private var bmiDisplay: String {
        guard let bmi = bmiValue else { return "--" }
        return String(format: "%.1f", bmi)
    }

    private struct BMICategory {
        let label: String
        let color: Color
    }

    private var bmiCategory: BMICategory? {
        guard let bmi = bmiValue else { return nil }
        switch bmi {
        case ..<18.5:
            return BMICategory(
                label: "低体重",
                color: Color(red: 0x00/255, green: 0x7A/255, blue: 0xFF/255)
            )
        case 18.5..<25.0:
            return BMICategory(label: "健康的", color: Color("HealthyGreen"))
        case 25.0..<30.0:
            return BMICategory(
                label: "過体重",
                color: Color(red: 0xFF/255, green: 0x95/255, blue: 0x00/255)
            )
        default:
            return BMICategory(
                label: "肥満",
                color: Color(red: 0xFF/255, green: 0x3B/255, blue: 0x30/255)
            )
        }
    }

    // Map a BMI value to a 0...1 position on the 4-segment bar.
    // The bar is split into four equal-width segments that each represent
    // one of the BMI categories. Within a segment, the position is
    // interpolated linearly between sensible BMI bounds (10–40).
    private func bmiBarPosition(for bmi: Double) -> CGFloat {
        let clamped = min(max(bmi, 10.0), 40.0)
        let segment: Double
        switch clamped {
        case ..<18.5:
            segment = (clamped - 10.0) / (18.5 - 10.0) * 0.25
        case 18.5..<25.0:
            segment = 0.25 + (clamped - 18.5) / (25.0 - 18.5) * 0.25
        case 25.0..<30.0:
            segment = 0.5 + (clamped - 25.0) / (30.0 - 25.0) * 0.25
        default:
            segment = 0.75 + (clamped - 30.0) / (40.0 - 30.0) * 0.25
        }
        return CGFloat(min(max(segment, 0.0), 1.0))
    }
}

// MARK: - Downward-pointing triangle shape

private struct DownwardTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview("Empty") {
    ProgressView()
        .environmentObject(AppState())
}

#Preview("With profile") {
    let state = AppState()
    state.userProfile = UserProfile(
        heightCm: 172,
        weightKg: 68
    )
    return ProgressView()
        .environmentObject(state)
}
