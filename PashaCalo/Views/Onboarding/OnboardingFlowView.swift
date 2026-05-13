import SwiftUI

/// Cal AI-style onboarding: 3+ minutes of personalisation before the paywall.
/// Screens: Welcome → Goal → Gender → Age → Weight → Height → Target Weight → Activity → Summary
struct OnboardingFlowView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentStep: Int = 0

    private let totalSteps = 9

    var body: some View {
        ZStack {
            Color("BackgroundCream")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                if currentStep > 0 {
                    OnboardingProgressBar(current: currentStep, total: totalSteps - 1)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                }

                // Step content
                Group {
                    switch currentStep {
                    case 0: OnboardingWelcomeView(onNext: nextStep)
                    case 1: OnboardingGoalView(onNext: nextStep)
                    case 2: OnboardingGenderView(onNext: nextStep)
                    case 3: OnboardingAgeView(onNext: nextStep)
                    case 4: OnboardingWeightView(onNext: nextStep)
                    case 5: OnboardingHeightView(onNext: nextStep)
                    case 6: OnboardingTargetWeightView(onNext: nextStep)
                    case 7: OnboardingActivityView(onNext: nextStep)
                    case 8: OnboardingSummaryView(onFinish: finishOnboarding)
                    default: EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }

    private func nextStep() {
        withAnimation {
            currentStep = min(currentStep + 1, totalSteps - 1)
        }
    }

    private func finishOnboarding() {
        appState.completeOnboarding()
    }
}

// MARK: - Progress Bar

struct OnboardingProgressBar: View {
    let current: Int
    let total: Int

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("ProgressBackground"))
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color("AccentGreen"))
                    .frame(width: geo.size.width * CGFloat(current) / CGFloat(total), height: 4)
                    .animation(.easeInOut(duration: 0.3), value: current)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Welcome Screen

struct OnboardingWelcomeView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Text("パシャカロへようこそ")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .multilineTextAlignment(.center)

                Text("写真を撮るだけで\nカロリーが瞬時にわかる")
                    .font(.system(size: 17))
                    .foregroundColor(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            .padding(.horizontal, 32)

            // Feature highlights
            VStack(spacing: 16) {
                OnboardingFeatureRow(icon: "camera.fill", text: "写真1枚でカロリー計算")
                OnboardingFeatureRow(icon: "checkmark.seal.fill", text: "コンビニ食品データベース搭載")
                OnboardingFeatureRow(icon: "chart.bar.fill", text: "毎日の栄養バランスを管理")
            }
            .padding(.horizontal, 32)

            Spacer()

            PrimaryButton(title: "はじめる") {
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

struct OnboardingFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color("AccentGreen"))
                .frame(width: 32)

            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Color("TextPrimary"))

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Goal Screen

struct OnboardingGoalView: View {
    @EnvironmentObject var appState: AppState
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            OnboardingHeader(
                title: "目標を教えてください",
                subtitle: "あなたに最適なプランを作成します"
            )

            VStack(spacing: 12) {
                ForEach(UserGoal.allCases, id: \.self) { goal in
                    SelectionCard(
                        title: goal.japaneseLabel,
                        icon: goal.icon,
                        isSelected: appState.userGoal == goal
                    ) {
                        appState.userGoal = goal
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            PrimaryButton(title: "次へ") { onNext() }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
        }
    }
}

// MARK: - Gender Screen

struct OnboardingGenderView: View {
    @EnvironmentObject var appState: AppState
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            OnboardingHeader(
                title: "性別を教えてください",
                subtitle: "基礎代謝の計算に使用します"
            )

            VStack(spacing: 12) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    SelectionCard(
                        title: gender.japaneseLabel,
                        icon: gender == .male ? "person.fill" : gender == .female ? "person.fill" : "person.fill.questionmark",
                        isSelected: appState.userGender == gender
                    ) {
                        appState.userGender = gender
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            PrimaryButton(title: "次へ") { onNext() }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
        }
    }
}

// MARK: - Age Screen

struct OnboardingAgeView: View {
    @EnvironmentObject var appState: AppState
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            OnboardingHeader(
                title: "年齢を教えてください",
                subtitle: "カロリー目標の計算に使用します"
            )

            Picker("年齢", selection: $appState.userAge) {
                ForEach(10...100, id: \.self) { age in
                    Text("\(age)歳").tag(age)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 200)
            .padding(.horizontal, 24)

            Spacer()

            PrimaryButton(title: "次へ") { onNext() }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
        }
    }
}

