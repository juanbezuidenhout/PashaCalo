import SwiftUI
import Charts

struct OnboardingGraphView: View {
    let onNext: () -> Void

    private struct WeightPoint: Identifiable {
        let id = UUID()
        let month: Double
        let weight: Double
    }

    // パシャカロ: smooth, sustained drop from start to end
    private let pashaCalo: [WeightPoint] = [
        .init(month: 1.0, weight: 70.0),
        .init(month: 1.6, weight: 69.0),
        .init(month: 2.2, weight: 67.2),
        .init(month: 2.8, weight: 64.6),
        .init(month: 3.5, weight: 61.2),
        .init(month: 4.2, weight: 58.0),
        .init(month: 4.9, weight: 56.0),
        .init(month: 5.5, weight: 55.2),
        .init(month: 6.0, weight: 55.0)
    ]

    // 記録なし: dips slightly, then rebounds above the starting weight
    private let noTracking: [WeightPoint] = [
        .init(month: 1.0, weight: 70.0),
        .init(month: 1.6, weight: 68.6),
        .init(month: 2.3, weight: 66.8),
        .init(month: 3.0, weight: 65.6),
        .init(month: 3.6, weight: 65.4),
        .init(month: 4.2, weight: 66.8),
        .init(month: 4.8, weight: 70.2),
        .init(month: 5.4, weight: 74.0),
        .init(month: 6.0, weight: 76.5)
    ]

    private let yMin: Double = 50.0
    private let yMax: Double = 82.0
    private let baselineWeight: Double = 65.0

    private var pashaCaloColor: Color { Color("AccentBlack") }
    private let noTrackingColor = Color(red: 0.97, green: 0.42, blue: 0.45)

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("続けるほど、変化が見えてくる")
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
        VStack(alignment: .leading, spacing: 10) {
            Text("体重")
                .font(.custom("NotoSansJP-Bold", size: 20))
                .foregroundStyle(Color("TextPrimary"))
                .padding(.leading, 2)
                .padding(.top, 4)

            chart
                .frame(height: 230)
                .padding(.top, 2)

            HStack {
                Text("1ヶ月目")
                Spacer()
                Text("6ヶ月目")
            }
            .font(.custom("NotoSansJP-Regular", size: 13))
            .foregroundStyle(Color("TextSecondary"))
            .padding(.horizontal, 2)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color("CardBackground"))
        )
    }

    @ViewBuilder
    private var chart: some View {
        if #available(iOS 16.0, *) {
            Chart {
                ForEach(noTracking) { point in
                    AreaMark(
                        x: .value("Month", point.month),
                        yStart: .value("Baseline", baselineWeight),
                        yEnd: .value("Weight", max(point.weight, baselineWeight))
                    )
                    .foregroundStyle(
                        LinearGradient(
                            stops: [
                                .init(color: noTrackingColor.opacity(0.0), location: 0.0),
                                .init(color: noTrackingColor.opacity(0.08), location: 0.45),
                                .init(color: noTrackingColor.opacity(0.32), location: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }

                RuleMark(y: .value("Baseline", baselineWeight))
                    .foregroundStyle(Color("TextSecondary").opacity(0.28))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 4]))

                ForEach(noTracking) { point in
                    LineMark(
                        x: .value("Month", point.month),
                        y: .value("Weight", point.weight),
                        series: .value("Series", "noTracking")
                    )
                    .foregroundStyle(noTrackingColor)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.catmullRom)
                }

                ForEach(pashaCalo) { point in
                    LineMark(
                        x: .value("Month", point.month),
                        y: .value("Weight", point.weight),
                        series: .value("Series", "pashaCalo")
                    )
                    .foregroundStyle(pashaCaloColor)
                    .lineStyle(StrokeStyle(lineWidth: 3.2, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.catmullRom)
                }

                PointMark(
                    x: .value("Month", 1.0),
                    y: .value("Weight", 70.0)
                )
                .symbol {
                    endpointDot
                }

                PointMark(
                    x: .value("Month", 6.0),
                    y: .value("Weight", 55.0)
                )
                .symbol {
                    endpointDot
                }

                PointMark(
                    x: .value("Anchor", 1.5),
                    y: .value("Anchor", baselineWeight)
                )
                .symbolSize(0)
                .annotation(position: .overlay, alignment: .leading, spacing: 0) {
                    brandPill
                        .padding(.leading, 2)
                }

                PointMark(
                    x: .value("Anchor", 5.5),
                    y: .value("Anchor", 73.6)
                )
                .symbolSize(0)
                .annotation(position: .top, alignment: .trailing, spacing: 2) {
                    Text("記録なし")
                        .font(.custom("NotoSansJP-Bold", size: 12))
                        .foregroundStyle(noTrackingColor)
                        .padding(.trailing, 4)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartXScale(domain: 1.0...6.0)
            .chartYScale(domain: yMin...yMax)
            .chartPlotStyle { plot in
                plot.padding(.top, 8)
                    .padding(.bottom, 4)
            }
        } else {
            Text("Chart requires iOS 16+")
                .font(.custom("NotoSansJP-Regular", size: 14))
                .foregroundStyle(Color("TextSecondary"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var endpointDot: some View {
        Circle()
            .fill(Color("CardBackground"))
            .frame(width: 13, height: 13)
            .overlay(
                Circle()
                    .stroke(Color("TextPrimary"), lineWidth: 2)
            )
    }

    private var brandPill: some View {
        HStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color("TextPrimary"))

                Text("パシャカロ")
                    .font(.custom("NotoSansJP-Bold", size: 12))
                    .foregroundStyle(Color("TextPrimary"))
            }

            Text("体重")
                .font(.custom("NotoSansJP-Bold", size: 11))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color("AccentBlack"))
                )
        }
    }
}

#Preview {
    OnboardingGraphView(onNext: {})
        .background(Color("AppBackground"))
}
