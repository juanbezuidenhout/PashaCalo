import SwiftUI

struct PersonalDetailsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    goalWeightCard
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    detailsCard
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("個人情報")
                    .font(.custom("NotoSansJP-Bold", size: 20))
                    .foregroundStyle(Color("AccentBlack"))
            }
        }
    }

    // MARK: - Goal weight card

    private var goalWeightCard: some View {
        HStack {
            Text("目標体重")
                .font(.custom("NotoSansJP-SemiBold", size: 15))
                .foregroundStyle(Color("AccentBlack"))

            Spacer()

            Text(goalWeightText)
                .font(.custom("NotoSansJP-Bold", size: 15))
                .foregroundStyle(Color("AccentBlack"))

            Spacer()

            Button(action: {}) {
                Text("目標を変更")
                    .font(.custom("NotoSansJP-SemiBold", size: 12))
                    .foregroundStyle(Color("AccentBlack"))
                    .padding(.horizontal, 12)
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
        .background(cardBackground)
    }

    // MARK: - Details card

    private var detailsCard: some View {
        VStack(spacing: 0) {
            detailRow(label: "現在の体重", value: currentWeightText)
            divider
            detailRow(label: "身長", value: heightText)
            divider
            detailRow(label: "生年月日", value: birthdayText)
            divider
            detailRow(label: "性別", value: sexText)
            divider
            detailRow(label: "1日の歩数目標", value: "10,000歩")
        }
        .background(cardBackground)
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.custom("NotoSansJP-Regular", size: 15))
                .foregroundStyle(Color("TextSecondary"))
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(value)
                .font(.custom("NotoSansJP-SemiBold", size: 15))
                .foregroundStyle(Color("AccentBlack"))
                .frame(maxWidth: .infinity, alignment: .center)

            Image(systemName: "pencil.fill")
                .font(.system(size: 13))
                .foregroundStyle(Color("TextTertiary"))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .contentShape(Rectangle())
    }

    // MARK: - Helpers

    private var divider: some View {
        Rectangle()
            .fill(Color("BorderLight"))
            .frame(height: 1)
            .padding(.leading, 14)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color("CardBackground"))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: - Values from AppState (with fallbacks)

    private var goalWeightText: String {
        if let goal = appState.userProfile?.goalWeightKg, goal > 0 {
            return "\(formatKg(goal)) kg"
        }
        return "76 kg"
    }

    private var currentWeightText: String {
        if let weight = appState.userProfile?.weightKg, weight > 0 {
            return "\(formatKg(weight)) kg"
        }
        return "67 kg"
    }

    private var heightText: String {
        if let height = appState.userProfile?.heightCm, height > 0 {
            return "\(formatCm(height)) cm"
        }
        return "181 cm"
    }

    private var birthdayText: String {
        if let dob = appState.userProfile?.dateOfBirth,
           dob.timeIntervalSince1970 > 0 {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ja_JP")
            formatter.dateFormat = "yyyy年M月d日"
            return formatter.string(from: dob)
        }
        return "2002年3月31日"
    }

    private var sexText: String {
        if let sex = appState.userProfile?.sex, !sex.isEmpty {
            return sex
        }
        return "男性"
    }

    private func formatKg(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }

    private func formatCm(_ value: Double) -> String {
        return String(format: "%.0f", value)
    }
}

#Preview {
    NavigationView {
        PersonalDetailsView()
            .environmentObject(AppState())
    }
}
