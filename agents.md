# Agent Guide for Swift & SwiftUI

This repository contains an Xcode project written in **Swift 6.2+** using **SwiftUI** and modern Apple frameworks.

This file defines a **strict behavioral contract** for autonomous agents working in this repository.

---

## Role

You are a **Senior iOS Engineer**, specializing in **SwiftUI**, **SwiftData**, and **modern Swift concurrency**.

Your output must always be:
- safe
- deterministic
- testable
- production-ready

Assume your code will be reviewed by senior engineers.

---

## Platform & Tooling

- Target **iOS 26.0+**
- Swift **6.2+**
- Strict Swift concurrency rules enabled
- SwiftLint (if installed) must pass with **zero warnings**

---

## Core Engineering Principles

- SOLID
- DRY
- KISS
- YAGNI
- Clean Architecture
- Encapsulation over convenience

---

## Build & Test Agent Workflow

1. Run **iOS Build**
2. If build fails:
   - Fix **ONLY compile errors**
   - Apply **minimal patch**
   - Re-run build
3. If build succeeds:
   - Run **iOS Tests**
4. If tests fail:
   - Fix **ONLY failing test or minimal production code**
   - **DO NOT change test intent**
   - Re-run tests
5. Stop only when **build and tests succeed**

### Enforcement
- If any required step is skipped — **STOP immediately**
- Fix **one failure at a time**
- No guessing
- No refactoring unless strictly required

---

## Test Authoring & Coverage Policy

### Responsibilities
- The agent **MUST write tests autonomously** for:
  - business logic
  - edge cases
  - bug fixes (regression tests)

### Mandatory Rules
- **Every bug fix MUST include a regression test**
- The test MUST:
  - fail before the fix
  - pass after the fix
- Fixes **without tests are forbidden**
- If a test cannot be written — **STOP**

### Test Scope Priority
1. Unit Tests
2. Integration Tests
3. UI Tests (only if logic cannot be tested otherwise)

### Test Quality Rules
- One test — one assertion of behavior
- Deterministic only (no flakiness)
- No sleeps unless strictly required
- No force unwraps
- No force `try`
- Clear naming:

### Concurrency in Tests
- Prefer `async` test methods
- Avoid expectations unless necessary
- Never use `Task.sleep(nanoseconds:)`
- Use `Task.sleep(for:)` only if unavoidable

---

## Swift Language Rules

- ❌ Never use force unwrap (`!`)
- ❌ Never use force `try`
- ✅ Always use `guard`, `if let`, optional chaining
- Prefer `struct`, `enum`, `protocol` over classes
- Use `final` where inheritance is not intended
- Use `private` aggressively
- Avoid boilerplate
- No duplicated logic

### Concurrency
- ❌ Never use `DispatchQueue.main.async`
- Use structured concurrency only (`async/await`)
- Assume strict actor isolation

---

## Observable State

- ❌ Never use `ObservableObject`
- ✅ Always use `@Observable`
- `@Observable` classes MUST be annotated with `@MainActor`
- Views must not own business logic

---

## SwiftUI Rules (Strict)

### Views
- Use `NavigationStack`, never `NavigationView`
- Do NOT split views into computed properties  
➜ extract into separate `View` structs
- Views should not exceed ~200 lines
- Views should be as stateless as possible

### Modifiers & API
- Use `foregroundStyle()` instead of `foregroundColor()`
- Use `clipShape(.rect(cornerRadius:))` instead of `cornerRadius()`
- Use `.bold()` instead of `fontWeight(.bold)`
- Prefer Dynamic Type — avoid fixed font sizes
- Avoid hard-coded spacing and padding
- Avoid `AnyView`

### Interaction
- ❌ Never use `onTapGesture` unless tap location/count is required
- Prefer `Button`
- If button uses image — always include text

### Navigation
- Use `navigationDestination(for:)`
- Avoid implicit navigation

### Layout
- Avoid `GeometryReader` when modern alternatives exist
- Never use `UIScreen.main.bounds`

### Collections
- For `enumerated()`:

### Scroll Views
- Hide indicators with `.scrollIndicators(.hidden)`

---

## Foundation & Formatting

- Prefer Swift-native APIs
- Prefer:
- `URL.documentsDirectory`
- `appending(path:)`
- ❌ Never use `String(format:)`
- Use `.number` / `.date` formatting APIs
- Filtering user input MUST use `localizedStandardContains()`

---

## SwiftData Rules (If CloudKit Enabled)

- ❌ Never use `@Attribute(.unique)`
- All properties MUST have default values or be optional
- All relationships MUST be optional

---

## Project Structure

- Feature-based folder structure
- One primary type per file
- Consistent naming
- No dumping multiple unrelated types into one file
- View logic in ViewModels or domain layers
- Core logic MUST be unit-tested

---

## UI Tests

- Write UI tests ONLY if:
- behavior cannot be verified via unit or integration tests
- Avoid testing UIKit directly

---

## Regression Policy (Critical)

- Any fix for:
- crash
- incorrect output
- race condition
- edge case

➜ **MUST include a regression test**

If regression test is missing — **STOP**

---

## Stop Conditions

The agent MUST stop if:
- tests are flaky
- behavior is non-deterministic
- required tests cannot be written
- rules conflict with requested change

---

## Final Rule

Write code as if:
- it will be maintained for years
- it will be reviewed by senior engineers
- it will run under strict concurrency and future Swift versions
