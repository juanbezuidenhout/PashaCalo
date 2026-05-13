# PashaCalo (パシャカロ) — Cursor Build Prompt

You are building **PashaCalo**, a Japanese-market calorie tracking iOS app built in **Swift + SwiftUI**.
This is a pixel-perfect clone of Cal AI, fully localized for Japan.

---

## Non-Negotiable Rules (Enforce on Every Screen)

1. **NO emojis anywhere in the app.** Not in copy, not in icons, nowhere.
2. **NO dashes in any text.** Use spaces or Japanese punctuation instead.
3. **Noto Sans JP** is the only font used across the entire app.
4. **Liquid glass visual theme** throughout — translucent cards, subtle blurs, soft shadows, frosted glass effects using `.ultraThinMaterial` and `.regularMaterial`.
5. **Japanese tone:** Polite and warm (丁寧語). Never shame the user. Always frame things as progress and possibility. Use "kcal" not "カロリー" for numbers. Use "kg" not "lbs". Use Year/Month/Day date format (例: 2026年5月13日).
6. **No camera functionality.** The app uses photo library uploads only — no live camera.
7. **Lead with value, not features.** Every screen should show the outcome, not explain the mechanism.
8. **Onboarding must be impressive and fun.** Every single onboarding screen must feel polished, animated, and visually exciting.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Auth + Database | Supabase |
| Subscriptions | RevenueCat |
| Food AI Analysis | OpenAI GPT-4o Vision API |
| Push Notifications | APNs via Supabase |
| Analytics | Amplitude |
| Font | Noto Sans JP |

---

## App Architecture

```
PashaCalo/
├── PashaCaloApp.swift          # @main entry point
├── AppState.swift              # ObservableObject: auth state, subscription, onboarding complete
├── RootView.swift              # Routes between Onboarding, Paywall, MainTab
│
├── Models/
│   ├── UserProfile.swift       # sex, dob, height, weight, goal, activity level
│   ├── FoodEntry.swift         # food name (JP), kcal, protein, carbs, fat, fiber, sugar, sodium
│   └── ScanResult.swift        # photo, entries[], mealType, timestamp
│
├── Views/
│   ├── Onboarding/             # All onboarding screens (see below)
│   ├── Auth/                   # AuthView.swift
│   ├── Paywall/                # 3-screen trust sequence
│   ├── Dashboard/              # HomeView, CalorieRingCard, MacroCards
│   ├── Log/                    # PhotoPickerView, AnalysingView, ResultView
│   ├── History/                # HistoryView, WeeklyChartView
│   ├── Progress/               # ProgressView, BMICard, WeeklyEnergyCard
│   ├── Profile/                # ProfileView, PersonalDetailsView, PreferencesView
│   └── Shared/                 # PrimaryButton, LiquidCard, MainTabView
│
├── Services/
│   ├── SupabaseManager.swift   # Auth, DB reads/writes, RLS enforced
│   ├── RevenueCatManager.swift # Subscription status, purchase, restore
│   └── VisionAnalyzer.swift    # GPT-4o Vision call, parse JSON response
│
└── Resources/
    ├── Colors.xcassets          # See color system below
    └── ja.lproj/Localizable.strings
```

---

## Color System

Define these in `Colors.xcassets`:

| Name | Light Mode | Purpose |
|---|---|---|
| `AppBackground` | `#F5F5F0` | Main background (warm off-white) |
| `CardBackground` | `#FFFFFF` | Card surfaces |
| `AccentBlack` | `#1A1A1A` | Primary CTA buttons, selected states |
| `TextPrimary` | `#1A1A1A` | Headings |
| `TextSecondary` | `#6B6B6B` | Subtext, labels |
| `TextTertiary` | `#ADADAD` | Placeholder, legal text |
| `BorderLight` | `#E8E8E8` | Card borders, dividers |
| `RingProtein` | `#FF6B9D` | Protein macro ring |
| `RingCarbs` | `#FF9500` | Carbs macro ring |
| `RingFat` | `#007AFF` | Fat macro ring |
| `RingFiber` | `#AF52DE` | Fiber macro ring |
| `RingSugar` | `#FF2D55` | Sugar macro ring |
| `RingSodium` | `#FFCC00` | Sodium macro ring |
| `HealthyGreen` | `#34C759` | BMI healthy indicator |

