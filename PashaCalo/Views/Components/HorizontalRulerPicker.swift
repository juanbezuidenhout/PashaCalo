import SwiftUI
import UIKit

/// A horizontal ruler-style value picker, modelled on the one Cal AI uses
/// for goal weight. A long strip of tick marks slides horizontally under a
/// fixed split background — white on the left half, light grey on the right
/// half — so the value at the centre of the screen is always the selection.
/// No separate pointer is drawn; the colour boundary IS the indicator.
///
/// - Smooth native momentum scrolling.
/// - Snaps to the nearest `step` when the user lets go.
/// - Fires selection haptics on every whole-unit crossing.
struct HorizontalRulerPicker: UIViewRepresentable {
    @Binding var value: Double
    let range: ClosedRange<Double>
    /// Smallest snap increment (e.g. 0.1 kg).
    var step: Double = 0.1
    /// Horizontal distance between adjacent `step` ticks.
    var pointsPerStep: CGFloat = 8
    /// Tick is drawn major if the value is a whole multiple of this.
    var majorEvery: Double = 1.0
    /// Total height of the ruler control (background + ticks).
    var height: CGFloat = 110

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> RulerHostView {
        let host = RulerHostView()
        host.configure(
            range: range,
            step: step,
            pointsPerStep: pointsPerStep,
            majorEvery: majorEvery
        )
        host.scrollView.delegate = context.coordinator
        host.coordinator = context.coordinator
        context.coordinator.host = host

        DispatchQueue.main.async {
            host.scrollToValue(clampedValue, animated: false)
        }
        return host
    }

    func updateUIView(_ host: RulerHostView, context: Context) {
        context.coordinator.parent = self
        host.configure(
            range: range,
            step: step,
            pointsPerStep: pointsPerStep,
            majorEvery: majorEvery
        )

        if !context.coordinator.isUserScrolling {
            let target = clampedValue
            let currentValue = host.value(forOffsetX: host.scrollView.contentOffset.x)
            if abs(currentValue - target) > step / 2 {
                host.scrollToValue(target, animated: false)
            }
        }
    }

    private var clampedValue: Double {
        min(max(value, range.lowerBound), range.upperBound)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: HorizontalRulerPicker
        weak var host: RulerHostView?
        var isUserScrolling = false
        private var lastReportedWholeUnit: Int = .min
        private let feedback = UISelectionFeedbackGenerator()

        init(_ parent: HorizontalRulerPicker) {
            self.parent = parent
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isUserScrolling = true
            feedback.prepare()
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard let host = host else { return }
            let raw = host.value(forOffsetX: scrollView.contentOffset.x)
            let clamped = min(max(raw, parent.range.lowerBound), parent.range.upperBound)

            if abs(clamped - parent.value) > 0.0001 {
                parent.value = clamped
            }

            if isUserScrolling || scrollView.isDecelerating {
                let whole = Int(clamped.rounded())
                if lastReportedWholeUnit != .min, whole != lastReportedWholeUnit {
                    feedback.selectionChanged()
                    feedback.prepare()
                }
                lastReportedWholeUnit = whole
            }
        }

        func scrollViewWillEndDragging(
            _ scrollView: UIScrollView,
            withVelocity velocity: CGPoint,
            targetContentOffset: UnsafeMutablePointer<CGPoint>
        ) {
            guard let host = host else { return }
            let projectedValue = host.value(forOffsetX: targetContentOffset.pointee.x)
            let snapped = (projectedValue / parent.step).rounded() * parent.step
            let clamped = min(max(snapped, parent.range.lowerBound), parent.range.upperBound)
            targetContentOffset.pointee.x = host.offset(forValue: clamped)
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            isUserScrolling = false
            lastReportedWholeUnit = .min
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                isUserScrolling = false
                lastReportedWholeUnit = .min
            }
        }
    }
}

// MARK: - Host UIView

/// Hosts the scroll view, the split white/grey background, and the tick strip.
final class RulerHostView: UIView {
    let scrollView = UIScrollView()
    let tickStrip = TickStripView()
    private let leftBackground = UIView()
    private let rightBackground = UIView()
    weak var coordinator: HorizontalRulerPicker.Coordinator?

    private var range: ClosedRange<Double> = 0...100
    private var step: Double = 0.1
    private var pointsPerStep: CGFloat = 8

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        clipsToBounds = true

