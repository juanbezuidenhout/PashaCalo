import SwiftUI

struct OnboardingSelectionCard<Content: View>: View {
    let isSelected: Bool
    var height: CGFloat = 64
    var cornerRadius: CGFloat = 14
    let action: () -> Void
    @ViewBuilder var content: (Bool) -> Content

    @State private var bump: Bool = false

    var body: some View {
        Button {
            triggerBump()
            action()
        } label: {
            content(isSelected)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .padding(.horizontal, 18)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(isSelected ? Color("AccentBlack") : Color("CardBackground"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color("BorderLight"), lineWidth: isSelected ? 0 : 1)
                )
                .scaleEffect(bump ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }

    private func triggerBump() {
        withAnimation(.spring(response: 0.22, dampingFraction: 0.55)) {
            bump = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.6)) {
                bump = false
            }
        }
    }
}
