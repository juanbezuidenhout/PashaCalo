# PashaCalo — Cursor Prompts (Run in Order, One at a Time)

---

## PROMPT 1 — Project Setup, AppState, Colors, Shared Components

```
You are building PashaCalo, a SwiftUI iOS app. This is the foundation step.

Create the following files exactly as described:

GLOBAL RULES (apply to every file you generate now and in all future prompts):
- Font: Noto Sans JP for all text. Register it in the project.
- No emojis anywhere.
- No dashes in any displayed text.
- Color names reference the asset catalog defined below.
- All transitions between screens use .easeInOut(duration: 0.35).
- Liquid glass aesthetic: use .ultraThinMaterial and .regularMaterial for card backgrounds, subtle shadows, soft corner radii of 16pt minimum.

--- FILE 1: AppState.swift ---
An ObservableObject class called AppState.
Published properties:
- isOnboardingComplete: Bool = false
- isAuthenticated: Bool = false
- hasSeenPaywall: Bool = false
- isSubscribed: Bool = false
- userProfile: UserProfile? = nil

Methods:
- completeOnboarding()
- completePaywall()
- setAuthenticated(_ value: Bool)
- setSubscribed(_ value: Bool)

--- FILE 2: UserProfile.swift ---
A struct called UserProfile (Codable, Identifiable).
Properties:
- id: UUID
- sex: String
- dateOfBirth: Date
- heightCm: Double
- weightKg: Double
- goalWeightKg: Double
- activityLevel: String
- dailyKcalTarget: Int
- dailyProteinTarget: Int
- dailyCarbTarget: Int
- dailyFatTarget: Int
- streakDays: Int

--- FILE 3: Colors.xcassets ---
Define these named colors in the asset catalog (light mode only for now):
- AppBackground: #F5F5F0
- CardBackground: #FFFFFF
- AccentBlack: #1A1A1A
- TextPrimary: #1A1A1A
- TextSecondary: #6B6B6B
- TextTertiary: #ADADAD
- BorderLight: #E8E8E8
- RingProtein: #FF6B9D
- RingCarbs: #FF9500
- RingFat: #007AFF
- RingFiber: #AF52DE
- RingSugar: #FF2D55
- RingSodium: #FFCC00
- HealthyGreen: #34C759

--- FILE 4: PrimaryButton.swift ---
A reusable SwiftUI View called PrimaryButton.
Parameters: title: String, action: () -> Void
Style: full width, 56pt height, 28pt corner radius (pill shape), AccentBlack background, white Noto Sans JP Semibold 17pt text.
On tap: subtle scale animation (scaleEffect 0.97) then back to 1.0.

--- FILE 5: RootView.swift ---
A SwiftUI View that reads AppState from the environment.
Logic:
- If !isOnboardingComplete → show OnboardingFlowView()
- If isOnboardingComplete && !isAuthenticated → show AuthView()
- If isAuthenticated && !hasSeenPaywall → show PaywallTrustSequenceView()
- If isAuthenticated && hasSeenPaywall → show MainTabView()
All transitions: .asymmetric insertion .move(edge: .trailing), removal .move(edge: .leading), combined with .opacity.

--- FILE 6: PashaCaloApp.swift ---
The @main App struct.
Creates AppState as a @StateObject and injects it as .environmentObject into RootView.
```

---

## PROMPT 2 — Splash Screen + Welcome Screen

```
You are continuing to build PashaCalo. AppState, colors, and shared components already exist.

Build these two screens exactly as described:

--- SCREEN 1: SplashView.swift ---
Full screen white background.
Center: VStack with:
- SF Symbol "leaf.fill" at 52pt, color AccentBlack
- Text "パシャカロ" in Noto Sans JP Bold 32pt, color AccentBlack
On appear: after 1.5 seconds, call a provided onComplete closure to advance to WelcomeView.
No animations on the text itself — clean, still, confident.

--- SCREEN 2: WelcomeView.swift ---
White background.
Layout top to bottom:
1. Top right corner: a small pill-shaped button showing "JP" in 13pt Noto Sans JP Regular, light gray background (#F0F0F0), AccentBlack text. Non-functional for now (static).
2. Center: A large rounded rectangle card (aspect ratio ~9:16 scaled to fit, max width 260pt) with AppBackground fill and a subtle shadow. Inside this card, show a static mockup of the app dashboard: display the text "残りkcal" in 13pt TextSecondary, a large bold number "2199" in 28pt AccentBlack, and below that three small colored dots (pink, orange, blue) representing macros. This simulates the app in use.
3. Below the card:
   - Heading: "カロリー管理を、もっと簡単に" — Noto Sans JP Bold 26pt, AccentBlack, center aligned
   - Subtext: "写真を撮るだけで栄養を自動計算" — Noto Sans JP Regular 15pt, TextSecondary, center aligned
4. Bottom: PrimaryButton with title "はじめる". On tap, navigate to the first onboarding screen.

The card entrance should animate: slide up from slightly below with opacity fade over 0.6 seconds on appear.
```

