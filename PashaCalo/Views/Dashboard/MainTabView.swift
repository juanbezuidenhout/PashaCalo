import SwiftUI

struct MainTabView: View {
    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 16) {
                Text("ホーム")
                    .font(.custom("NotoSansJP-Bold", size: 28))
                    .foregroundStyle(Color("TextPrimary"))

                Text("今日の食事")
                    .font(.custom("NotoSansJP-Regular", size: 15))
                    .foregroundStyle(Color("TextSecondary"))
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 18, x: 0, y: 10)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    MainTabView()
}
