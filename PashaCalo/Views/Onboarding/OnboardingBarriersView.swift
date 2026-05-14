import SwiftUI

struct OnboardingBarriersView: View {
    @EnvironmentObject private var data: OnboardingData
    let onNext: () -> Void

    private struct BarrierOption: Identifiable {
        let id = UUID()
        let key: String
        let icon: String
        let label: String
    }

    private let options: [BarrierOption] = [
        .init(
            key: OnboardingData.Barrier.consistency,
            icon: "chart.bar.fill",
            label: "続けるのが難しい"
        ),
        .init(
            key: OnboardingData.Barrier.eatingHabits,
            icon: "fork.knife",
            label: "食生活が乱れがち"
        ),
        .init(
            key: OnboardingData.Barrier.support,
            icon: "hands.sparkles.fill",
            label: "サポートが足りない"
        ),
        .init(
            key: OnboardingData.Barrier.busySchedule,
            icon: "calendar",
            label: "忙しくて時間がない"
        ),
        .init(
            key: OnboardingData.Barrier.mealInspiration,
            icon: "leaf.fill",
            label: "何を食べればいいかわからない"
        )
    ]

    private var isSelectionValid: Bool {
        !data.barriers.isEmpty
    }

    // Soft lavender row background lifted from screenshot 2.
    private let rowBackground = Color(red: 0.95, green: 0.94, blue: 0.97)

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("目標達成で難しいと感じることは？")
                .font(.custom("NotoSansJP-Bold", size: 26))
                .foregroundStyle(Color("TextPrimary"))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 28)

            VStack(spacing: 12) {
                ForEach(options) { option in
                    barrierRow(option)
                }
            }

            Spacer()

            PrimaryButton(title: "次へ") {
                onNext()
            }
            .disabled(!isSelectionValid)
            .opacity(isSelectionValid ? 1.0 : 0.4)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func barrierRow(_ option: BarrierOption) -> some View {
        let selected = data.barriers.contains(option.key)

        Button {
            toggle(option.key)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(selected ? Color.white.opacity(0.18) : Color.white)
                        .frame(width: 40, height: 40)
                    Image(systemName: option.icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(selected ? .white : Color("TextPrimary"))
                }

                Text(option.label)
                    .font(.custom("NotoSansJP-SemiBold", size: 16))
                    .foregroundStyle(selected ? .white : Color("TextPrimary"))

                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selected ? Color("AccentBlack") : rowBackground)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: selected)
    }

    private func toggle(_ key: String) {
        if data.barriers.contains(key) {
            data.barriers.remove(key)
        } else {
            data.barriers.insert(key)
        }
    }
}

#Preview {
    let data = OnboardingData()
    data.goalDirection = OnboardingData.GoalDirection.maintain
    return OnboardingBarriersView(onNext: {})
        .environmentObject(data)
        .background(Color("AppBackground"))
}