---

## PROMPT 3 — Onboarding Screens 1 to 5

```
You are continuing to build PashaCalo. All previous screens exist.

Build an OnboardingFlowView.swift that manages a @State var step: Int starting at 1, advancing via a shared "次へ" button. Each step renders a different child view. Include a progress bar at the top of every screen: a thin (4pt) full-width track in BorderLight, with an AccentBlack fill that animates to (currentStep / 9) width using .animation(.easeInOut, value: step).

Build these 5 onboarding screens as separate SwiftUI Views:

--- OnboardingGenderView ---
Heading: "性別を教えてください" — Bold 26pt
Subtext: "あなたに合ったプランを作成します" — Regular 14pt TextSecondary
Three full-width selection cards (64pt height, 14pt corner radius):
- "男性"
- "女性"  
- "その他"
Unselected style: BorderLight border 1pt, CardBackground fill, TextPrimary text.
Selected style: AccentBlack fill, white text, spring scale animation on selection (scaleEffect 1.02 then back).
"次へ" button disabled (opacity 0.4) until a selection is made.
Binding: writes selected sex string to a shared OnboardingData ObservableObject.

--- OnboardingActivityView ---
Heading: "週に何回運動しますか？"
Subtext: "目標kcalの計算に使います"
Three selection cards, each with an SF Symbol icon (left, 22pt) and text:
- figure.walk icon → "週0〜2回　たまに動く"
- figure.run icon → "週3〜5回　定期的に運動する"
- figure.strengthtraining.traditional icon → "週6回以上　本格的に鍛えている"
Same selected/unselected style as gender screen.

--- OnboardingDOBView ---
Heading: "生年月日を教えてください"
Subtext: "目標kcalの計算に使います"
Three Picker views in .wheel style arranged horizontally: Year (left), Month (center), Day (right).
Labels above each wheel: "年", "月", "日" in 12pt TextSecondary.
Selected row highlight: light gray pill background.
Default selection: 2000 / January / 1.

--- OnboardingDiscoveryView ---
Heading: "パシャカロをどこで知りましたか？"
Scrollable VStack of selection buttons. Each button: full width, 56pt height, 14pt corner radius, BorderLight border. Icon on left (22pt), text right of icon.
Options (icon → label):
- camera.fill → "Instagram"
- bird → "X / Twitter"
- music.note → "TikTok"
- hand.thumbsup.fill → "Facebook"
- play.rectangle.fill → "YouTube"
- person.2.fill → "友人・家族"
- applelogo → "App Store"
- ellipsis.circle → "その他"
Single selection only. Same selected style as previous screens.

--- OnboardingPreviousAppView ---
Heading: "他のカロリー管理アプリを使ったことはありますか？"
Two cards side by side (HStack, equal width):
- Left: hand.thumbsup.fill icon (24pt) above "はい"
- Right: hand.thumbsdown.fill icon (24pt) above "いいえ"
Each card: 100pt height, 14pt corner radius, same selected/unselected style.
```

---

## PROMPT 4 — Onboarding Screens 6 to 9

