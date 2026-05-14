import SwiftUI

struct GroupsView: View {
    private let groups: [GroupItem] = [
        GroupItem(
            name: "フィットネス＆トレーニング",
            members: "10,980人のメンバー",
            description: "カロリー目標に合わせたトレーニングをシェアしよう"
        ),
        GroupItem(
            name: "カロリー管理はじめました",
            members: "14,834人のメンバー",
            description: "初心者の質問、ヒント、最初の成果をシェアしよう"
        ),
        GroupItem(
            name: "新年の目標チャレンジ",
            members: "1,205人のメンバー",
            description: "目標を宣言して、達成を一緒に祝おう"
        ),
        GroupItem(
            name: "筋肉増量チャレンジ",
            members: "9,457人のメンバー",
            description: "カロリーをしっかり摂って一緒に筋肉をつけよう"
        ),
        GroupItem(
            name: "ダイエット応援グループ",
            members: "13,057人のメンバー",
            description: "記録を続けて、一緒に理想の体型を目指そう"
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar
                        .padding(.top, 16)
                        .padding(.horizontal, 16)

                    subheaderRow
                        .padding(.top, 16)
                        .padding(.horizontal, 16)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(groups) { group in
                                groupCard(group)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Text("グループ")
                .font(.custom("NotoSansJP-Bold", size: 22))
                .foregroundStyle(Color("AccentBlack"))

            Spacer()

            Image(systemName: "bell")
                .font(.system(size: 20))
                .foregroundStyle(Color("TextSecondary"))
        }
    }

    // MARK: - Subheader

    private var subheaderRow: some View {
        HStack {
            Text("グループを探す")
                .font(.custom("NotoSansJP-SemiBold", size: 17))
                .foregroundStyle(Color("AccentBlack"))

            Spacer()

            Button(action: {}) {
                Text("+ プライベートグループ")
                    .font(.custom("NotoSansJP-SemiBold", size: 13))
                    .foregroundStyle(Color("AccentBlack"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color("CardBackground"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color("BorderLight"), lineWidth: 1)
                    )
            }
            .buttonStyle(.pressable(.secondary))
        }
    }

    // MARK: - Group card

    private func groupCard(_ group: GroupItem) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color("AppBackground"))
                    .frame(width: 44, height: 44)

                Image(systemName: "person.2.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color("TextTertiary"))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(group.name)
                    .font(.custom("NotoSansJP-SemiBold", size: 15))
                    .foregroundStyle(Color("AccentBlack"))

                Text(group.members)
                    .font(.custom("NotoSansJP-Regular", size: 12))
                    .foregroundStyle(Color("TextSecondary"))

                Text(group.description)
                    .font(.custom("NotoSansJP-Regular", size: 13))
                    .foregroundStyle(Color("TextSecondary"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)

            Button(action: {}) {
                Text("+ 参加")
                    .font(.custom("NotoSansJP-SemiBold", size: 12))
                    .foregroundStyle(Color("AccentBlack"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color("CardBackground"))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color("BorderLight"), lineWidth: 1)
                    )
            }
            .buttonStyle(.pressable(.secondary))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("CardBackground"))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
    }
}

private struct GroupItem: Identifiable {
    let id = UUID()
    let name: String
    let members: String
    let description: String
}

#Preview {
    GroupsView()
}