// MARK: - Weight Screen

struct OnboardingWeightView: View {
    @EnvironmentObject var appState: AppState
    let onNext: () -> Void
    @State private var weightString: String = "60"

    var body: some View {
        VStack(spacing: 32) {
            OnboardingHeader(
                title: "現在の体重を教えてください",
                subtitle: "kg単位で入力してください"
            )

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                TextField("60", text: $weightString)
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 160)

                Text("kg")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))
            }

            Spacer()

            PrimaryButton(title: "次へ") {
                appState.userWeightKg = Double(weightString) ?? 60.0
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Height Screen

struct OnboardingHeightView: View {
    @EnvironmentObject var appState: AppState
    let onNext: () -> Void
    @State private var heightString: String = "165"

    var body: some View {
        VStack(spacing: 32) {
            OnboardingHeader(
                title: "身長を教えてください",
                subtitle: "cm単位で入力してください"
            )

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                TextField("165", text: $heightString)
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 160)

                Text("cm")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))
            }

            Spacer()

            PrimaryButton(title: "次へ") {
                appState.userHeightCm = Double(heightString) ?? 165.0
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Target Weight Screen

struct OnboardingTargetWeightView: View {
    @EnvironmentObject var appState: AppState
    let onNext: () -> Void
    @State private var targetString: String = "55"

    var body: some View {
        VStack(spacing: 32) {
            OnboardingHeader(
                title: "目標体重を教えてください",
                subtitle: "理想の体重を入力してください"
            )

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                TextField("55", text: $targetString)
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(Color("TextPrimary"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 160)

                Text("kg")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))
            }

            Spacer()

            PrimaryButton(title: "次へ") {
                appState.targetWeightKg = Double(targetString) ?? 55.0
                onNext()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Activity Screen

struct OnboardingActivityView: View {
    @EnvironmentObject var appState: AppState
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            OnboardingHeader(
                title: "活動レベルを教えてください",
                subtitle: "1日の消費カロリーの計算に使用します"
            )

            VStack(spacing: 10) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    SelectionCard(
                        title: level.japaneseLabel,
                        icon: "figure.walk",
                        isSelected: appState.activityLevel == level
                    ) {
                        appState.activityLevel = level
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            PrimaryButton(title: "次へ") { onNext() }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
        }
    }
}

// MARK: - Summary Screen

struct OnboardingSummaryView: View {
    @EnvironmentObject var appState: AppState
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            OnboardingHeader(
                title: "あなたのプランが完成しました",
                subtitle: "毎日の目標カロリーを計算しました"
            )

            VStack(spacing: 16) {
                CalorieTargetCard(calories: appState.dailyCalorieTarget)

                HStack(spacing: 12) {
                    MacroCard(label: "タンパク質", value: appState.dailyProteinTarget, unit: "g", color: "MacroProtein")
                    MacroCard(label: "炭水化物", value: appState.dailyCarbTarget, unit: "g", color: "MacroCarb")
                    MacroCard(label: "脂質", value: appState.dailyFatTarget, unit: "g", color: "MacroFat")
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            PrimaryButton(title: "パシャカロをはじめる") {
                onFinish()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

struct CalorieTargetCard: View {
    let calories: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("1日の目標カロリー")
                .font(.system(size: 14))
                .foregroundColor(Color("TextSecondary"))

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(calories)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color("AccentGreen"))
                Text("kcal")
                    .font(.system(size: 18))
                    .foregroundColor(Color("TextSecondary"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

struct MacroCard: View {
    let label: String
    let value: Int
    let unit: String
    let color: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color("TextSecondary"))

            Text("\(value)\(unit)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(color))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Shared Onboarding Components

struct OnboardingHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.system(size: 15))
                .foregroundColor(Color("TextSecondary"))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .padding(.top, 32)
    }
}

struct SelectionCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isSelected ? Color("AccentGreen") : Color("TextSecondary"))
                    .frame(width: 28)

                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(Color("TextPrimary"))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("AccentGreen"))
                }
            }
            .padding(16)
            .background(isSelected ? Color("AccentGreen").opacity(0.08) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color("AccentGreen") : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
