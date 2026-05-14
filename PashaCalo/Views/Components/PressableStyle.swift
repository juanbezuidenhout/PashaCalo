import SwiftUI

/// A premium, iOS-native press feel for SwiftUI `Button`s. Every variant
/// combines two ingredients that are tuned to feel like Cal AI (or
/// better):
///
/// 1. A snappy scale-down on touch-down that springs back on release.
///    Spring response/damping are tuned so the animation is fast enough
///    to feel tactile, but never robotic.
/// 2. A calibrated, low-intensity haptic that fires on touch-down (not
///    release). Firing on touch-down is the single biggest difference
///    between buttons that feel sluggish and buttons that feel like they
///    have weight under the finger.
///
/// Different `Feel` cases tune intensity, scale, and opacity so the
/// feedback matches the visual prominence of the control. For example a
/// big black CTA gets a heavier "medium" thump; a small ✕ dismiss icon
/// gets a soft pat plus a brief dim.
struct PressableStyle: ButtonStyle {
    enum Feel {
        /// Big confirm / next CTAs (`PrimaryButton`, "+" action buttons).
        case primary
        /// Standard tappable rows, secondary action buttons, source cards.
        case secondary
        /// Toggleable selection rows / chips / plan cards. Fires a
        /// selection haptic instead of an impact so picking a value
        /// feels different from triggering an action.
        case selection
        /// Tab-bar items at the bottom of the screen.
        case tab
        /// Tiny nav-bar icon buttons (back arrow, dismiss ✕). These
        /// also briefly dim because the scale alone is too subtle on
        /// a 22pt SF Symbol.
        case navigation
        /// Inline subtle controls (chevron toggles, "?" info buttons,
        /// quiet text links). The lightest possible feedback that's
        /// still noticeable.
        case subtle
    }

    var feel: Feel = .secondary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .opacity(configuration.isPressed ? pressedOpacity : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.66), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                guard isPressed else { return }
                fireHaptic()
            }
    }

    // MARK: - Tuning

    private var pressedScale: CGFloat {
        switch feel {
        case .primary, .secondary, .selection:
            return 0.97
        case .tab:
            return 0.94
        case .navigation:
            return 0.92
        case .subtle:
            return 0.94
        }
    }

    private var pressedOpacity: Double {
        switch feel {
        case .primary, .secondary, .selection:
            return 1.0
        case .tab:
            return 0.75
        case .navigation:
            return 0.6
        case .subtle:
            return 0.7
        }
    }

    private func fireHaptic() {
        switch feel {
        case .primary:
            Haptics.impact(.medium, intensity: 0.85)
        case .secondary:
            Haptics.impact(.light, intensity: 0.7)
        case .selection:
            Haptics.selectionChanged()
        case .tab:
            Haptics.impact(.soft, intensity: 0.55)
        case .navigation:
            Haptics.impact(.light, intensity: 0.55)
        case .subtle:
            Haptics.impact(.soft, intensity: 0.5)
        }
    }
}

// MARK: - Ergonomic call sites

extension ButtonStyle where Self == PressableStyle {
    /// Default secondary feel: `.buttonStyle(.pressable)`
    static var pressable: PressableStyle { PressableStyle() }

    /// Specific feel: `.buttonStyle(.pressable(.primary))`
    static func pressable(_ feel: PressableStyle.Feel) -> PressableStyle {
        PressableStyle(feel: feel)
    }
}
