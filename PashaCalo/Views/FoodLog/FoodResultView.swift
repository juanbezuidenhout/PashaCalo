import SwiftUI
import UIKit

struct FoodResultView: View {
    let image: UIImage
    @Binding var items: [FoodItem]
    var onSave: (_ mealType: String) -> Void

    @State private var selectedMeal: Int = 1
    @State private var isEditing: Bool = false
    @State private var isSaving: Bool = false

    private let mealLabels: [String] = ["朝食", "昼食", "夕食", "間食"]

    private var totalKcal: Int {
        items.reduce(0) { $0 + $1.kcal }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                heroImage

                sectionHeader

                itemsList

                totalRow

                mealSelector

                actionButtons
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Hero image

    private var heroImage: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Section header

    private var sectionHeader: some View {
        HStack {
            Text("検出された食品")
                .font(.custom("NotoSansJP-SemiBold", size: 17))
                .foregroundStyle(Color("AccentBlack"))
            Spacer()
        }
    }

    // MARK: - Items list

    private var itemsList: some View {
        VStack(spacing: 10) {
            ForEach($items) { $item in
                itemRow(item: $item)
            }
        }
    }

    private func itemRow(item: Binding<FoodItem>) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    TextField("食品名", text: item.name)
                        .font(.custom("NotoSansJP-SemiBold", size: 15))
                        .foregroundStyle(Color("AccentBlack"))
                        .textFieldStyle(.roundedBorder)

                    HStack(spacing: 8) {
                        macroEditor(label: "P", value: item.protein, unit: "g")
                        macroEditor(label: "C", value: item.carbs, unit: "g")
                        macroEditor(label: "F", value: item.fat, unit: "g")
                    }
                } else {
                    Text(item.wrappedValue.name)
                        .font(.custom("NotoSansJP-SemiBold", size: 15))
                        .foregroundStyle(Color("AccentBlack"))

                    Text(macroSummary(for: item.wrappedValue))
                        .font(.custom("NotoSansJP-Regular", size: 12))
                        .foregroundStyle(Color("TextSecondary"))
                }
            }

            Spacer()

            if isEditing {
                HStack(spacing: 2) {
                    TextField(
                        "kcal",
                        value: item.kcal,
                        format: .number
                    )
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.custom("NotoSansJP-Bold", size: 15))
                    .foregroundStyle(Color("AccentBlack"))
                    .frame(width: 56)
                    .textFieldStyle(.roundedBorder)

                    Text("kcal")
                        .font(.custom("NotoSansJP-Regular", size: 12))
                        .foregroundStyle(Color("TextSecondary"))
                }
            } else {
                Text("\(item.wrappedValue.kcal) kcal")
                    .font(.custom("NotoSansJP-Bold", size: 15))
                    .foregroundStyle(Color("AccentBlack"))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("CardBackground"))
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 1)
    }

    private func macroSummary(for item: FoodItem) -> String {
        "タンパク質 \(formatMacro(item.protein))g　炭水化物 \(formatMacro(item.carbs))g　脂質 \(formatMacro(item.fat))g"
    }

    private func formatMacro(_ value: Double) -> String {
        if value == value.rounded() {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }

    private func macroEditor(label: String, value: Binding<Double>, unit: String) -> some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.custom("NotoSansJP-SemiBold", size: 11))
                .foregroundStyle(Color("TextSecondary"))
            TextField(label, value: value, format: .number)
                .keyboardType(.decimalPad)
                .font(.custom("NotoSansJP-Regular", size: 12))
                .foregroundStyle(Color("AccentBlack"))
                .frame(width: 40)
                .textFieldStyle(.roundedBorder)
            Text(unit)
                .font(.custom("NotoSansJP-Regular", size: 11))
                .foregroundStyle(Color("TextSecondary"))
        }
    }

    // MARK: - Total row

    private var totalRow: some View {
        VStack(spacing: 12) {
            Rectangle()
                .fill(Color("BorderLight"))
                .frame(height: 1)

            HStack {
                Text("合計")
                    .font(.custom("NotoSansJP-Bold", size: 16))
                    .foregroundStyle(Color("AccentBlack"))
                Spacer()
                Text("\(totalKcal) kcal")
                    .font(.custom("NotoSansJP-Bold", size: 20))
                    .foregroundStyle(Color("AccentBlack"))
            }
        }
    }

    // MARK: - Meal selector

    private var mealSelector: some View {
        HStack(spacing: 8) {
            ForEach(0..<mealLabels.count, id: \.self) { index in
                mealChip(index: index)
            }
        }
    }

    private func mealChip(index: Int) -> some View {
        let isSelected = selectedMeal == index
        return Button {
            selectedMeal = index
        } label: {
            Text(mealLabels[index])
                .font(.custom(isSelected ? "NotoSansJP-SemiBold" : "NotoSansJP-Regular", size: 13))
                .foregroundStyle(isSelected ? .white : Color("AccentBlack"))
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isSelected ? Color("AccentBlack") : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color("BorderLight"), lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Action buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            PrimaryButton(title: isSaving ? "記録中..." : "記録する") {
                guard !isSaving else { return }
                isSaving = true
                onSave(mealLabels[selectedMeal])
            }
            .disabled(isSaving)
            .opacity(isSaving ? 0.7 : 1.0)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isEditing.toggle()
                }
            } label: {
                Text(isEditing ? "完了" : "修正する")
                    .font(.custom("NotoSansJP-Regular", size: 14))
                    .foregroundStyle(Color("TextSecondary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }
}

#Preview {
    FoodResultView(
        image: UIImage(systemName: "photo") ?? UIImage(),
        items: .constant([
            FoodItem(name: "おにぎり（鮭）", kcal: 185, protein: 6.2, carbs: 34.1, fat: 2.8),
            FoodItem(name: "緑茶（500ml）", kcal: 0, protein: 0, carbs: 0, fat: 0)
        ]),
        onSave: { _ in }
    )
    .background(Color("AppBackground"))
}
