import UIKit

/// Central haptic feedback helper.
///
/// The point of the singleton design is that every generator is created
/// once and kept warm via `prepare()` so the very first tap of every
/// session is instantaneous. Without this priming, iOS lazily spins up
/// the Taptic Engine on first call, which causes the first ~200ms of
/// "click feeling" to be missing — exactly the difference between
/// apps that feel cheap and apps like Cal AI that feel premium.
///
/// Generators are re-prepared immediately after each event so subsequent
/// taps within the same session are also instant.
enum Haptics {
    enum ImpactStyle {
        case soft
        case light
        case medium
        case rigid
    }

    // MARK: - Generators

    private static let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private static let selection = UISelectionFeedbackGenerator()
    private static let notification = UINotificationFeedbackGenerator()

    /// Primes every generator. Call once at app launch (and whenever the
    /// app foregrounds) so the Taptic Engine is already awake for the
    /// first interaction.
    static func warmUp() {
        softImpact.prepare()
        lightImpact.prepare()
        mediumImpact.prepare()
        rigidImpact.prepare()
        selection.prepare()
        notification.prepare()
    }

    // MARK: - Impacts

    /// Fires an impact-style haptic. `intensity` lets us dial back the
    /// strength so the feedback feels subtle and refined rather than the
    /// default jarring full-intensity tap.
    static func impact(_ style: ImpactStyle, intensity: CGFloat = 1.0) {
        let clamped = max(0.0, min(1.0, intensity))
        switch style {
        case .soft:
            softImpact.impactOccurred(intensity: clamped)
            softImpact.prepare()
        case .light:
            lightImpact.impactOccurred(intensity: clamped)
            lightImpact.prepare()
        case .medium:
            mediumImpact.impactOccurred(intensity: clamped)
            mediumImpact.prepare()
        case .rigid:
            rigidImpact.impactOccurred(intensity: clamped)
            rigidImpact.prepare()
        }
    }

    // MARK: - Selection

    /// Use for value-changing interactions (picker scrolls, tab switches,
    /// toggle taps, segmented controls).
    static func selectionChanged() {
        selection.selectionChanged()
        selection.prepare()
    }

    // MARK: - Notifications

    static func success() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }

    static func warning() {
        notification.notificationOccurred(.warning)
        notification.prepare()
    }

    static func error() {
        notification.notificationOccurred(.error)
        notification.prepare()
    }
}
