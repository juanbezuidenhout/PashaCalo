import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState

    @State private var cardOffset: CGFloat = 20
    @State private var cardOpacity: Double = 0

    private let cardWidth: CGFloat = 240

    private func cardHeight(for availableHeight: CGFloat) -> CGFloat {
        let ideal = cardWidth * 19.0 / 9.0
        let cap = max(280, availableHeight * 0.5)
        return min(ideal, cap)
    }

    private func headlineSize(for screenWidth: CGFloat) -> CGFloat {
        screenWidth < 360 ? 26 : (screenWidth < 400 ? 28 : 30)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        languagePill
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                    Spacer(minLength: 12)

                    mockupCard(height: cardHeight(for: proxy.size.height))
                        .offset(y: cardOffset)
                        .opacity(cardOpacity)

                    Spacer(minLength: 20)

                    VStack(spacing: 12) {
                        Text("写真を撮るだけで、\n食事記録が終わる")
                            .font(.custom("NotoSansJP-SemiBold", size: headlineSize(for: proxy.size.width)))
                            .foregroundStyle(Color("AccentBlack"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("カロリーとPFCを自動で記録")
                            .font(.custom("NotoSansJP-Regular", size: 15))
                            .foregroundStyle(Color("TextSecondary"))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 24)

                    PrimaryButton(title: "はじめる") {
                        appState.completeWelcome()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                cardOffset = 0
                cardOpacity = 1
            }
        }
    }

    private var languagePill: some View {
        Text("JP")
            .font(.custom("NotoSansJP-Regular", size: 13))
            .foregroundStyle(Color("AccentBlack"))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(red: 0xF0/255, green: 0xF0/255, blue: 0xF0/255))
            )
    }

    private func mockupCard(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color("AppBackground"))
            .frame(width: cardWidth, height: height)
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            .overlay(
                VStack(alignment: .leading, spacing: 6) {
                    Text("残りkcal")
                        .font(.custom("NotoSansJP-Regular", size: 12))
                        .foregroundStyle(Color("TextSecondary"))

                    Text("2199")
                        .font(.custom("NotoSansJP-Bold", size: 28))
                        .foregroundStyle(Color("AccentBlack"))

                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(red: 0xFF/255, green: 0x6B/255, blue: 0x9D/255))
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(Color(red: 0xFF/255, green: 0x95/255, blue: 0x00/255))
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(Color(red: 0x00/255, green: 0x7A/255, blue: 0xFF/255))
                            .frame(width: 8, height: 8)
                    }
                    .padding(.top, 2)

                    Spacer()
                }
                .padding(20),
                alignment: .topLeading
            )
    }
}

#Preview {
    WelcomeView()
        .environmentObject(AppState())
}
