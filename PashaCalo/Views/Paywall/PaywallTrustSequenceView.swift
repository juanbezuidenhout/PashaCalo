import SwiftUI

struct PaywallTrustSequenceView: View {
    @EnvironmentObject private var appState: AppState
    @State private var screen: Int = 0

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            Group {
                switch screen {
                case 0:
                    PaywallScreen1View(onNext: advance)
                        .transition(slideTransition)
                case 1:
                    PaywallScreen2View(onNext: advance)
                        .transition(slideTransition)
                default:
                    PaywallScreen3View()
                        .transition(slideTransition)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: screen)
        }
    }

    private var slideTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    private func advance() {
        screen += 1
    }
}

#Preview {
    PaywallTrustSequenceView()
        .environmentObject(AppState())
}
