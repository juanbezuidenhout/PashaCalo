import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState

    @State private var showDeleteConfirm: Bool = false

    private let gold = Color(red: 0xFF / 255, green: 0xD7 / 255, blue: 0x00 / 255)
    private let appleHealthRed = Color(red: 0xFF / 255, green: 0x2D / 255, blue: 0x55 / 255)
    private let destructiveRed = Color(red: 0xFF / 255, green: 0x3B / 255, blue: 0x30 / 255)

    var body: some View {
        NavigationView {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        title
                            .padding(.top, 16)
                            .padding(.horizontal, 16)

                        userCard
                            .padding(.horizontal, 16)

                        inviteCard
                            .padding(.horizontal, 16)

                        sectionLabel("アカウント")
                        accountCard

                        sectionLabel("目標と記録")
                        goalsCard

                        supportCard
                            .padding(.top, 4)
                    }
                    .padding(.bottom, 120)
                }
            }
            .navigationBarHidden(true)
            .alert(
                "アカウントを削除しますか？",
                isPresented: $showDeleteConfirm
            ) {
                Button("キャンセル", role: .cancel) { }
                Button("削除する", role: .destructive) {
                    appState.setAuthenticated(false)
                    appState.isOnboardingComplete = false
                }
            } message: {
                Text("この操作は取り消せません。すべてのデータが削除されます。")
            }
        }
    }

    // MARK: - Title

    private var title: some View {
        Text("プロフィール")
            .font(.custom("NotoSansJP-Bold", size: 22))
            .foregroundStyle(Color("AccentBlack"))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - User card

    private var userCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color("AppBackground"))
                    .frame(width: 52, height: 52)

                Image(systemName: "person.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(Color("TextTertiary"))

                Image(systemName: "crown.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(gold)
                    .offset(x: 14, y: 14)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("名前を設定する")
                    .font(.custom("NotoSansJP-SemiBold", size: 15))
                    .foregroundStyle(Color("AccentBlack"))

                Text("ユーザー名を設定する")
                    .font(.custom("NotoSansJP-Regular", size: 13))
                    .foregroundStyle(Color("TextSecondary"))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(Color("TextTertiary"))
        }
        .padding(14)
        .background(cardBackground)
    }

    // MARK: - Invite card

    private var inviteCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("友達を招待")
                    .font(.custom("NotoSansJP-SemiBold", size: 15))
                    .foregroundStyle(Color("AccentBlack"))

                Text("友達を紹介して ¥1,000 をもらおう")
                    .font(.custom("NotoSansJP-Regular", size: 13))
                    .foregroundStyle(Color("TextSecondary"))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(Color("TextTertiary"))
        }
        .padding(14)
        .background(cardBackground)
    }

    // MARK: - Section label

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.custom("NotoSansJP-Regular", size: 12))
            .foregroundStyle(Color("TextSecondary"))
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 8)
    }

    // MARK: - Account card

    private var accountCard: some View {
        VStack(spacing: 0) {
            NavigationLink {
                PersonalDetailsView()
            } label: {
                row(iconName: "person.fill", iconColor: Color("AccentBlack"), label: "個人情報", labelColor: Color("AccentBlack"))
            }
            .buttonStyle(.plain)

            divider

            row(iconName: "slider.horizontal.3", iconColor: Color("AccentBlack"), label: "設定", labelColor: Color("AccentBlack"))

            divider

            row(iconName: "globe", iconColor: Color("AccentBlack"), label: "言語", labelColor: Color("AccentBlack"))

            divider

            row(iconName: "person.badge.plus", iconColor: Color("AccentBlack"), label: "ファミリープランにアップグレード", labelColor: Color("AccentBlack"))
        }
        .background(cardBackground)
        .padding(.horizontal, 16)
    }

    // MARK: - Goals & tracking card

    private var goalsCard: some View {
        VStack(spacing: 0) {
            row(iconName: "heart.fill", iconColor: appleHealthRed, label: "Apple Health", labelColor: Color("AccentBlack"))

            divider

            row(iconName: "target", iconColor: Color("AccentBlack"), label: "栄養目標を編集", labelColor: Color("AccentBlack"))
        }
        .background(cardBackground)
        .padding(.horizontal, 16)
    }

    // MARK: - Support card

    private var supportCard: some View {
        VStack(spacing: 0) {
            row(iconName: "questionmark.circle", iconColor: Color("AccentBlack"), label: "サポート", labelColor: Color("AccentBlack"))

            divider

            row(iconName: "doc.text", iconColor: Color("AccentBlack"), label: "プライバシーポリシー", labelColor: Color("AccentBlack"))

            divider

            row(iconName: "doc.plaintext", iconColor: Color("AccentBlack"), label: "利用規約", labelColor: Color("AccentBlack"))

            divider

            Button {
                showDeleteConfirm = true
            } label: {
                row(iconName: "trash", iconColor: destructiveRed, label: "アカウントを削除", labelColor: destructiveRed)
            }
            .buttonStyle(.plain)
        }
        .background(cardBackground)
        .padding(.horizontal, 16)
    }

    // MARK: - Row & helpers

    private func row(
        iconName: String,
        iconColor: Color,
        label: String,
        labelColor: Color
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundStyle(iconColor)
                .frame(width: 24, alignment: .center)

            Text(label)
                .font(.custom("NotoSansJP-SemiBold", size: 15))
                .foregroundStyle(labelColor)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(Color("TextTertiary"))
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .contentShape(Rectangle())
    }

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
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}
