import SwiftUI

struct FoodLogView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                VStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color("TextTertiary"))

                    Text("食事を記録")
                        .font(.custom("NotoSansJP-Bold", size: 22))
                        .foregroundStyle(Color("AccentBlack"))

                    Text("写真を撮影して栄養を自動計算します")
                        .font(.custom("NotoSansJP-Regular", size: 14))
                        .foregroundStyle(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color("AccentBlack"))
                    }
                }
            }
        }
    }
}

#Preview {
    FoodLogView()
}
