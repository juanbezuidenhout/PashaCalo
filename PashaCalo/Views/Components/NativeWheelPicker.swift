import SwiftUI
import UIKit

/// A thin SwiftUI wrapper around `UIPickerView` so we get the genuine
/// native iOS wheel feel (haptics, momentum, snap, perspective fade) while
/// matching Cal AI's pill-highlight design.
///
/// The default selection bars are removed so a custom `Capsule` can be
/// layered behind the picker in SwiftUI.
struct NativeWheelPicker: UIViewRepresentable {
    @Binding var selection: Int
    let range: ClosedRange<Int>
    let unit: String

    var values: [Int] { Array(range) }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> IndicatorlessPickerView {
        let picker = IndicatorlessPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        picker.backgroundColor = .clear
        picker.setContentHuggingPriority(.defaultLow, for: .horizontal)
        picker.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        if let idx = values.firstIndex(of: clampedSelection) {
            picker.selectRow(idx, inComponent: 0, animated: false)
        }
        return picker
    }

    func updateUIView(_ uiView: IndicatorlessPickerView, context: Context) {
        context.coordinator.parent = self

        if let idx = values.firstIndex(of: clampedSelection),
           uiView.selectedRow(inComponent: 0) != idx {
            uiView.selectRow(idx, inComponent: 0, animated: false)
        }
    }

    private var clampedSelection: Int {
        min(max(selection, range.lowerBound), range.upperBound)
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: NativeWheelPicker

        init(_ parent: NativeWheelPicker) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.values.count
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            40
        }

        func pickerView(
            _ pickerView: UIPickerView,
            viewForRow row: Int,
            forComponent component: Int,
            reusing view: UIView?
        ) -> UIView {
            let container = view ?? UIView()
            container.subviews.forEach { $0.removeFromSuperview() }
            container.backgroundColor = .clear

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.textColor = .label
            label.font = .systemFont(ofSize: 22, weight: .regular)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.8

            let value = parent.values[row]
            label.text = "\(value) \(parent.unit)"

            container.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                label.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 8),
                label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -8)
            ])
            return container
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let newValue = parent.values[row]
            if parent.selection != newValue {
                parent.selection = newValue
            }
        }
    }
}

/// `UIPickerView` subclass that hides the default thin gray selection
/// indicator bars after every layout pass. Doing this from `layoutSubviews`
/// (rather than from `updateUIView`) avoids a race where the bars don't yet
/// exist or all subviews have zero bounds, which previously caused the entire
/// picker to be hidden on first render.
final class IndicatorlessPickerView: UIPickerView {
    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews
        where subview.bounds.height > 0 && subview.bounds.height < 2 {
            subview.backgroundColor = .clear
            subview.isHidden = true
        }
    }
}

#Preview {
    StatefulPreviewWrapper(168) { value in
        NativeWheelPicker(selection: value, range: 100...250, unit: "cm")
            .frame(height: 220)
            .padding()
    }
}

/// Lightweight helper to drive a `@State` binding inside `#Preview`.
private struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initial)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
