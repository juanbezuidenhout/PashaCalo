import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.55)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            action()
        } label: {
            Text(title)
                .font(.custom("NotoSansJP-SemiBold", size: 17))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color("AccentBlack"))
                )
                .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : 1.0)
    }
}

#Preview {
    PrimaryButton(title: "はじめる") {}
        .padding(24)
        .background(Color("AppBackground"))
}