```
You are continuing to build PashaCalo. Onboarding screens 1 to 5 exist.

Build these 4 remaining onboarding screens and add them to OnboardingFlowView:

--- OnboardingGraphView (step 6) ---
This is a motivational interstitial. No data is collected. Visual reference: Cal AI's "Designed to help you stay on track" screen.
Heading: "続けるほど、変化が見えてくる" — Bold 26pt
A card (CardBackground, 24pt corner radius, no shadow) containing a line chart:
- Card header: "体重" — Bold 20pt TextPrimary (top-left of card)
- Axes hidden. Only "1ヶ月目" and "6ヶ月目" shown at the bottom corners of the card.
- A faint dashed horizontal reference line in the middle of the chart.
- On the dashed line (left side), an inline brand pill: small camera icon + "パシャカロ" + a small black capsule containing "体重".
- Line 1 (記録なし): smooth catmullRom pink/red line that dips slightly then rebounds above the starting weight. A soft pink area fill (linear gradient fading in from left) sits between the reference line and the line where the line is above the reference. The label "記録なし" appears in pink near the rising portion of the line.
- Line 2 (パシャカロ): smooth catmullRom AccentBlack line, slightly thicker, trending steadily downward. White-filled circles with a 2pt AccentBlack stroke mark the start (top-left) and end (bottom-right) of the line.
Subtext below card: "食習慣を記録して、長期的な変化を実感しましょう" — Regular 14pt TextSecondary center aligned
Button: "次へ"

--- OnboardingHeightWeightView (step 7) ---
Heading: "身長と体重を教えてください"
Subtext: "目標kcalの計算に使います"
Two input fields stacked vertically, each in a CardBackground rounded card:
- Field 1: label "身長" left, numeric text field right, "cm" unit label far right
- Field 2: label "体重" left, decimal numeric text field right, "kg" unit label far right
Keyboard type: .numberPad for height, .decimalPad for weight.
"次へ" disabled until both fields have valid numeric values.

--- OnboardingGoalWeightView (step 8) ---
Heading: "目標体重を教えてください"
Subtext: "無理のない目標が長続きのコツです"
One input field card: label "目標体重", decimal text field, "kg" unit label.
"次へ" disabled until valid value entered.

--- OnboardingCompleteView (step 9 — transitions to AuthView) ---
This screen does NOT collect data. It is a celebration/transition screen.
Center: SF Symbol "checkmark.circle.fill" at 72pt, color HealthyGreen, with a pulse animation (scale 1.0 to 1.08 and back, repeating).
Heading: "準備完了です！" — Bold 28pt
Subtext: "あなた専用のプランが完成しました" — Regular 16pt TextSecondary
Button: "アカウントを作成する" — on tap, call appState.completeOnboarding() which triggers RootView to show AuthView.
```

---

## PROMPT 5 — Auth Screen

```
You are continuing to build PashaCalo. Onboarding is complete.

Build AuthView.swift exactly as described:

Background: #F0F0F0 (slightly gray, different from the white onboarding screens — this signals a new phase).

Layout top to bottom:
1. App icon (leaf.fill SF Symbol, 44pt, AccentBlack) centered near top
2. Heading: "進行状況を保存する" — Noto Sans JP Bold 24pt, AccentBlack, center
3. Subtext: "アカウントを作成して記録を続けましょう" — Regular 15pt TextSecondary, center
4. Three stacked pill buttons (full width, 56pt height, 28pt corner radius), spaced 12pt apart:
   - Button 1 (Sign in with Apple): AccentBlack background, Apple logo SF Symbol "applelogo" left-aligned inside button, white text "Appleでサインイン" — Noto Sans JP Semibold 16pt
   - Button 2 (Sign in with Google): White background, 1pt BorderLight border, Google "g.circle.fill" SF Symbol left-aligned, AccentBlack text "Googleでサインイン"
   - Button 3 (Email): White background, 1pt BorderLight border, envelope SF Symbol "envelope.fill" left-aligned, AccentBlack text "メールで続ける"
5. On tap of any button: call appState.setAuthenticated(true) for now (real auth wired in a later prompt).

Implementation note: Sign in with Apple uses Apple's AuthenticationServices framework. Import it and add the SignInWithAppleButton. This is mandatory for App Store approval.
```

---

## PROMPT 6 — Paywall (3-Screen Trust Sequence)

