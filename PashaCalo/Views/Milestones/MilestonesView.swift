import SwiftUI

struct MilestonesView: View {
    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.orange)

                Text("マイルストーン")
                    .font(.custom("NotoSansJP-Bold", size: 22))
                    .foregroundStyle(Color("AccentBlack"))

                Text("継続日数や達成バッジがここに表示されます")
                    .font(.custom("NotoSansJP-Regular", size: 14))
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MilestonesView()
    }
}