---

## Screen-by-Screen Specification

### SCREEN 1: Splash Screen

**Purpose:** App launch, brand impression.

**Layout:**
- Solid white background
- Center: App logo (apple with leaf icon, SF Symbol: `leaf.fill`) + "パシャカロ" in Noto Sans JP Bold, 32pt
- Auto-transitions to Welcome after 1.5 seconds

---

### SCREEN 2: Welcome Screen

**Purpose:** First impression, value proposition, start onboarding.

**Layout:**
- White background
- Top right: Language indicator (日本語 pill, static — no need to be functional for MVP)
- Center: Animated mockup of the app in use (use a static illustration or lottie-style animation showing a phone with food being analysed and "残りカロリー 2199 kcal" on screen)
- Below animation:
  - Heading (28pt Bold): `カロリー管理を、もっと簡単に`
  - Subtext (15pt Regular): `写真を撮るだけで栄養を自動計算`
- Bottom: Full-width black pill button → `はじめる`

---

### SCREEN 3: Onboarding — Gender

**Progress bar:** Step 1 of 9 (thin black line, ~11% filled)

**Layout:**
- Back arrow top left
- Heading (26pt Bold): `性別を教えてください`
- Subtext (14pt): `あなたに合ったプランを作成します`
- 3 large rectangular selection cards (full width, 64pt height, 14pt corner radius):
  - `男性`
  - `女性`
  - `その他`
- Unselected: light gray background, black text
- Selected: solid black background, white text, subtle spring animation on tap
- Bottom: Full-width black pill button → `次へ` (disabled until selection made)

---

### SCREEN 4: Onboarding — Workout Frequency

**Progress bar:** Step 2 of 9

**Layout:**
- Heading: `週に何回運動しますか？`
- Subtext: `目標kcalの計算に使います`
- 3 selection cards with icon + text:
  - Icon: figure.walk → `週0〜2回　たまに動く`
  - Icon: figure.run → `週3〜5回　定期的に運動する`
  - Icon: figure.strengthtraining.traditional → `週6回以上　本格的に鍛えている`
- Same selected/unselected style as Screen 3
- Button: `次へ`

---

### SCREEN 5: Onboarding — Date of Birth

**Progress bar:** Step 3 of 9

**Layout:**
- Heading: `生年月日を教えてください`
- Subtext: `目標kcalの計算に使います`
- Center: 3 vertical `Picker` wheels in `.wheel` style — **Year / Month / Day** (in that order, Japanese convention)
- Selected row: light gray pill highlight, black text
- Button: `次へ`

---

### SCREEN 6: Onboarding — Discovery Source

**Progress bar:** Step 4 of 9

**Layout:**
- Heading: `パシャカロをどこで知りましたか？`
- Scrollable list of selection buttons, each with brand icon on left:
  - Instagram (brand icon)
  - X / Twitter (brand icon)
  - TikTok (brand icon)
  - Facebook (brand icon)
  - YouTube (brand icon)
  - 友人・家族 (person.2.fill icon)
  - App Store (apple logo icon)
  - その他 (ellipsis icon)
- Button: `次へ`

---

### SCREEN 7: Onboarding — Previous App Usage

**Progress bar:** Step 5 of 9

**Layout:**
- Heading: `他のカロリー管理アプリを使ったことはありますか？`
- 2 large cards side by side:
  - Left: `はい` (hand.thumbsup.fill icon)
  - Right: `いいえ` (hand.thumbsdown.fill icon)
- Button: `次へ`

---

### SCREEN 8: Onboarding — Value Graph (Interstitial)

**Progress bar:** Step 6 of 9

**Purpose:** Motivational interstitial. No data collected. Just builds belief.

