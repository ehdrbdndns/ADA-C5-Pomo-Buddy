# Project: Focus Buddy Timer (v1.2)

## 1. Project Overview

### Project Goal
To develop a cute Pomodoro timer iOS app using SwiftUI, which helps users manage focus/break cycles in an enjoyable way and motivates them through a sense of accomplishment.

### Core UX Vision
To transform the experience of using a timer from a simple utility into an emotional and enjoyable habit-forming process. This is achieved through interaction with a cute character, who acts as the user's "focus buddy." The user forms a positive attachment to the act of focusing. (사용자는 '포커스 버디' 역할을 하는 귀여운 캐릭터와의 상호작용을 통해, 집중하는 행위 자체에 긍정적인 애착을 갖게 됩니다.)

### Our Roles
*   **User**: Lead Developer & Final Decision Maker.
*   **Gemini**: AI Coding Partner & Technical Consultant.

### Single Source of Truth
This GEMINI.md document is the sole specification for this project. All discussions and implementations will be based on the definitions herein.

## 2. Core Domain Concepts

*   **Session**: The fundamental unit of the timer. (타이머의 기본 작동 단위입니다.)
    *   **FocusSession**: A time block for focused work.
    *   **BreakSession**: A time block for resting.

*   **Cycle**: A completed pair of one FocusSession and its subsequent BreakSession.

*   **Seed (or RewardItem)**: The visual unit of reward. One is earned **only upon the successful completion of a FocusSession**. Giving up a session does not earn a seed.

*   **TimerState**: The clearly defined states of the app's timer logic. (앱 타이머 로직의 명확한 상태입니다.)
    *   `Idle`
    *   `Focusing`
    *   `Breaking`
    *   `Paused`

*   **Character**: The user's swappable "focus buddy." Its visual appearance and theme colors are determined by the selected character type.

*   **Auto-Timer**: A user-configurable setting (`isAutoTimerEnabled`). 
    *   When a FocusSession ends, the BreakSession **always** starts automatically.
    *   When a BreakSession ends, the next FocusSession **only** starts automatically if this setting is enabled.

*   **Appearance Setting**: A user-configurable setting (`appearance`) that determines the app's color scheme. The user can choose between **Light Mode** and **Dark Mode**, and this choice overrides the system setting.

*   **Navigation Style**: The main UI is a carousel/pager, not a tab bar. The user navigates between Timer, Settings, and History by swiping left and right.

## 3. Architecture and Structure

### 3.1. Architecture Pattern
The project will be built using the **MVVM (Model-View-ViewModel)** pattern.

### 3.2. Core Technologies
*   **UI Framework**: SwiftUI
*   **Data Persistence**: SwiftData
*   **Localization**: Standard SwiftUI Localization using `.strings` files.

### 3.3. Folder Structure
*   `/Models`: Contains SwiftData models (`TimerSettings`, `FocusLog`).
*   `/Views`: Contains all SwiftUI views.
    *   `/Views/Components`: Contains reusable, smaller view components.
*   `/ViewModels`: Contains the ViewModel classes (`TimerViewModel`).
*   `/Global`: Holds globally accessible enums (`TimerState`).
*   `/Theme`: Manages the design system (`AppColor`, `AppFontSize`, `AppTheme`, etc.).
*   `/Resource`: Contains resources, including language-specific localization files.
    *   `/Resource/en.lproj/Localizable.strings`
    *   `/Resource/ko.lproj/Localizable.strings`

### 3.4. Main View Descriptions
*   **TimerView**: The main screen for the Pomodoro timer operation, character interaction, and session progress.
*   **SettingsView**: A screen where the user can configure timer durations, auto-start preferences, and the app's appearance (Light/Dark Mode).
*   **HistoryView**: (To be implemented) A screen to view logs of past focus sessions.

## 4. Development Workflow

### 4.1. Always-Check-First Principle (Top Priority)
*   **Rule**: Before any response or action (proposing logic, writing code, providing feedback), Gemini **must** first read the latest version of all relevant files to ensure its context is up-to-date.
*   **Rationale**: This prevents providing feedback based on stale information and wasting development time.

### 4.2. Logic-Before-Code Confirmation Principle
To ensure perfect alignment and prevent rework, the AI partner (Gemini) must receive explicit approval from the lead developer (User) on the intended logic *before* generating or modifying any code.

**Process:**
1.  **Proposal:** For any new file or modification, Gemini will first propose the high-level goal.
2.  **Logic Explanation:** Gemini will then provide a detailed, step-by-step explanation of the internal logic of each function and class in plain text.
3.  **User Approval:** The lead developer will review the logic and give explicit approval to proceed.
4.  **Code Generation:** Only after receiving approval will Gemini generate the corresponding code.

### 4.3. Mental Walkthrough Principle
To enhance accuracy and prevent logical errors, Gemini will perform an internal 'mental walkthrough' of user scenarios before proposing logic.