        leftBackground.backgroundColor = UIColor.systemBackground
        rightBackground.backgroundColor = UIColor(white: 0.86, alpha: 1.0)
        addSubview(leftBackground)
        addSubview(rightBackground)

        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.bounces = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        addSubview(scrollView)

        scrollView.addSubview(tickStrip)
    }

    func configure(
        range: ClosedRange<Double>,
        step: Double,
        pointsPerStep: CGFloat,
        majorEvery: Double
    ) {
        let configChanged = self.range != range
            || self.step != step
            || self.pointsPerStep != pointsPerStep
            || tickStrip.majorEvery != majorEvery

        self.range = range
        self.step = step
        self.pointsPerStep = pointsPerStep

        if configChanged {
            tickStrip.range = range
            tickStrip.step = step
            tickStrip.pointsPerStep = pointsPerStep
            tickStrip.majorEvery = majorEvery
            tickStrip.setNeedsDisplay()
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let halfWidth = bounds.width / 2

        leftBackground.frame = CGRect(x: 0, y: 0, width: halfWidth, height: bounds.height)
        rightBackground.frame = CGRect(x: halfWidth, y: 0, width: bounds.width - halfWidth, height: bounds.height)

        scrollView.frame = bounds

        let stepsCount = ((range.upperBound - range.lowerBound) / step).rounded()
        let contentWidth = CGFloat(stepsCount) * pointsPerStep
        tickStrip.frame = CGRect(x: 0, y: 0, width: contentWidth, height: bounds.height)
        scrollView.contentSize = CGSize(width: contentWidth, height: bounds.height)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: halfWidth, bottom: 0, right: halfWidth)
    }

    // MARK: - Coordinate conversion

    func value(forOffsetX offsetX: CGFloat) -> Double {
        let centerX = offsetX + bounds.width / 2
        let stepsFromMin = Double(centerX / pointsPerStep)
        return range.lowerBound + stepsFromMin * step
    }

    func offset(forValue value: Double) -> CGFloat {
        let stepsFromMin = (value - range.lowerBound) / step
        return CGFloat(stepsFromMin) * pointsPerStep - bounds.width / 2
    }

    func scrollToValue(_ value: Double, animated: Bool) {
        guard bounds.width > 0 else { return }
        scrollView.setContentOffset(CGPoint(x: offset(forValue: value), y: 0), animated: animated)
    }
}

// MARK: - Tick strip view

/// Draws every tick mark in a single pass with Core Graphics. Major ticks
/// (whole-unit values) are taller and slightly thicker than minor ticks.
final class TickStripView: UIView {
    var range: ClosedRange<Double> = 0...100
    var step: Double = 0.1
    var pointsPerStep: CGFloat = 8
    var majorEvery: Double = 1.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isOpaque = false
        backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let tickColor = UIColor.label.withAlphaComponent(0.55)
        ctx.setStrokeColor(tickColor.cgColor)
        ctx.setLineCap(.butt)

        let totalSteps = Int(((range.upperBound - range.lowerBound) / step).rounded())
        let firstIndex = max(0, Int(floor(rect.minX / pointsPerStep)) - 1)
        let lastIndex = min(totalSteps, Int(ceil(rect.maxX / pointsPerStep)) + 1)

        let majorH = bounds.height * 0.55
        let minorH = bounds.height * 0.28
        let centerY = bounds.height * 0.55

        for i in firstIndex...lastIndex {
            let value = range.lowerBound + Double(i) * step
            let x = CGFloat(i) * pointsPerStep + 0.5

            let remainder = (value / majorEvery).rounded()
            let isMajor = abs(value - remainder * majorEvery) < step / 2

            let h = isMajor ? majorH : minorH
            let lineWidth: CGFloat = isMajor ? 1.5 : 1.0
            let y0 = centerY - h / 2
            let y1 = y0 + h

            ctx.setLineWidth(lineWidth)
            ctx.move(to: CGPoint(x: x, y: y0))
            ctx.addLine(to: CGPoint(x: x, y: y1))
            ctx.strokePath()
        }
    }
}

#Preview {
    StatefulRulerPreview()
        .padding()
        .background(Color.gray.opacity(0.1))
}

private struct StatefulRulerPreview: View {
    @State private var value: Double = 60

    var body: some View {
        VStack(spacing: 16) {
            Text(String(format: "%.1f kg", value))
                .font(.system(size: 44, weight: .bold))
            HorizontalRulerPicker(
                value: $value,
                range: 30...200
            )
            .frame(height: 110)
        }
    }
}