```
You are continuing to build PashaCalo. Auth screen exists.

Build PaywallTrustSequenceView.swift — a container view that manages @State var screen: Int = 0 and renders 3 child views in sequence with slide transitions.

--- PaywallScreen1View (screen 0) ---
This is NOT the paywall. It is a free trial offer screen.
Background: AppBackground.
Center content:
- SF Symbol "gift.fill" at 64pt, AccentBlack
- Heading: "3日間、すべて無料でお試しください" — Bold 26pt, center
- Subtext: "いつでもキャンセルできます" — Regular 14pt TextSecondary, center
- Feature list (4 rows, each: SF Symbol icon left 20pt AccentBlack, text right):
  - "photo.on.rectangle" → "写真から栄養を自動計算"
  - "chart.bar.fill" → "詳細な栄養バランス分析"
  - "fork.knife" → "コンビニ・外食データベース"
  - "square.and.arrow.up" → "バイラル共有カード"
Bottom: PrimaryButton "無料トライアルを始める" → advances to screen 1.

--- PaywallScreen2View (screen 1) ---
Trust builder. Background: AppBackground.
Center content:
- SF Symbol "bell.badge.fill" at 64pt, AccentBlack
- Heading: "終了の2日前にお知らせします" — Bold 26pt, center
- Subtext: "無料期間中はいつでもキャンセルできます。請求は発生しません。" — Regular 14pt TextSecondary, center
- 3 trust rows (icon + text):
  - "lock.fill" → "いつでもキャンセル可能"
  - "bell.fill" → "終了2日前にリマインダー送信"
  - "creditcard.fill" → "トライアル中は請求なし"
Bottom: PrimaryButton "わかりました" → advances to screen 2.

--- PaywallScreen3View (screen 2) ---
The actual paywall.
Top: Heading "プランを選択してください" — Bold 24pt
Social proof row: 5 star.fill icons (yellow, 12pt each) + "4.8　10,000人以上が利用中" — 13pt TextSecondary
3 pricing cards (tappable, full width, 16pt corner radius):
  Card 1 — 年間プラン:
    - Badge pill top right: "最もお得" — white text on AccentBlack background, 10pt Bold
    - Title: "年間プラン" — Semibold 16pt
    - Savings label: "月あたり約 ¥567" — 12pt HealthyGreen
    - Price right-aligned: "¥6,800 / 年" — Bold 18pt
  Card 2 — 月間プラン:
    - Title: "月間プラン"
    - Price: "¥980 / 月"
  Card 3 — 週間プラン:
    - Title: "週間プラン"
    - Price: "¥380 / 週"
Selected card: 2pt AccentBlack border, AccentBlack.opacity(0.06) background fill.
Unselected card: 1pt BorderLight border, CardBackground fill.
Default selected: 年間プラン.
CTA: PrimaryButton "3日間無料で試す" — on tap calls appState.setSubscribed(true) and appState.completePaywall() for now.
Below CTA: Text button "今はスキップ" — 14pt TextSecondary — same action (no freemium, but allows skip for testing).
Legal text (11pt TextTertiary center): "3日間の無料トライアル後、選択したプランで自動更新されます。"
3 text links row: "プライバシーポリシー　利用規約　購入を復元" — 11pt TextSecondary.
```

---

## PROMPT 7 — Main Tab Bar + Dashboard (Home Screen)

