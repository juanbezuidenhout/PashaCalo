import SwiftUI

struct OnboardingDOBView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    @State private var selectedYear: Int = 2000
    @State private var selectedMonth: Int = 1
    @State private var selectedDay: Int = 1

    private let years: [Int] = Array(1925...2020)
    private let months: [Int] = Array(1...12)
    private let days: [Int] = Array(1...31)

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("生年月日を選択してください")
                    .font(.custom("NotoSansJP-Bold", size: 26))
                    .foregroundStyle(Color("TextPrimary"))

                Text("目標カロリーの計算に使用します")
                    .font(.custom("NotoSansJP-Regular", size: 14))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .padding(.top, 28)

            HStack(spacing: 12) {
                wheelColumn(label: "年", picker: yearPicker)
                wheelColumn(label: "月", picker: monthPicker)
                wheelColumn(label: "日", picker: dayPicker)
            }
            .frame(maxWidth: .infinity)

            Spacer()

            PrimaryButton(title: "次へ") {
                commitDate()
                onNext()
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
        .onAppear { syncFromData() }
    }

    private func wheelColumn<Picker: View>(label: String, picker: Picker) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.custom("NotoSansJP-Regular", size: 12))
                .foregroundStyle(Color("TextSecondary"))

            picker
                .frame(height: 180)
                .clipped()
        }
        .frame(maxWidth: .infinity)
    }

    private var yearPicker: some View {
        Picker("年", selection: $selectedYear) {
            ForEach(years, id: \.self) { year in
                Text(String(year))
                    .font(.custom("NotoSansJP-Regular", size: 18))
                    .tag(year)
            }
        }
        .pickerStyle(.wheel)
    }

    private var monthPicker: some View {
        Picker("月", selection: $selectedMonth) {
            ForEach(months, id: \.self) { month in
                Text(String(month))
                    .font(.custom("NotoSansJP-Regular", size: 18))
                    .tag(month)
            }
        }
        .pickerStyle(.wheel)
    }

    private var dayPicker: some View {
        Picker("日", selection: $selectedDay) {
            ForEach(days, id: \.self) { day in
                Text(String(day))
                    .font(.custom("NotoSansJP-Regular", size: 18))
                    .tag(day)
            }
        }
        .pickerStyle(.wheel)
    }

    private func syncFromData() {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: data.dateOfBirth)
        selectedYear = components.year ?? 2000
        selectedMonth = components.month ?? 1
        selectedDay = components.day ?? 1
    }

    private func commitDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = selectedDay
        if let date = Calendar(identifier: .gregorian).date(from: components) {
            data.dateOfBirth = date
        }
    }
}

#Preview {
    OnboardingDOBView(onNext: {})
        .environmentObject(OnboardingData())
        .background(Color("AppBackground"))
}
