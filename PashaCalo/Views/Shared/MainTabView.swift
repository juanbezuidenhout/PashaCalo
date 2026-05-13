import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var showCamera: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(0)

                // Camera tab — handled via sheet, not a real tab
                Color.clear
                    .tag(1)

                HistoryView()
                    .tag(2)

                SettingsView()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom tab bar
            CustomTabBar(selectedTab: $selectedTab, onCameraTap: {
                showCamera = true
            })
        }
        .sheet(isPresented: $showCamera) {
            CameraView()
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let onCameraTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(icon: "house.fill", label: "ホーム", isSelected: selectedTab == 0) {
                selectedTab = 0
            }

            TabBarItem(icon: "chart.bar.fill", label: "履歴", isSelected: selectedTab == 2) {
                selectedTab = 2
            }

            // Centre camera button
            Button(action: onCameraTap) {
                ZStack {
                    Circle()
                        .fill(Color("AccentGreen"))
                        .frame(width: 60, height: 60)
                        .shadow(color: Color("AccentGreen").opacity(0.4), radius: 8, x: 0, y: 4)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -16)
            .frame(maxWidth: .infinity)

            TabBarItem(icon: "gearshape.fill", label: "設定", isSelected: selectedTab == 3) {
                selectedTab = 3
            }

            // Placeholder to balance layout
            Color.clear.frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            Color("BackgroundCream")
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
        )
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color("AccentGreen") : Color("TextSecondary"))

                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? Color("AccentGreen") : Color("TextSecondary"))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