```
You are continuing to build PashaCalo. Paywall exists.

Build MainTabView.swift and DashboardView.swift exactly as described.

--- MainTabView.swift ---
A custom tab bar (do NOT use SwiftUI's TabView tab bar — build a custom HStack bar pinned to the bottom).
5 tab items:
1. house.fill → "ホーム"
2. chart.line.uptrend.xyaxis → "進捗"
3. CENTER: A large 60pt circle, AccentBlack fill, plus.circle.fill icon white 26pt inside. This is the food log button. On tap, present FoodLogView as a sheet.
4. person.2.fill → "グループ"
5. person.fill → "プロフィール"

Active tab icon: AccentBlack. Inactive: TextTertiary.
Tab bar background: CardBackground with a top shadow (opacity 0.08, radius 12).
The center button lifts 16pt above the bar (offset y: -16).

--- DashboardView.swift ---
NavigationView with navigationBarHidden(true).
Background: AppBackground.

SECTION 1 — Top bar:
HStack: "パシャカロ" text left (Noto Sans JP Bold 20pt AccentBlack). Right: a pill containing flame.fill icon (orange) + streak number "0" — 13pt Semibold. Tapping this pill navigates to MilestonesView.

SECTION 2 — Date carousel:
Horizontal ScrollView of 7 days. Each day: VStack of day-of-week abbreviation (月火水木金土日) in 11pt TextSecondary, and day number in 15pt. Current day: day number inside a 32pt AccentBlack circle with white text. Others: plain text.

SECTION 3 — Main calorie card:
CardBackground card, 16pt corner radius, soft shadow.
HStack:
- Left: VStack — large number (e.g. "3164") in Noto Sans JP Bold 42pt AccentBlack. Below: "残りkcal" in 14pt TextSecondary with a small chevron.up.chevron.down icon. Tapping this label toggles between "残りkcal" and "摂取kcal".
- Right: A circular ring (ZStack). Outer ring: 12pt stroke, BorderLight. Inner progress arc: 12pt stroke, AccentBlack, trim from 0 to progress value, rotationEffect -90 degrees. Center: flame.fill icon 22pt orange.

SECTION 4 — Macro cards (horizontal paging):
TabView with .page style (PageTabViewStyle), 3 pages.
Page 1 — 3 cards in HStack:
  - "タンパク質": RingProtein color ring, fork.knife icon, "175g 残り"
  - "炭水化物": RingCarbs color ring, leaf.fill icon, "417g 残り"
  - "脂質": RingFat color ring, drop.fill icon, "87g 残り"
Page 2 — 3 cards:
  - "食物繊維": RingFiber ring, "38g 残り"
  - "糖質": RingSugar ring, "118g 残り"
  - "塩分": RingSodium ring, "2300mg 残り"
Page 3 — 2 cards:
  - Apple Health connect card: heart.fill icon (pink), "Apple Healthを連携", "歩数を記録する", black "連携する" button
  - Activity card: figure.walk icon, "消費カロリー 0 kcal", "歩数 0"
Each macro card: CardBackground, 12pt corner radius, soft shadow, 80pt square.
Pagination dots below the TabView.

SECTION 5 — Recently uploaded:
Title: "最近の食事" — Semibold 17pt
Empty state card: placeholder image area (gray rounded rect), text "＋ボタンで今日の食事を追加しましょう" — 14pt TextSecondary center.

SECTION 6 — Health Score card:
CardBackground card. Title: "健康スコア" Semibold 15pt. Value: "N/A" Bold 28pt. Subtext: "食事を記録するとスコアが表示されます" — 13pt TextSecondary.

SECTION 7 — Water card:
CardBackground card. HStack: glass icon (drop.fill) + "水分　0 ml" left. Right: outlined button "水分を記録" (white fill, 1pt BorderLight border, AccentBlack text 13pt).
```

---

## PROMPT 8 — Camera + Food Log Flow

```
You are continuing to build PashaCalo. Dashboard exists.

Build the food logging flow triggered by the center + button in the tab bar.

--- FoodLogView.swift (presented as a sheet) ---
Full screen sheet. Background: AppBackground.
Top bar: "食事を記録" title center, X dismiss button top right.

Step 1 — Photo source selection:
Two large cards stacked:
- camera.fill icon + "カメラで撮影"
- photo.on.rectangle icon + "ライブラリから選ぶ"
Both open the appropriate iOS picker (UIImagePickerController for camera, PHPickerViewController for library).

Step 2 — Analysing screen (shown after photo selected):
Full screen overlay on AppBackground.
Center: ProgressView() with .circular style, scaled 1.8x, AccentBlack tint.
Below: "AIが分析中" text in Noto Sans JP Semibold 18pt, with animated trailing dots (1, 2, 3 dots cycling every 0.4 seconds using a Timer).
This screen shows while the OpenAI Vision API call is in progress (stub the call for now — return mock data).

Step 3 — Result screen (FoodResultView):
Top: The selected photo in a rounded rect (16pt corner radius), aspect ratio fill, max height 200pt.
Below photo: "検出された食品" title Semibold 17pt.
List of detected food items (use mock data for now):
  Each row: food name left (Semibold 15pt), kcal right (Bold 15pt AccentBlack).
  Below name: "タンパク質 Xg　炭水化物 Xg　脂質 Xg" in 12pt TextSecondary.
Total row at bottom of list: "合計" left Bold 16pt, total kcal right Bold 20pt AccentBlack.

Meal type selector — horizontal pill row:
"朝食　昼食　夕食　間食"
Selected pill: AccentBlack background white text. Unselected: BorderLight border AccentBlack text.

Two buttons at bottom:
1. PrimaryButton "記録する" — saves entry (stub for now), dismisses sheet, shows a brief success toast "記録しました" sliding up from bottom.
2. Text button "修正する" — 14pt TextSecondary — allows manual edit of the detected items (show a simple editable list for MVP).
```

