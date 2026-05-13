import SwiftUI

struct SplashView: View {
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Color("AccentBlack"))

                Text("パシャカロ")
                    .font(.custom("NotoSansJP-Bold", size: 32))
                    .foregroundStyle(Color("AccentBlack"))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onComplete()
            }
        }
    }
}

#Preview {
    SplashView(onComplete: {})
}
