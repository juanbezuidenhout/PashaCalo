import SwiftUI
import Charts

struct OnboardingGraphView: View {
    let onNext: () -> Void

    private struct WeightPoint: Identifiable {
        let id = UUID()
        let month: Int
        let weight: Double
        let series: String
    }

    private let generalDiet: [WeightPoint] = [
        .init(month: 1, weight: 70.0, series: "一般的なダイエット"),
        .init(month: 2, weight: 68.5, series: "一般的なダイエット"),
        .init(month: 3, weight: 69.8, series: "一般的なダイエット"),
        .init(month: 4, weight: 68.0, series: "一般的なダイエット"),
        .init(month: 5, weight: 69.6, series: "一般的なダイエット"),
        .init(month: 6, weight: 69.2, series: "一般的なダイエット")
    ]

    private let pashaCalo: [WeightPoint] = [
        .init(month: 1, weight: 70.0, series: "パシャカロ"),
        .init(month: 2, weight: 68.6, series: "パシャカロ"),
        .init(month: 3, weight: 67.0, series: "パシャカロ"),
        .init(month: 4, weight: 65.5, series: "パシャカロ"),
        .init(month: 5, weight: 64.1, series: "パシャカロ"),
        .init(month: 6, weight: 62.8, series: "パシャカロ")
    ]

    private let generalDietColor = Color.red
    private var pashaCaloColor: Color { Color("AccentBlack") }

    private let xAxisLabels: [Int: String] = [
        1: "1ヶ月目",
        2: "2ヶ月目",
        3: "3ヶ月目",
        4: "4ヶ月目",
        5: "5ヶ月目",
        6: "6ヶ月目"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("継続すれば、必ず結果が出ます")
                .font(.custom("NotoSansJP-Bold", size: 26))
                .foregroundStyle(Color("TextPrimary"))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 28)

            chartCard

            Text("食習慣を記録して、長期的な変化を実感しましょう")
                .font(.custom("NotoSansJP-Regular", size: 14))
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Spacer()

            PrimaryButton(title: "次へ") {
                onNext()
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("体重 (kg)")
                .font(.custom("NotoSansJP-Regular", size: 11))
                .foregroundStyle(Color("TextSecondary"))

            chart
                .frame(height: 220)

            legend
                .padding(.top, 4)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    @ViewBuilder
    private var chart: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(generalDiet) { point in
                    AreaMark(
                        x: .value("Month", point.month),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(generalDietColor.opacity(0.3))
                    .interpolationMethod(.catmullRom)
                }

                ForEach(pashaCalo) { point in
                    LineMark(
                        x: .value("Month", point.month),
                        y: .value("Weight", point.weight)
                    )
                    .foregroundStyle(pashaCaloColor)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis {
                AxisMarks(values: Array(1...6)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let month = value.as(Int.self), let label = xAxisLabels[month] {
                            Text(label)
                                .font(.custom("NotoSansJP-Regular", size: 10))
                                .foregroundStyle(Color("TextSecondary"))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
        } else {
            Text("Chart requires iOS 16+")
                .font(.custom("NotoSansJP-Regular", size: 14))
                .foregroundStyle(Color("TextSecondary"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var legend: some View {
        HStack(spacing: 18) {
            legendItem(color: generalDietColor.opacity(0.5), label: "一般的なダイエット")
            legendItem(color: pashaCaloColor, label: "パシャカロ")
            Spacer()
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.custom("NotoSansJP-Regular", size: 12))
                .foregroundStyle(Color("TextSecondary"))
        }
    }
}

#Preview {
    OnboardingGraphView(onNext: {})
        .background(Color("AppBackground"))
}