**Layout:**
- Heading: `継続すれば、必ず結果が出ます`
- Card with line graph:
  - X axis: `1ヶ月目` → `6ヶ月目`
  - Y axis: 体重 (kg)
  - Line 1 (red shaded area, fluctuating): label `一般的なダイエット`
  - Line 2 (solid black, steady downward): label `パシャカロ`
- Subtext below card: `食習慣を記録して、長期的な変化を実感しましょう`
- Button: `次へ`

---

### SCREEN 9: Onboarding — Height and Weight

**Progress bar:** Step 7 of 9

**Layout:**
- Heading: `身長と体重を教えてください`
- Subtext: `目標kcalの計算に使います`
- Toggle: `cm / kg` (metric only — no imperial for Japanese market)
- Two input fields:
  - `身長 (cm)` — numeric keyboard
  - `体重 (kg)` — numeric keyboard with decimal
- Button: `次へ`

---

### SCREEN 10: Onboarding — Goal Weight

**Progress bar:** Step 8 of 9

**Layout:**
- Heading: `目標体重を教えてください`
- Single input field: `目標体重 (kg)`
- Subtext: `現在の体重より少し低い目標が継続しやすいです`
- Button: `次へ`

---

### SCREEN 11: Auth Screen

**Progress bar:** Step 9 of 9

**Purpose:** Account creation to save progress.

**Layout:**
- Background: light gray (`#F0F0F0`)
- Heading (24pt Bold): `進行状況を保存する`
- Subtext: `アカウントを作成して記録を続けましょう`
- 3 stacked pill buttons:
  1. Black background, Apple logo, white text: `Appleでサインイン`
  2. White background, Google logo, gray border: `Googleでサインイン`
  3. White background, envelope icon, gray border: `メールで続ける`
- **Implementation note:** Sign in with Apple is MANDATORY (App Store requirement). Sign in with Google requires Sign in with Apple to also be present.

---

### PAYWALL — 3-Screen Trust Sequence

**This is the exact Cal AI paywall flow. Do not skip any screen.**

#### Paywall Screen 1: Free Trial Offer (NOT the paywall yet)

**Layout:**
- Large gift/present icon (SF Symbol: `gift.fill`) centered, 64pt
- Heading (26pt Bold): `3日間、すべて無料でお試しください`
- Subtext: `登録不要で全機能をご利用いただけます`
- Feature list (icon + text, no bullets):
  - `photo.on.rectangle` → `写真から栄養を自動計算`
  - `chart.bar.fill` → `詳細な栄養バランス分析`
  - `fork.knife` → `コンビニ・外食データベース`
  - `square.and.arrow.up` → `バイラル共有カード`
- Bottom: Black pill button → `無料トライアルを始める`

#### Paywall Screen 2: Trust Builder

**Layout:**
- Bell icon (SF Symbol: `bell.badge.fill`) centered, 64pt
- Heading: `終了の2日前にお知らせします`
- Subtext: `無料期間中はいつでもキャンセルできます。請求は発生しません。`
- 3 trust rows (icon + text):
  - `lock.fill` → `いつでもキャンセル可能`
  - `bell.fill` → `終了2日前にリマインダー送信`
  - `creditcard.fill` → `トライアル中は請求なし`
- Bottom: Black pill button → `わかりました`

#### Paywall Screen 3: The Actual Paywall

**Layout:**
- Heading: `プランを選択してください`
- Social proof row: 5 star icons + `4.8　10,000人以上が利用中`
- 3 pricing cards (tappable, border highlights on selection):
  - **年間プラン** — badge: `最もお得` (green pill) — price: `¥6,800 / 年` — savings label: `月あたり約¥567`
  - **月間プラン** — `¥980 / 月`
  - **週間プラン** — `¥380 / 週`
- Default selected: 年間プラン
- Black pill CTA: `3日間無料で試す`
- Below CTA: gray text link `今はスキップ`
- Legal text (11pt, gray): `3日間の無料トライアル後、選択したプランで自動更新されます。`
- 3 text links: `プライバシーポリシー　利用規約　購入を復元`

---

