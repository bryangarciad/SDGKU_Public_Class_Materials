# 📱 WatchOS Design Principles - Teaching Guide

## Course: MDI 112 - Class 1
## Duration: 3 Hours
## Project: HealthPulse - Calories & Water Tracker

---

## 🎯 Learning Objectives

By the end of this session, students will:
1. Understand key UX design principles for wearable devices
2. Implement a complete WatchOS app using SwiftUI
3. Work with local storage (UserDefaults)
4. Integrate external APIs
5. Implement haptic feedback for enhanced UX

---

## 📚 Wearable Design Principles (Reference)

Based on [UX Design Institute](https://www.uxdesigninstitute.com/blog/designing-for-wearables/) and [Usability Geek](https://usabilitygeek.com/wearable-devices-user-experience/):

| Principle | Description | App Implementation |
|-----------|-------------|-------------------|
| **Glanceability** | Info visible at a quick glance | Progress rings on dashboard |
| **Keep it Simple** | Limited, focused functionality | Only calories + water tracking |
| **Minimalistic Interface** | Sharp contrast, basic typography | Clean dark theme, bold numbers |
| **Privacy** | Sensitive data protection | Local-only storage |
| **Fashionability** | Aesthetically pleasing | Modern, colorful design |
| **Quick Interactions** | No complex gestures | Pre-set quick-add buttons |

---

## 🗂️ Project Structure

```
MDI112Class1WatchDesignPrinciples Watch App/
├── Models/
│   ├── DiaryEntry.swift          # Data model for entries
│   ├── UserGoals.swift           # User preferences
│   └── MotivationalQuote.swift   # API response model
├── Services/
│   ├── StorageManager.swift      # UserDefaults persistence
│   ├── MotivationalQuoteService.swift  # API integration
│   └── HapticManager.swift       # Haptic feedback
├── ViewModels/
│   └── HealthViewModel.swift     # Business logic (MVVM)
├── Views/
│   ├── MainDashboardView.swift   # Home screen
│   ├── AddEntryView.swift        # Add calories/water
│   ├── GoalsSettingsView.swift   # User goals settings
│   └── Components/
│       ├── ProgressRingView.swift    # Reusable progress ring
│       └── QuoteOverlayView.swift    # Motivational quote overlay
├── ContentView.swift             # Root view
└── MDI112Class1WatchDesignPrinciplesApp.swift  # App entry
```

---

## ⏱️ 3-Hour Class Schedule

### Hour 1: Theory & Project Setup (60 min)

#### 1.1 Introduction (15 min)
- Open `presentation.html` in browser for slides
- Discuss wearable UX challenges:
  - Small screen real estate
  - Limited interaction time (glances)
  - Battery constraints
  - Context of use (on-the-go)
- Review the 7 design principles from reference articles

#### 1.2 Project Overview (10 min)
- Demonstrate the finished app
- Walk through the feature list:
  - Calories tracking with progress
  - Water intake tracking
  - Goal setting with persistence
  - Motivational quotes from API
  - Haptic feedback

#### 1.3 Create Xcode Project (10 min)
```
Steps:
1. Open Xcode → Create New Project
2. Select watchOS → App
3. Name: MDI112Class1WatchDesignPrinciples
4. Interface: SwiftUI
5. Life Cycle: SwiftUI App
```

#### 1.4 Create Folder Structure (10 min)
```
Right-click on Watch App folder:
1. New Group → "Models"
2. New Group → "Services"
3. New Group → "ViewModels"
4. New Group → "Views"
5. Inside Views → New Group → "Components"
```

#### 1.5 Models Implementation (15 min)

**DiaryEntry.swift** - Explain:
- `Identifiable` for SwiftUI lists
- `Codable` for JSON encoding (storage)
- `EntryType` enum with computed properties

```swift
// Key concepts to highlight:
struct DiaryEntry: Identifiable, Codable {
    let id: UUID                    // Unique identifier
    let type: EntryType             // Calories or Water
    let value: Double               // Amount
    let timestamp: Date             // When recorded
}

enum EntryType: String, Codable {
    case calories = "calories"
    case water = "water"
    
    var icon: String { ... }        // Computed property
    var unit: String { ... }
}
```

**UserGoals.swift** - Explain:
- Simple struct for preferences
- Default values for first-time users

**MotivationalQuote.swift** - Explain:
- API response mapping
- Nested struct for JSON structure

---

### Hour 2: Services & ViewModel (60 min)

#### 2.1 StorageManager Service (20 min)

**Key Concepts:**
- Singleton pattern (`static let shared`)
- `UserDefaults` for simple persistence
- `JSONEncoder/JSONDecoder` for complex types

```swift
// Teaching points:
class StorageManager {
    static let shared = StorageManager()  // Singleton
    private init() {}                      // Private init
    
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Save with encoding
    func saveGoals(_ goals: UserGoals) {
        if let encoded = try? encoder.encode(goals) {
            defaults.set(encoded, forKey: Keys.userGoals)
        }
    }
    
    // Load with decoding
    func loadGoals() -> UserGoals {
        guard let data = defaults.data(forKey: Keys.userGoals),
              let goals = try? decoder.decode(...) else {
            return UserGoals.defaultGoals  // Fallback
        }
        return goals
    }
}
```

**Discuss Design Principle:** Offline-first approach for wearables

#### 2.2 MotivationalQuoteService (15 min)

**Key Concepts:**
- `async/await` for network calls
- Error handling with fallbacks
- API integration basics

```swift
// Teaching points:
func fetchQuote() async -> MotivationalQuote {
    // 1. Create URL
    guard let url = URL(string: apiURL) else {
        return getRandomFallbackQuote()  // Graceful fallback
    }
    
    do {
        // 2. Async network call
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // 3. Decode JSON
        let responses = try JSONDecoder().decode([...].self, from: data)
        
        // 4. Return result
        return MotivationalQuote(quote: response.q, author: response.a)
    } catch {
        // 5. Error handling
        return getRandomFallbackQuote()
    }
}
```

**API Used:** [ZenQuotes API](https://zenquotes.io/api/random) - Free, no auth

**Discuss Design Principle:** Always have fallback content for offline use

#### 2.3 HapticManager Service (10 min)

**Key Concepts:**
- `WKInterfaceDevice` for haptics
- Different haptic types and their uses

```swift
import WatchKit

class HapticManager {
    static let shared = HapticManager()
    
    func playSuccess() {
        WKInterfaceDevice.current().play(.success)
    }
    
    func playClick() {
        WKInterfaceDevice.current().play(.click)
    }
    
    // Other haptic types: .notification, .directionUp, .failure
}
```

**Live Demo:** Test each haptic type on device/simulator

**Discuss Design Principle:** Physical feedback without requiring visual attention

#### 2.4 HealthViewModel (15 min)

**Key Concepts:**
- MVVM architecture pattern
- `@Published` properties for UI binding
- `@MainActor` for UI updates

```swift
@MainActor
class HealthViewModel: ObservableObject {
    // Published = triggers UI updates
    @Published var todayCalories: Double = 0
    @Published var todayWater: Double = 0
    @Published var goals: UserGoals
    
    // Computed properties for progress
    var caloriesProgress: Double {
        min(todayCalories / goals.dailyCaloriesGoal, 1.0)
    }
    
    // Actions that modify state
    func addCalories(_ amount: Double) {
        let entry = DiaryEntry(type: .calories, value: amount)
        storage.addEntry(entry)
        todayCalories += amount
        haptics.playDirectionUp()
        
        if caloriesGoalMet {
            haptics.playNotification()  // Celebrate!
        }
        
        fetchQuoteAfterEntry()  // Show motivation
    }
}
```

**Discuss:** Single source of truth for UI state

---

### Hour 3: Views & Polish (60 min)

#### 3.1 ProgressRingView Component (10 min)

**Key Concepts:**
- Reusable SwiftUI components
- `Circle()` with `.trim()` for progress
- Animation with `.animation()`

```swift
struct ProgressRingView: View {
    let progress: Double  // 0.0 to 1.0
    let icon: String
    let color: Color
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            
            // Icon
            Image(systemName: icon)
        }
    }
}
```

**Discuss Design Principle:** Glanceability - visual progress at a glance

#### 3.2 MainDashboardView (15 min)

**Key Concepts:**
- Layout with `VStack`, `HStack`
- `NavigationLink` for navigation
- Overlay for quote display

```swift
struct MainDashboardView: View {
    @ObservedObject var viewModel: HealthViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                // Progress rings side by side
                HStack {
                    ProgressRingView(progress: viewModel.caloriesProgress, ...)
                    ProgressRingView(progress: viewModel.waterProgress, ...)
                }
                
                // Quick add buttons
                HStack {
                    NavigationLink(destination: AddEntryView(...)) {
                        QuickAddButton(icon: "plus", label: "Calories")
                    }
                    NavigationLink(destination: AddEntryView(...)) {
                        QuickAddButton(icon: "plus", label: "Water")
                    }
                }
            }
        }
        .overlay {
            if viewModel.showQuoteOverlay {
                QuoteOverlayView(...)
            }
        }
    }
}
```

**Discuss Design Principle:** Minimalistic interface with essential info only

#### 3.3 AddEntryView (15 min)

**Key Concepts:**
- Pre-defined quick-add options
- State management with `@State`
- Environment dismiss action

```swift
struct AddEntryView: View {
    @ObservedObject var viewModel: HealthViewModel
    @State private var selectedAmount: Double = 0
    @Environment(\.dismiss) private var dismiss
    
    private var quickAddOptions: [Double] {
        entryType == .calories ? [100, 200, 300, 500] : [100, 200, 250, 500]
    }
    
    var body: some View {
        // Quick-add buttons grid
        LazyVGrid(columns: [...]) {
            ForEach(quickAddOptions, id: \.self) { amount in
                Button {
                    selectedAmount = amount
                } label: {
                    Text("+\(Int(amount))")
                }
            }
        }
        
        // Add button
        Button {
            viewModel.addCalories(selectedAmount)
            dismiss()  // Go back
        } label: {
            Text("Add")
        }
    }
}
```

**Discuss Design Principle:** Quick interactions with pre-set options

#### 3.4 GoalsSettingsView (10 min)

**Key Concepts:**
- Preset options for quick selection
- Saving preferences to storage

#### 3.5 Testing & Demo (10 min)

1. Run on Apple Watch Simulator
2. Test all features:
   - Add calories → See progress update
   - Add water → See motivational quote
   - Reach goal → Hear notification haptic
   - Change goals → Verify persistence
3. Discuss real device testing

---

## 🎨 Design Principles Summary

| Screen | Principle Applied |
|--------|-------------------|
| Dashboard | **Glanceability** - All key info visible |
| Add Entry | **Quick Interactions** - Pre-set options |
| Goals | **Personalization** - Custom targets |
| Quote Overlay | **Delight** - Positive reinforcement |
| Haptics | **Feedback** - Physical confirmation |

---

## 📋 Student Exercises

### Exercise 1: Add a New Entry Type (Easy)
Add a third tracking category: "Steps"
- Add `case steps` to `EntryType`
- Add a third progress ring to dashboard
- Create quick-add options for steps

### Exercise 2: Improve the Quote Display (Medium)
- Save the last quote shown
- Allow users to "favorite" quotes
- Display favorites in a new view

### Exercise 3: Add Weekly Summary (Advanced)
- Create a new view showing 7-day history
- Use a bar chart to visualize daily totals
- Calculate weekly averages

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| Haptics not working | Test on real device, not simulator |
| API not responding | Check network, use fallback quotes |
| Data not persisting | Verify UserDefaults keys match |
| Progress not updating | Ensure @Published properties trigger |

---

## 📖 References

- [Designing for Wearables - UX Design Institute](https://www.uxdesigninstitute.com/blog/designing-for-wearables/)
- [Wearable Devices UX - Usability Geek](https://usabilitygeek.com/wearable-devices-user-experience/)
- [Apple Watch Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/watchos)
- [ZenQuotes API](https://zenquotes.io/)

---

## ✅ Checklist for Students

- [ ] Understand MVVM architecture
- [ ] Can create SwiftUI views for WatchOS
- [ ] Can use UserDefaults for persistence
- [ ] Can make API calls with async/await
- [ ] Can implement haptic feedback
- [ ] Understand wearable UX principles

---

## 👨‍🏫 Teaching Tips

1. **Start with WHY** - Explain design principles before coding
2. **Live code together** - Don't just show, build WITH students
3. **Incremental testing** - Run the app after each major section
4. **Encourage questions** - Pause frequently for clarification
5. **Real device demo** - If possible, show on actual Apple Watch
6. **Relate to familiar apps** - Reference Apple Fitness, etc.

---

*Happy Teaching! 🍎⌚*