---

## PROMPT 9 — Progress Tab

```
You are continuing to build PashaCalo. Dashboard and food log exist.

Build ProgressView.swift — the second tab.

Background: AppBackground. NavigationView with title "進捗" (Noto Sans JP Bold 22pt, inline).

Week selector: HStack of 4 pill buttons at top:
"今週　先週　2週前　3週前"
Selected: AccentBlack fill white text. Unselected: BorderLight border AccentBlack text.

Three cards stacked vertically (CardBackground, 16pt corner radius, soft shadow):

CARD 1 — 週間エネルギー:
Title: "週間エネルギー" Semibold 15pt.
Empty state: a circular chart icon placeholder (chart.pie.fill, 40pt, TextTertiary) centered.
Text: "食事を記録するとデータが表示されます" — 13pt TextSecondary center.

CARD 2 — 消費変化:
Title: "消費変化" Semibold 15pt.
A table-style list of 5 rows:
"3日　準備中　Pending"
"7日　準備中　Pending"
"14日　準備中　Pending"
"30日　準備中　Pending"
"90日　準備中　Pending"
Each row: timeframe label left (Semibold 13pt), "準備中" center (TextSecondary 12pt), "Pending" right pill (gray background, TextSecondary 11pt).

CARD 3 — BMI:
Title: "BMI" Semibold 15pt. Question mark icon top right (tap shows an alert explaining BMI).
Large number: calculated from userProfile.heightCm and weightKg — Noto Sans JP Bold 36pt.
Status pill below number: text and color based on value:
  - Under 18.5: "低体重" — blue pill
  - 18.5 to 24.9: "健康的" — HealthyGreen pill
  - 25.0 to 29.9: "過体重" — orange pill
  - 30+: "肥満" — red pill
Color-coded horizontal bar (4 segments: blue, green, yellow, red) with a small triangle indicator pointing to the user's BMI position.
Legend below bar: "低体重 18.5未満　健康的 18.5〜24.9　過体重 25.0〜29.9　肥満 30.0以上" — 10pt TextSecondary.
```

---

## PROMPT 10 — Groups Tab

```
You are continuing to build PashaCalo. Progress tab exists.

Build GroupsView.swift — the fourth tab.

Background: AppBackground. NavigationView.

Top bar: Title "グループ" left (Bold 22pt). Bell icon button right (non-functional for MVP).

Subheader row: "グループを探す" left (Semibold 17pt). "+ プライベートグループ" right — outlined pill button (BorderLight border, AccentBlack text 13pt).

Scrollable list of group cards. Each card (CardBackground, 12pt corner radius, soft shadow, full width):
HStack:
- Left: Circle image placeholder (40pt diameter, AppBackground fill, person.2.fill icon TextTertiary)
- Center: VStack left-aligned:
  - Group name: Semibold 15pt AccentBlack
  - Member count: "X人のメンバー" — 12pt TextSecondary
  - Description: 13pt TextSecondary, max 2 lines
- Right: "+ 参加" pill button (white fill, 1pt BorderLight border, AccentBlack text 12pt Semibold)

Groups to show:
1. "フィットネス＆トレーニング" — "10,980人のメンバー" — "カロリー目標に合わせたトレーニングをシェアしよう"
2. "カロリー管理はじめました" — "14,834人のメンバー" — "初心者の質問、ヒント、最初の成果をシェアしよう"
3. "新年の目標チャレンジ" — "1,205人のメンバー" — "目標を宣言して、達成を一緒に祝おう"
4. "筋肉増量チャレンジ" — "9,457人のメンバー" — "カロリーをしっかり摂って一緒に筋肉をつけよう"
5. "ダイエット応援グループ" — "13,057人のメンバー" — "記録を続けて、一緒に理想の体型を目指そう"
```