### MAIN TAB: Dashboard (Home)

**Bottom nav bar (5 tabs):**
1. house.fill → `ホーム` (active = black)
2. chart.line.uptrend.xyaxis → `進捗`
3. **Center: Large black circle, plus.circle.fill icon** → opens photo picker sheet
4. person.2.fill → `グループ`
5. person.fill → `プロフィール`

**Home screen layout (top to bottom):**

1. **Top bar:**
   - Left: "パシャカロ" logo text
   - Right: flame.fill icon in gray pill → streak count (e.g., `0`)

2. **Date carousel:**
   - Horizontal scroll of 7 days
   - Format: `月13` (month + day)
   - Current day: circled in black

3. **Main calorie card:**
   - Large number (e.g., `3164`)
   - Below number: `残りkcal` with a small chevron.up.chevron.down icon (tapping toggles between "残りkcal" and "摂取kcal")
   - Right side: thick circular ring (gray background ring, black progress arc, flame.fill icon in center)

4. **Macro cards (horizontal swipeable, 3 pages):**
   - Page 1: Protein (pink ring, fork.knife icon), Carbs (orange ring, leaf.fill icon), Fat (blue ring, drop.fill icon)
   - Page 2: Fiber (purple ring), Sugar (pink ring), Sodium (yellow ring)
   - Page 3: Apple Health connect card + Steps/Calories burned card
   - Each card shows: `Xg 残り` format
   - Pagination dots below

5. **Recently uploaded section:**
   - Title: `最近の食事`
   - Empty state: placeholder card with `+ ボタンで今日の食事を追加しましょう`
   - Populated state: food photo thumbnail, food name, kcal count

6. **Health Score card:**
   - Title: `健康スコア`
   - Value: `N/A` (until food is logged)
   - Subtext: `食事を記録するとスコアが表示されます`

7. **Water card:**
   - Glass icon, `水分 0 ml`
   - Button: `水分を記録` (white, gray border)

---

### MAIN TAB: Progress

**Layout:**
- Week selector pills at top: `今週　先週　2週前　3週前`
- 3 cards:
  1. **週間エネルギー** — circular bar chart — empty state: `食事を記録するとデータが表示されます`
  2. **消費変化** — table with rows: `3日　7日　14日　30日　90日` — status: `準備中`
  3. **BMI** — large number (calculated from height/weight), status pill (`健康的`, `低体重`, `過体重`, `肥満`), color-coded bar with triangle indicator, legend

---

### MAIN TAB: Groups

**Layout:**
- Header: `グループ`
- Subheader row: `グループを探す` (left) + `+ プライベートグループ` button (right)
- List of group cards:
  - Each card: circular image, group name, member count, description, `+ 参加` button
  - Groups:
    - `フィットネス＆トレーニング` — `10,980人のメンバー`
    - `カロリー管理はじめました` — `14,834人のメンバー`
    - `筋肉増量チャレンジ` — `9,457人のメンバー`
    - `ダイエット応援グループ` — `13,057人のメンバー`

---

### MAIN TAB: Profile

**Layout:**
- Header: `プロフィール`
- User card: avatar circle, crown icon (premium), `名前を設定する` prompt, `ユーザー名を設定する`
- **友達を招待** section: `友達を招待して¥1,000をもらおう`
- **アカウント** section: Personal Details, Preferences, Language, Family Plan
- **目標と記録** section: Apple Health, 栄養目標を編集

**Personal Details sub-screen:**
- 目標体重: `76 kg` + `目標を変更` button
- List rows (label / value / pencil edit icon):
  - 現在の体重 / 67 kg
  - 身長 / 181 cm
  - 生年月日 / 2002年3月31日
  - 性別 / 男性
  - 1日の歩数目標 / 10,000歩

---

### PHOTO LOG FLOW (replaces camera)

**Triggered by tapping the center + tab button.**

