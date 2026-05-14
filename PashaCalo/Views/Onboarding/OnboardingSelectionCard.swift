import SwiftUI

struct OnboardingSelectionCard<Content: View>: View {
    let isSelected: Bool
    var height: CGFloat = 64
    var cornerRadius: CGFloat = 14
    let action: () -> Void
    @ViewBuilder var content: (Bool) -> Content

    var body: some View {
        Button(action: action) {
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
                .animation(.spring(response: 0.32, dampingFraction: 0.78), value: isSelected)
        }
        .buttonStyle(.pressable(.selection))
    }
}
