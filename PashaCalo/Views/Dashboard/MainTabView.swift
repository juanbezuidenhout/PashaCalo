import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var showFoodLog: Bool = false
    @State private var showLoggedToast: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("AppBackground").ignoresSafeArea()

            Group {
                switch selectedTab {
                case 0:
                    DashboardView()
                case 1:
                    ProgressView()
                case 3:
                    GroupsView()
                case 4:
                    PlaceholderTabView(
                        iconName: "person.fill",
                        title: "プロフィール",
                        subtitle: "アカウントと目標設定を管理します"
                    )
                default:
                    DashboardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar

            toastLayer
        }
        .sheet(isPresented: $showFoodLog) {
            FoodLogView(onLogged: presentLoggedToast)
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(icon: "house.fill", title: "ホーム", index: 0)
            tabItem(icon: "chart.line.uptrend.xyaxis", title: "進捗", index: 1)
            centerButton
            tabItem(icon: "person.2.fill", title: "グループ", index: 3)
            tabItem(icon: "person.fill", title: "プロフィール", index: 4)
        }
        .frame(height: 64)
        .background(
            Color("CardBackground")
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabItem(icon: String, title: String, index: Int) -> some View {
        let isActive = selectedTab == index
        return Button {
            selectedTab = index
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(title)
                    .font(.custom("NotoSansJP-Regular", size: 10))
            }
            .foregroundStyle(isActive ? Color("AccentBlack") : Color("TextTertiary"))
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var centerButton: some View {
        Button {
            showFoodLog = true
        } label: {
            ZStack {
                Circle()
                    .fill(Color("AccentBlack"))
                    .frame(width: 60, height: 60)
                    .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)

                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .offset(y: -16)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Toast

    private var toastLayer: some View {
        VStack {
            Spacer()
            if showLoggedToast {
                Text("記録しました")
                    .font(.custom("NotoSansJP-SemiBold", size: 14))
                    .foregroundStyle(Color("AccentBlack"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color("CardBackground"))
                    )
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
                    .padding(.bottom, 96)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showLoggedToast)
    }

    private func presentLoggedToast() {
        showLoggedToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showLoggedToast = false
        }
    }
}

private struct PlaceholderTabView: View {
    let iconName: String
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(Color("TextTertiary"))

                Text(title)
                    .font(.custom("NotoSansJP-Bold", size: 22))
                    .foregroundStyle(Color("AccentBlack"))

                Text(subtitle)
                    .font(.custom("NotoSansJP-Regular", size: 14))
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    MainTabView()
}
