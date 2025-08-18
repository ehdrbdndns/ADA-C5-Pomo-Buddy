# Project: Focus Buddy Timer (v1.1)

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

*   **Seed (or RewardItem)**: The visual unit of reward. One is earned only upon the successful completion of a FocusSession.

*   **AppState**: The clearly defined states of the app's timer logic. (앱 타이머 로직의 명확한 상태입니다.)
    *   `Idle`
    *   `Focusing`
    *   `Breaking`
    *   `Paused`

*   **Character (New)**: The user's swappable "focus buddy." Its visual appearance and animations are determined by the selected character type (e.g., Hamster, Cat, etc.). (사용자가 선택 가능한 '포커스 버디'입니다. 선택된 종류에 따라 모습과 애니메이션이 달라집니다.)

*   **CharacterState (New)**: The state of the character's appearance and behavior, which is determined by the current `AppState`. (현재 AppState에 따라 결정되는 캐릭터의 행동 상태입니다.)
    *   **Idle**: Default state before the timer starts. (타이머 시작 전 기본 상태입니다.)
    *   **PerformingAction**: The character's state during `Focusing`. Each character has a unique action. (집중 상태. 캐릭터별 고유 행동 수행. 예: 햄스터는 쳇바퀴 돌리기, 식물은 햇빛 흡수하기)
    *   **Resting**: The character's state during `Breaking`. (휴식 상태. 잠을 자거나 편안히 쉬는 모습입니다.)

## 3. Architecture and Structure

### 3.1. Architecture Pattern
The project will be built using the **MVVM (Model-View-ViewModel)** pattern. This choice is based on its excellent synergy with SwiftUI's declarative nature, providing a clear separation between data logic (Model), UI (View), and the state/logic that connects them (ViewModel).

### 3.2. Core Technologies
*   **UI Framework**: SwiftUI
*   **Data Persistence**: SwiftData

### 3.3. Folder Structure
The following directory structure will be created within `ADA-C5-Pomo Buddy/ADA-C5-Pomo Buddy/` to organize the codebase:
*   `/Models`: Contains SwiftData models for data persistence (e.g., `TimerSettings`, `FocusLog`).
*   `/Views`: Contains all SwiftUI views for the application's UI (e.g., `TimerView`, `SettingsView`).
*   `/ViewModels`: Contains the ViewModel classes that manage the logic and state for the Views.
*   `/Global`: Holds globally accessible constants, enums, or helper functions (e.g., `AppState`).
*   `/Theme`: Manages the design system, including colors, fonts, and character-specific themes.

### 3.4. Design System Principles
*   **Character-Centric Theme**: The app's color scheme is primarily determined by the selected character's unique theme colors.
*   **State-Driven Colors**: Timer states (`Focusing`, `Breaking`, `Idle`) are visually represented by adjusting the tone (e.g., saturation, brightness) of the base character colors, ensuring both brand identity and state clarity.
*   **Appearance Support**: Both Light and Dark modes will be fully supported.

### 3.5. Development Principles
*   **SOLID**: We will adhere to SOLID principles (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion) to build a robust, maintainable, and scalable codebase.

## 4. Development Workflow

### 4.1. Logic-Before-Code Confirmation Principle
To ensure perfect alignment and prevent rework, the AI partner (Gemini) must receive explicit approval from the lead developer (User) on the intended logic *before* generating or modifying any code.

**Process:**
1.  **Proposal:** For any new file or modification, Gemini will first propose the high-level goal.
2.  **Logic Explanation:** Gemini will then provide a detailed, step-by-step explanation of the internal logic of each function and class in plain text.
3.  **User Approval:** The lead developer will review the logic and give explicit approval to proceed.
4.  **Code Generation:** Only after receiving approval will Gemini generate the corresponding code, including skeletons or boilerplate.

### 4.2. Mental Walkthrough Principle
To enhance accuracy and prevent logical errors, Gemini will perform an internal 'mental walkthrough' of user scenarios before proposing logic.

**Process:**
1.  **Identify Scenarios:** Before defining the logic for a feature, identify the primary user interaction paths (e.g., start -> pause -> resume, start -> finish -> auto-start break).
2.  **Simulate State Changes:** For each scenario, trace the expected changes in all relevant state variables (`timerState`, `timeRemaining`, etc.) at each step.
3.  **Verify Logic:** Based on the simulation, verify that the proposed functions and logic correctly handle all transitions, edge cases, and dependencies.
4.  **Propose Verified Logic:** The final logic proposed to the user will be the result of this internal verification process.