1. **Photo picker sheet** — standard iOS PHPickerViewController
2. **Analysing screen** — full screen overlay, `AIが分析中` text with animated dots, circular progress spinner
3. **Result screen** — shows:
   - Photo thumbnail
   - List of detected food items (Japanese name, kcal, protein, carbs, fat)
   - Total kcal for the meal
   - Meal type selector: `朝食　昼食　夕食　間食`
   - Black pill button: `記録する`
   - Gray text link: `修正する` (allows manual edit)

---

### MILESTONES & STREAKS SCREEN

**Accessed from:** Tapping the flame icon on the dashboard top bar.

**Layout:**
- Header: Back arrow (left), Share icon (right)
- Heading: `連続記録`
- Current streak: large number + `日連続`
- Grid of achievement badges (locked = gray, unlocked = black with glow)
- Badge examples: `3日連続`, `7日連続`, `30日連続`, `初めての記録`, `目標達成`

---

## Security Implementation Checklist

Implement all of the following from day one:

- Supabase Row Level Security (RLS) enabled on ALL tables. Users can only read/write their own rows.
- API keys (OpenAI, RevenueCat) stored in `.env` file. Never committed to git. Add `.env` to `.gitignore`.
- Rate limiting on any custom Supabase Edge Functions.
- Account deletion flow built and accessible from Profile settings (mandatory for App Store approval).
- Sign in with Apple implemented (mandatory if any other OAuth provider is present).
- Input validation on all user-submitted fields (height, weight, etc.) — enforce numeric ranges server-side.
- Session expiry: JWT tokens expire after 7 days with refresh token rotation via Supabase.

---

## RevenueCat Subscription Configuration

Products to configure in RevenueCat + App Store Connect:

| Product ID | Type | Price | Duration |
|---|---|---|---|
| `pashacalo_annual` | Auto-renewable | ¥6,800 | 1 year |
| `pashacalo_monthly` | Auto-renewable | ¥980 | 1 month |
| `pashacalo_weekly` | Auto-renewable | ¥380 | 1 week |

- All products include a **3-day free trial**.
- Entitlement ID: `premium`
- Offering ID: `default`

---

## Supabase Database Schema

```sql
-- Users table (extends Supabase auth.users)
create table profiles (
  id uuid references auth.users primary key,
  sex text,
  date_of_birth date,
  height_cm numeric,
  weight_kg numeric,
  goal_weight_kg numeric,
  activity_level text,
  daily_kcal_target int,
  daily_protein_target int,
  daily_carb_target int,
  daily_fat_target int,
  streak_days int default 0,
  created_at timestamptz default now()
);

-- Food log entries
create table food_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  logged_at timestamptz default now(),
  meal_type text, -- 朝食, 昼食, 夕食, 間食
  food_name_jp text,
  kcal int,
  protein_g numeric,
  carbs_g numeric,
  fat_g numeric,
  fiber_g numeric,
  sugar_g numeric,
  sodium_mg numeric,
  photo_url text
);

-- Enable RLS
alter table profiles enable row level security;
alter table food_entries enable row level security;

-- RLS Policies
create policy "Users can only access own profile"
  on profiles for all using (auth.uid() = id);

create policy "Users can only access own food entries"
  on food_entries for all using (auth.uid() = user_id);
```

---

## Build Order for Cursor

Build in this exact order to avoid dependency issues:

1. `AppState.swift` + `RootView.swift` (navigation shell)
2. `Colors.xcassets` (color system)
3. `PrimaryButton.swift` + `LiquidCard.swift` (shared components)
4. All Onboarding screens (Screens 3 through 11) in order
5. `AuthView.swift`
6. Paywall (all 3 screens)
7. `MainTabView.swift`
8. `DashboardView.swift` (Home tab)
9. `PhotoPickerView.swift` + `AnalysingView.swift` + `ResultView.swift` (log flow)
10. `ProgressView.swift`
11. `GroupsView.swift`
12. `ProfileView.swift` + `PersonalDetailsView.swift`
13. `MilestonesView.swift`
14. `SupabaseManager.swift`
15. `RevenueCatManager.swift`
16. `VisionAnalyzer.swift`

---

*This document is the single source of truth. Build exactly what is described here.*
