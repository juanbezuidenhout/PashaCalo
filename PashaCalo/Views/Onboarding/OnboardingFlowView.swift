import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var data = OnboardingData()
    @State private var step: Int = 1

    private let totalSteps: Double = 11

    var body: some View {
        ZStack {
            Color("AppBackground").ignoresSafeArea()

            VStack(spacing: 0) {
                progressBar
                    .padding(.top, 8)

                Group {
                    switch step {
                    case 1:
                        OnboardingGenderView(onNext: advance)
                    case 2:
                        OnboardingActivityView(onNext: advance)
                    case 3:
                        OnboardingDOBView(onNext: advance)
                    case 4:
                        OnboardingDiscoveryView(onNext: advance)
                    case 5:
                        OnboardingPreviousAppView(onNext: advance)
                    case 6:
                        OnboardingGraphView(onNext: advance)
                    case 7:
                        OnboardingHeightWeightView(onNext: advance)
                    case 8:
                        OnboardingGoalDirectionView(onNext: advance)
                    case 9:
                        // Step 9 branches off the chosen goal direction:
                        //   - maintain → ask which barriers are holding them back
                        //   - gain     → pick a target weight on the ruler
                        //   - lose     → skipped entirely in `advance()` below
                        if data.goalDirection == OnboardingData.GoalDirection.maintain {
                            OnboardingBarriersView(onNext: advance)
                        } else {
                            OnboardingGoalWeightView(onNext: advance)
                        }
                    case 10:
                        OnboardingDietView(onNext: advance)
                    case 11:
                        OnboardingCompleteView()
                    default:
                        placeholder
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environmentObject(data)
            }
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color("BorderLight"))
                    .frame(height: 4)

                Rectangle()
                    .fill(Color("AccentBlack"))
                    .frame(
                        width: geo.size.width * CGFloat(Double(step) / totalSteps),
                        height: 4
                    )
            }
        }
        .frame(height: 4)
        .animation(.easeInOut, value: step)
    }

    private var placeholder: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("ステップ \(step)")
                .font(.custom("NotoSansJP-Bold", size: 22))
                .foregroundStyle(Color("TextPrimary"))
            Text("後ほど追加されます")
                .font(.custom("NotoSansJP-Regular", size: 14))
                .foregroundStyle(Color("TextSecondary"))
            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private func advance() {
        // Users who picked "lose" don't need step 9 (neither the goal-weight
        // wheel nor the barriers list), so jump straight to the diet step.
        if step == 8, data.goalDirection == OnboardingData.GoalDirection.lose {
            step = 10
            return
        }

        if step < Int(totalSteps) {
            step += 1
        } else {
            appState.completeOnboarding()
        }
    }
}

#Preview {
    OnboardingFlowView()
        .environmentObject(AppState())
}
