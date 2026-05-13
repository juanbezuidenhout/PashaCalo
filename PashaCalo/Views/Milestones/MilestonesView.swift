import SwiftUI

struct MilestonesView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private let flameOrange = Color(red: 0xFF / 255, green: 0x95 / 255, blue: 0x00 / 255)
    private let gold = Color(red: 0xFF / 255, green: 0xD7 / 255, blue: 0x00 / 255)

    private var streakDays: Int {
        appState.userProfile?.streakDays ?? 0
    }

    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    topBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    streakCard
                        .padding(.horizontal, 16)

                    achievementsHeader
                        .padding(.top, 4)

                    badgesGrid
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color("AccentBlack"))
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text("実績")
                .font(.custom("NotoSansJP-Bold", size: 20))
                .foregroundStyle(Color("AccentBlack"))

            Spacer()

            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 20))
                .foregroundStyle(Color("TextSecondary"))
                .frame(width: 32, height: 32)
        }
    }

    // MARK: - Streak card

    private var streakCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundStyle(flameOrange)

            Text("\(streakDays)")
                .font(.custom("NotoSansJP-Bold", size: 56))
                .foregroundStyle(Color("AccentBlack"))

            Text("日連続")
                .font(.custom("NotoSansJP-Regular", size: 18))
                .foregroundStyle(Color("TextSecondary"))

            Text("今日も記録して連続記録を伸ばしましょう")
                .font(.custom("NotoSansJP-Regular", size: 14))
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // MARK: - Achievements section

    private var achievementsHeader: some View {
        Text("実績")
            .font(.custom("NotoSansJP-SemiBold", size: 17))
            .foregroundStyle(Color("AccentBlack"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
    }

    private var badgesGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(badges) { badge in
                badgeCell(for: badge)
            }
        }
        .padding(.horizontal, 16)
    }

    private func badgeCell(for badge: MilestoneBadge) -> some View {
        let isUnlocked = badge.isUnlocked(streakDays: streakDays)
        let contentColor = isUnlocked ? Color("AccentBlack") : Color("TextTertiary")

        return VStack(spacing: 6) {
            Image(systemName: badge.iconName)
                .font(.system(size: 28))
                .foregroundStyle(contentColor)

            Text(badge.label)
                .font(.custom("NotoSansJP-Regular", size: 11))
                .foregroundStyle(contentColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("CardBackground").opacity(isUnlocked ? 1.0 : 0.6))
        )
        .shadow(
            color: isUnlocked
                ? gold.opacity(0.3)
                : .black.opacity(0.05),
            radius: isUnlocked ? 6 : 4,
            x: 0,
            y: 2
        )
    }

    // MARK: - Badge data

    private var badges: [MilestoneBadge] {
        [
            MilestoneBadge(iconName: "flame.fill", label: "1日連続", unlockCondition: .streak(1)),
            MilestoneBadge(iconName: "flame.fill", label: "3日連続", unlockCondition: .streak(3)),
            MilestoneBadge(iconName: "flame.fill", label: "7日連続", unlockCondition: .streak(7)),
            MilestoneBadge(iconName: "flame.fill", label: "30日連続", unlockCondition: .streak(30)),
            MilestoneBadge(iconName: "fork.knife", label: "初めての記録", unlockCondition: .alwaysLocked),
            MilestoneBadge(iconName: "checkmark.seal.fill", label: "目標達成", unlockCondition: .alwaysLocked),
            MilestoneBadge(iconName: "star.fill", label: "7日間完璧", unlockCondition: .alwaysLocked),
            MilestoneBadge(iconName: "chart.line.uptrend.xyaxis", label: "体重マイナス1kg", unlockCondition: .alwaysLocked),
            MilestoneBadge(iconName: "person.2.fill", label: "友達を招待", unlockCondition: .alwaysLocked)
        ]
    }
}

// MARK: - Badge model

private struct MilestoneBadge: Identifiable {
    enum UnlockCondition {
        case streak(Int)
        case alwaysLocked
    }

    let id = UUID()
    let iconName: String
    let label: String
    let unlockCondition: UnlockCondition

    func isUnlocked(streakDays: Int) -> Bool {
        switch unlockCondition {
        case .streak(let threshold):
            return streakDays >= threshold
        case .alwaysLocked:
            return false
        }
    }
}

#Preview {
    NavigationStack {
        MilestonesView()
            .environmentObject(AppState())
    }
}