---

## PROMPT 11 — Profile Tab + Personal Details

```
You are continuing to build PashaCalo. Groups tab exists.

Build ProfileView.swift and PersonalDetailsView.swift.

--- ProfileView.swift ---
Background: AppBackground. NavigationView. Title: "プロフィール" Bold 22pt.

USER CARD (CardBackground, 16pt corner radius, soft shadow):
HStack:
- Circle avatar (52pt): person.fill SF Symbol, TextTertiary, AppBackground fill
- Crown icon (crown.fill, 16pt, yellow) overlapping bottom-right of avatar
- VStack: "名前を設定する" Semibold 15pt AccentBlack. "ユーザー名を設定する" 13pt TextSecondary
- Spacer + chevron.right TextTertiary

INVITE FRIENDS CARD (CardBackground, 16pt corner radius):
Title: "友達を招待" Semibold 15pt
Subtext: "友達を紹介して ¥1,000 をもらおう" 13pt TextSecondary
Chevron right.

ACCOUNT SECTION:
Section header: "アカウント" 13pt TextSecondary uppercase.
Grouped list card (CardBackground, 16pt corner radius):
Rows (each: icon left 20pt AccentBlack, label, chevron right):
- person.fill → "個人情報" → navigates to PersonalDetailsView
- slider.horizontal.3 → "設定"
- globe → "言語"
- person.badge.plus → "ファミリープランにアップグレード"

GOALS & TRACKING SECTION:
Section header: "目標と記録"
Grouped list card:
- heart.fill (red) → "Apple Health"
- target → "栄養目標を編集"

SUPPORT SECTION:
Grouped list card:
- questionmark.circle → "サポート"
- doc.text → "プライバシーポリシー"
- doc.plaintext → "利用規約"
- trash → "アカウントを削除" (red text — mandatory for App Store)

--- PersonalDetailsView.swift ---
NavigationView. Title: "個人情報" Bold 20pt. Back arrow.

GOAL WEIGHT ROW (CardBackground card):
HStack: "目標体重" left Semibold 15pt, "76 kg" center Bold 15pt, "目標を変更" right — outlined pill button.

DETAILS LIST (CardBackground card, grouped rows):
Each row: label left 15pt TextSecondary, value right 15pt AccentBlack Semibold, pencil.fill icon far right 14pt TextTertiary.
Rows:
- "現在の体重" / "67 kg"
- "身長" / "181 cm"
- "生年月日" / "2002年3月31日"
- "性別" / "男性"
- "1日の歩数目標" / "10,000歩"

Values should read from userProfile where available.
```

---

## PROMPT 12 — Milestones and Streaks Screen

```
You are continuing to build PashaCalo. Profile tab exists.

Build MilestonesView.swift — accessed by tapping the flame streak pill on the dashboard.

Background: AppBackground. NavigationView.

TOP BAR: Back arrow left. Share button right (square.and.arrow.up icon — non-functional for MVP).

STREAK SECTION (CardBackground card, 16pt corner radius, soft shadow):
Center: flame.fill icon 40pt orange.
Large number: current streakDays from AppState — Noto Sans JP Bold 56pt AccentBlack.
Below: "日連続" — Regular 18pt TextSecondary.
Subtext: "今日も記録して連続記録を伸ばしましょう" — 14pt TextSecondary center.

ACHIEVEMENTS SECTION:
Title: "実績" Semibold 17pt left.
LazyVGrid with 3 columns, spacing 12pt.
Each badge cell (CardBackground, 12pt corner radius, soft shadow, ~100pt square):
- Icon: SF Symbol centered 28pt
- Label below: 11pt center
- Locked state: icon and text in TextTertiary, gray overlay
- Unlocked state: AccentBlack icon, AccentBlack text, subtle glow shadow

Badges:
1. "1日連続" — flame.fill — unlocked if streakDays >= 1
2. "3日連続" — flame.fill — unlocked if streakDays >= 3
3. "7日連続" — flame.fill — unlocked if streakDays >= 7
4. "30日連続" — flame.fill — unlocked if streakDays >= 30
5. "初めての記録" — fork.knife — unlocked if any food entry exists
6. "目標達成" — checkmark.seal.fill — unlocked if goal weight reached
```

