# PashaCalo (パシャカロ) - Master Build Prompt

**Goal:** Build a pixel-perfect clone of Cal AI, localized entirely for the Japanese market.
**Stack:** SwiftUI, Supabase (Auth + DB), RevenueCat (Subscriptions), OpenAI GPT-4o Vision (Food Analysis).
**Font:** Noto Sans JP (MUST be used everywhere).

## Core Principles (Strictly Enforce)
1. **NO EMOJIS:** Emojis must be entirely removed from the application interface.
2. **NO DASHES IN FONTS:** Dashes should not be used in any fonts.
3. **LIQUID GLASS THEME:** The app should maintain a consistent theme throughout, including the entire onboarding process, incorporating 'perfect liquid glass' elements.
4. **ONBOARDING UX:** Every onboarding screen must be impressive, fun to use, and visually appealing.
5. **JAPANESE TONE:** Use polite, encouraging language (敬語 lite). No shame-based messaging. Frame everything as progress. Use "kcal" and "kg".

## File Structure
```
PashaCalo/
├── App/
│   ├── PashaCaloApp.swift
│   ├── AppState.swift
│   └── RootView.swift
├── Models/
│   ├── UserProfile.swift
│   └── FoodModels.swift
├── Views/
│   ├── Onboarding/
│   ├── Dashboard/
│   ├── History/
│   ├── Profile/
│   └── Paywall/
├── Services/
│   ├── SupabaseManager.swift
│   ├── RevenueCatManager.swift
│   └── VisionAIAnalyzer.swift
└── Resources/
    └── Colors.xcassets
```

## Screen-by-Screen Blueprint

### 1. Splash Screen
*   **Visuals:** Solid white background, black logo icon (apple with a leaf), black text.
*   **Copy:** "パシャカロ" (PashaCalo)
*   **Flow:** Auto-transitions to Welcome screen.

### 2. Welcome Screen
*   **Visuals:** Animated graphic of a phone screen demonstrating food scanning. Liquid glass elements. Black primary CTA button.
*   **Copy:**
    *   Heading: "カロリー管理を簡単に" (Calorie tracking made easy)
    *   Button: "はじめる" (Get Started)
*   **Flow:** Tapping button starts the onboarding questionnaire.

### 3. Onboarding: Gender Selection
*   **Visuals:** Back arrow, progress bar. Three large rectangular selection buttons.
*   **Copy:**
    *   Heading: "性別を選択してください" (Choose your sex)
    *   Subtext: "あなたに最適なプランを作成します" (This helps personalize your experience)
    *   Options: "男性" (Male), "女性" (Female), "その他" (Other)
    *   Button: "次へ" (Continue)

### 4. Onboarding: Workout Frequency
*   **Visuals:** Three large rectangular cards with icons.
*   **Copy:**
    *   Heading: "週に何回運動しますか？" (How many workouts do you do per week?)
    *   Subtext: "目標カロリーの計算に使用します" (This will be used to calibrate your custom plan)
    *   Options: "0-2回 たまに運動する", "3-5回 定期的に運動する", "6回以上 アスリートレベル"

### 5. Onboarding: Date of Birth
*   **Visuals:** Three vertical scrolling wheel selectors (Year, Month, Day).
*   **Copy:**
    *   Heading: "生年月日を教えてください" (When were you born?)

### 6. Onboarding: Acquisition Source
*   **Visuals:** Scrolling list of rectangular buttons with brand icons.
*   **Copy:**
    *   Heading: "パシャカロをどこで知りましたか？" (Where did you hear about us?)
    *   Options: "Instagram", "X (Twitter)", "TikTok", "友人・家族", "App Store", "その他"

### 7. Onboarding: Previous App Usage
*   **Visuals:** Two rectangular buttons (Thumbs Up / Thumbs Down icons).
*   **Copy:**
    *   Heading: "他のカロリー管理アプリを使ったことはありますか？" (Have you tried other calorie tracking apps?)
    *   Options: "はい" (Yes), "いいえ" (No)

### 8. Onboarding: Value Graph (Interstitial)
*   **Visuals:** Line graph showing "Traditional diet" (fluctuating red) vs "PashaCalo" (steady downward black line).
*   **Copy:**
    *   Heading: "目標達成をサポートします" (Designed to help you stay on track)
    *   Subtext: "習慣を記録し、長期的な成果を出しましょう" (Track your habits and stay consistent over time)

### 9. Onboarding: Height & Weight
*   **Visuals:** Text inputs for Height (cm) and Weight (kg).
*   **Copy:**
    *   Heading: "現在の身長と体重を教えてください"

### 10. Auth Screen
*   **Visuals:** Apple, Google, and Email sign-in buttons.
*   **Copy:**
    *   Heading: "進行状況を保存" (Save your progress)
    *   Buttons: "Appleでサインイン", "Googleでサインイン", "メールで続ける"

### 11. The 3-Screen Paywall Trust Sequence
**Screen 1 (Offer):**
*   **Copy:** "3日間の無料トライアルですべての機能をお試しください" (Try all features free for 3 days)
**Screen 2 (Trust):**
*   **Copy:** "トライアル終了の2日前にお知らせします。いつでもキャンセル可能です。" (We'll remind you 2 days before trial ends. Cancel anytime.)
**Screen 3 (Paywall):**
*   **Visuals:** Annual, Monthly, Weekly pricing cards.
*   **Copy:**
    *   Heading: "プランを選択" (Choose your plan)
    *   Options: "年間プラン (最もお得)", "月間プラン", "週間プラン"

### 12. Main Dashboard
*   **Visuals:** Date carousel at top. Large circular calorie ring. Three smaller macro rings (Protein, Carbs, Fat). Bottom navigation bar.
*   **Copy:**
    *   "残りカロリー" (Calories left)
    *   "タンパク質", "炭水化物", "脂質"
    *   "今日の食事" (Today's meals)

## Security Playbook (Implement Immediately)
1. Use Supabase for Auth. Implement Row Level Security (RLS) on all tables from day one.
2. Store API keys (OpenAI, RevenueCat) securely in environment variables. NEVER commit `.env`.
3. Add rate limiting to any custom backend endpoints.
4. Build a real account deletion flow (mandatory for App Store).

## Implementation Instructions for Cursor
1. Read this entire document.
2. Generate the SwiftUI views screen by screen, following the exact copy provided.
3. Ensure Noto Sans JP is applied globally.
4. Remove all emojis from the generated code.
5. Apply the "liquid glass" visual style (translucency, subtle blurs, soft shadows) to the onboarding flow.
