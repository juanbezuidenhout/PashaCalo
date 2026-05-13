import SwiftUI
import AVFoundation

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CameraViewModel()
    @State private var showResult: Bool = false
    @State private var capturedImage: UIImage?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isAnalysing {
                AnalysingView()
            } else if let result = viewModel.scanResult {
                ScanResultView(result: result, onDismiss: {
                    dismiss()
                })
            } else {
                // Camera preview
                CameraPreviewView(session: viewModel.session)
                    .ignoresSafeArea()

                VStack {
                    // Top bar
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                        Spacer()

                        Text("食事を撮影")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Spacer()

                        // Photo library picker
                        Button(action: { viewModel.showPhotoPicker = true }) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                    Spacer()

                    // Meal type selector
                    MealTypeSelectorView(selected: $viewModel.selectedMealType)
                        .padding(.bottom, 24)

                    // Capture button
                    Button(action: { viewModel.capturePhoto() }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 72, height: 72)

                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 4)
                                .frame(width: 84, height: 84)
                        }
                    }
                    .padding(.bottom, 48)
                }
            }
        }
        .sheet(isPresented: $viewModel.showPhotoPicker) {
            // TODO: PHPickerViewController wrapper
        }
        .onAppear { viewModel.startSession() }
        .onDisappear { viewModel.stopSession() }
    }
}

// MARK: - Analysing Overlay

struct AnalysingView: View {
    @State private var dots: Int = 0
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color("AccentGreen")))
                .scaleEffect(1.8)

            Text("AI が分析中" + String(repeating: ".", count: dots))
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
        }
        .onReceive(timer) { _ in
            dots = (dots + 1) % 4
        }
    }
}

// MARK: - Meal Type Selector

struct MealTypeSelectorView: View {
    @Binding var selected: MealType

    var body: some View {
        HStack(spacing: 8) {
            ForEach(MealType.allCases, id: \.self) { type in
                Button(action: { selected = type }) {
                    Text(type.japaneseLabel)
                        .font(.system(size: 13, weight: selected == type ? .semibold : .regular))
                        .foregroundColor(selected == type ? .white : .white.opacity(0.6))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(selected == type ? Color("AccentGreen") : Color.white.opacity(0.15))
                        .cornerRadius(20)
                }
            }
        }
    }
}

// MARK: - Camera Preview (AVFoundation wrapper)

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        context.coordinator.previewLayer = previewLayer
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.previewLayer?.frame = uiView.bounds
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}