**Process:**
1.  **Identify Scenarios:** Before defining logic, identify the primary user interaction paths (e.g., start -> pause -> resume, start -> finish -> auto-start break).
2.  **Simulate State Changes:** For each scenario, trace the expected changes in all relevant state variables.
3.  **Verify Logic:** Based on the simulation, verify that the proposed functions and logic correctly handle all transitions and edge cases.
4.  **Propose Verified Logic:** The final logic proposed to the user will be the result of this internal verification process.

### 4.4. Atomic Proposal Principle
To ensure clarity and prevent implicit changes, all proposed code modifications will be "atomic."

*   **Principle**: Each proposal from Gemini will contain only a single, indivisible logical change.
*   **Rationale**: This prevents bundling unrelated changes. It allows the lead developer to review and approve each modification granularly, ensuring full understanding and control.
*   **Example**:
    *   **Incorrect (Bundled)**: "I will fix the count bug and also refactor the time properties."
    *   **Correct (Atomic)**: 
        1.  "**Proposal 1:** I will fix the count bug using the 'save and then refetch' method. [Details...] Do you agree?"
        2.  *(After approval)* "**Proposal 2:** Now, I will refactor the time properties for better data integrity using Computed Properties. [Details...] Do you agree?"

### 4.5. Codebase-Grounded Implementation Principle

*   **Core Mandate**: Gemini **must not** write code that references any property, method, or value without first verifying its existence in the current codebase. All code generation must be grounded in direct, recent file analysis.

*   **The Workflow**: Gemini must adhere to this strict, non-negotiable sequence:
    1.  **Deconstruct the Goal**: Clearly state the primary objective (e.g., "Create SettingsView").
    2.  **Map All Dependencies**: Before writing any code, list *every* external file and component the new code will reference. This includes, but is not limited to: ViewModels, Models, Theme files (colors, fonts), custom UI components, and utility classes.
    3.  **Verify Reality via Code**: Use `read_file` or `read_many_files` to read all identified dependency files. This step is mandatory to build an accurate understanding of the current codebase. **No assumptions are permitted.**
    4.  **Announce and Resolve Gaps First**: Compare the implementation plan against the verified reality of the codebase. If any required element (property, method, value) is missing, **STOP**. Announce the specific gap and propose a plan to modify the dependency file *first*.
    5.  **Implement After Verification**: Only when all dependencies are confirmed to exist in the codebase, proceed to write the code for the original goal.

*   **Rationale**: This workflow eradicates errors from "hallucinated" or assumed code. It forces a bottom-up, verifiable implementation process, ensuring all generated code is immediately valid and buildable.

## 5. Code Patterns & Conventions

This section serves as a style guide and a set of instructions for writing consistent code within this project.

### 5.1. Dependency Injection
*   **Rule**: Global, app-wide services (`TimerViewModel`, `ThemeManager`) that conform to the `@Observable` macro are initialized at the app's entry point (`ADA_C5_Pomo_BuddyApp.swift`) and injected into the SwiftUI `Environment`.
*   **Example**:
    ```swift
    // In App struct
    .environment(timerViewModel)
    .environment(themeManager)

    // In a View
    @Environment(TimerViewModel.self) private var viewModel
    @Environment(ThemeManager.self) private var themeManager
    ```

### 5.2. Styling
*   **Rule**: All colors and font sizes must be referenced from the central theme files (`AppColor.swift`, `AppFontSize.swift`). Do not use hardcoded values (e.g., `Color.red`, `fontSize: 12`) in View files.
*   **State-Dependent Styles**: For colors that change based on `TimerState` or `ColorScheme`, use the `ThemeManager` to get the correct `AppTheme` object, then use its properties.
    ```swift
    let theme = themeManager.currentTheme.theme(for: viewModel.timerState, in: colorScheme)
    view.background(theme.background)
    ```
*   **Fixed Styles**: For styles that do not change, use the static properties from `AppFontSize` and `Font.Weight` directly in the view. The base font family is `Quicksand`.
    ```swift
    Text("...").font(.custom("Quicksand", size: AppFontSize.textBase).weight(.medium))
    ```
*   **Reusable View Styles**: For complex, reusable styles like buttons or shadows, create a `ViewModifier` or `ButtonStyle` (e.g., `CustomButtonStyle`, `.shadowLG()`).

### 5.3. Localization
*   **Rule**: All user-facing text must be localized using SwiftUI's standard localization system. Do not use hardcoded strings in View files.
*   **Keys**: Use the `viewName_componentType_identifier` naming convention for keys (e.g., `timerView_button_start`).
*   **Implementation**: Use `Text("key_name")` to have SwiftUI automatically display the correct translation from the `Localizable.strings` files.
    ```swift
    Button(action: {}) {
        Text("timerView_button_start")
    }
    ```

### 5.4. Sub-view Refactoring
*   **Principle**: To improve compiler performance and code readability, complex views must be broken down into smaller, single-purpose sub-views.
*   **Primary Pattern**: Use `private var body: some View` computed properties, typically organized within a `private extension` of the main view. This is the preferred pattern as it provides direct access to the main view's state (like `@Environment` objects) without passing numerous parameters.
*   **Alternative Pattern**: For cases where explicit dependency passing is clearer, `private func body(...) -> some View` that accepts `@Binding` parameters is also acceptable. The choice should be based on clarity and context.
