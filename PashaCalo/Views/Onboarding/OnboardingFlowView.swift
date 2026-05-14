import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var data = OnboardingData()
    @State private var step: Int = 1

    private let totalSteps: Double = 14

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
                        //   - maintain    → ask which barriers are holding them back
                        //   - gain / lose → pick a target weight on the ruler
                        if data.goalDirection == OnboardingData.GoalDirection.maintain {
                            OnboardingBarriersView(onNext: advance)
                        } else {
                            OnboardingGoalWeightView(onNext: advance)
                        }
                    case 10:
                        // Plan teaser — reached by every direction; the
                        // headline adapts to lose / gain / maintain.
                        OnboardingGoalPlanView(onNext: advance)
                    case 11:
                        // Pace picker — only applies to gain / lose. Maintain
                        // users skip straight to diet in `advance()` below.
                        OnboardingPaceView(onNext: advance)
                    case 12:
                        // Comparison hero — also gated to gain / lose, since
                        // it's framed as the payoff for the pace they just
                        // committed to. Maintain users skip it for the same
                        // reason they skip pace (see `advance()` below).
                        OnboardingSimplerWayView(onNext: advance)
                    case 13:
                        OnboardingDietView(onNext: advance)
                    case 14:
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
        // The pace picker (step 11) and the comparison hero (step 12) only
        // apply when the user is actively shifting their weight — maintain
        // users skip both and jump straight from the plan teaser to diet.
        if step == 10, data.goalDirection == OnboardingData.GoalDirection.maintain {
            step = 13
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