---

## PROMPT 13 — Supabase Integration

```
You are continuing to build PashaCalo. All UI screens exist. Now wire up the backend.

Install the Supabase Swift SDK via Swift Package Manager:
URL: https://github.com/supabase/supabase-swift

Create SupabaseManager.swift:
- Singleton: static let shared = SupabaseManager()
- Initialize SupabaseClient with URL and anon key from a Config.swift file (create Config.swift with placeholder strings SUPABASE_URL and SUPABASE_ANON_KEY — never hardcode real values).
- Store API keys in a .env file and add .env to .gitignore.

Implement these methods:

signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws
  - Calls supabase.auth.signInWithIdToken with the Apple identity token
  - On success, calls appState.setAuthenticated(true)

signInWithGoogle(idToken: String) async throws
  - Calls supabase.auth.signInWithIdToken for Google

signOut() async throws
  - Calls supabase.auth.signOut
  - Calls appState.setAuthenticated(false)

saveProfile(_ profile: UserProfile) async throws
  - Upserts to the "profiles" table

loadProfile() async throws -> UserProfile?
  - Fetches from "profiles" table where id = auth.uid()

saveFoodEntry(_ entry: FoodEntry) async throws
  - Inserts into "food_entries" table

loadTodayEntries() async throws -> [FoodEntry]
  - Fetches food_entries where user_id = auth.uid() and logged_at >= today midnight

deleteAccount() async throws
  - Deletes all user data from profiles and food_entries
  - Calls supabase.auth.admin.deleteUser (or use a Supabase Edge Function)
  - Calls appState.setAuthenticated(false)

Wire up:
- AuthView to call SupabaseManager.shared.signInWithApple/Google/Email
- DashboardView to call loadTodayEntries() on appear
- FoodResultView "記録する" button to call saveFoodEntry()
- ProfileView account delete row to call deleteAccount() with a confirmation alert first
```

---

## PROMPT 14 — RevenueCat Integration

```
You are continuing to build PashaCalo. Supabase integration exists.

Install RevenueCat via Swift Package Manager:
URL: https://github.com/RevenueCat/purchases-ios

Create RevenueCatManager.swift:
- Singleton: static let shared = RevenueCatManager()
- In configure(), call Purchases.configure(withAPIKey: REVENUECAT_API_KEY) — store key in Config.swift.

Implement these methods:

checkSubscriptionStatus() async -> Bool
  - Fetches CustomerInfo
  - Returns true if entitlement "premium" is active
  - Calls appState.setSubscribed(true/false)

purchase(productID: String) async throws
  - Fetches the product from the "default" offering
  - Calls Purchases.shared.purchase(package:)
  - On success, calls appState.setSubscribed(true) and appState.completePaywall()

restorePurchases() async throws
  - Calls Purchases.shared.restorePurchases()
  - Updates subscription status

Product IDs to use:
- "pashacalo_annual" — ¥6,800/year, 3-day free trial
- "pashacalo_monthly" — ¥980/month, 3-day free trial
- "pashacalo_weekly" — ¥380/week, 3-day free trial

Wire up:
- PaywallScreen3View "3日間無料で試す" button → calls RevenueCatManager.shared.purchase(productID: selectedTier.productID)
- PaywallScreen3View "購入を復元" link → calls RevenueCatManager.shared.restorePurchases()
- AppState init → calls RevenueCatManager.shared.checkSubscriptionStatus() on launch
- RootView gates MainTabView behind appState.isSubscribed check
```

---

## HOW TO USE THESE PROMPTS

1. Create a new Xcode project: SwiftUI, iOS, named "PashaCalo", bundle ID "com.yourname.pashacalo"
2. Open the project folder in Cursor
3. Open Cursor Composer (Cmd + I)
4. Paste Prompt 1. Wait for it to finish. Review the output.
5. Paste Prompt 2. Wait. Review.
6. Continue in order through Prompt 14.
7. Never skip a prompt. Never run two prompts at once.
8. If Cursor makes an error on a prompt, fix it before moving to the next one.
