import SwiftUI
import UIKit

struct FoodLogView: View {
    @Environment(\.dismiss) private var dismiss

    var onLogged: () -> Void = {}

    @State private var step: Int = 1
    @State private var selectedImage: UIImage? = nil
    @State private var foodItems: [FoodItem] = []

    @State private var showCamera: Bool = false
    @State private var showPhotoPicker: Bool = false

    @State private var dotCount: Int = 1
    @State private var dotTimer: Timer? = nil

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                Group {
                    switch step {
                    case 1:
                        sourceSelection
                    case 2:
                        analysingView
                    case 3:
                        if let image = selectedImage {
                            FoodResultView(
                                image: image,
                                items: $foodItems,
                                onSave: handleSave
                            )
                        } else {
                            sourceSelection
                        }
                    default:
                        sourceSelection
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in
                handlePickedImage(image)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoLibraryPicker { image in
                handlePickedImage(image)
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        ZStack {
            Text("食事を記録")
                .font(.custom("NotoSansJP-Bold", size: 18))
                .foregroundStyle(Color("AccentBlack"))

            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color("TextSecondary"))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 56)
    }

    // MARK: - Step 1: source selection

    private var sourceSelection: some View {
        VStack(spacing: 16) {
            sourceCard(icon: "camera.fill", title: "カメラで撮影") {
                showCamera = true
            }
            sourceCard(icon: "photo.on.rectangle", title: "ライブラリから選ぶ") {
                showPhotoPicker = true
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    private func sourceCard(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(Color("AccentBlack"))
                    .frame(width: 32, alignment: .center)

                Text(title)
                    .font(.custom("NotoSansJP-SemiBold", size: 16))
                    .foregroundStyle(Color("AccentBlack"))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color("TextTertiary"))
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color("CardBackground"))
            )
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 2: analysing screen

    private var analysingView: some View {
        VStack(spacing: 20) {
            Spacer()

            SwiftUI.ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.8)
                .tint(Color("AccentBlack"))

            Text("AIが分析中")
                .font(.custom("NotoSansJP-SemiBold", size: 18))
                .foregroundStyle(Color("AccentBlack"))

            Text(String(repeating: ".", count: dotCount))
                .font(.system(size: 18))
                .foregroundStyle(Color("AccentBlack"))
                .frame(height: 22)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            startDotTimer()
            runAnalysis()
        }
        .onDisappear {
            stopDotTimer()
        }
    }

    // MARK: - Flow handlers

    private func handlePickedImage(_ image: UIImage) {
        selectedImage = image
        step = 2
    }

    private func handleSave() {
        dismiss()
        onLogged()
    }

    private func runAnalysis() {
        guard let image = selectedImage else { return }
        Task {
            let items = await analyzeFood(image: image)
            await MainActor.run {
                foodItems = items
                step = 3
                stopDotTimer()
            }
        }
    }

    private func analyzeFood(image: UIImage) async -> [FoodItem] {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return [
            FoodItem(name: "おにぎり（鮭）", kcal: 185, protein: 6.2, carbs: 34.1, fat: 2.8),
            FoodItem(name: "緑茶（500ml）", kcal: 0, protein: 0, carbs: 0, fat: 0)
        ]
    }

    // MARK: - Dot animation

    private func startDotTimer() {
        dotCount = 1
        dotTimer?.invalidate()
        dotTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            DispatchQueue.main.async {
                dotCount = dotCount >= 3 ? 1 : dotCount + 1
            }
        }
    }

    private func stopDotTimer() {
        dotTimer?.invalidate()
        dotTimer = nil
    }
}

#Preview {
    FoodLogView()
}
