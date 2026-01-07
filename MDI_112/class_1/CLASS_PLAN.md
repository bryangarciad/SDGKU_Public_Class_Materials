# MDI 112 - Class 1: Designing User Experience for Wearable Devices
## 3-Hour Hands-On Workshop with Swift/watchOS

---

## 📚 Learning Objectives

By the end of this class, students will be able to:
1. Understand UX principles specific to wearable devices
2. Design interfaces optimized for small screens
3. Implement core features with simplicity in mind
4. Create a functional watchOS app demonstrating best practices

---

## 🎯 Project Overview: "WearableWellness"

A wellness tracking watchOS app that demonstrates:
- **Usability**: Large, easy-to-tap UI elements
- **Core Features**: Simple, focused functionality
- **Device Integration**: Notifications and haptic feedback

---

## ⏰ Class Schedule (3 Hours)

### Hour 1: Theory & Project Setup (60 min)

#### Part 1.1: UX Principles for Wearables (20 min)
- **Who are we designing for?**
  - Tech-savvy early adopters (20s-30s)
  - Familiar with gestures and multiple UIs
  - Above-average income, open-minded

- **The 3 Key Design Principles:**
  1. **Make it Usable**
     - Small display = limited interaction space
     - Consider user activity (walking, running, sitting)
     - Your finger shouldn't block the entire screen
  
  2. **Stick to Core Features**
     - Cannot have too many elements
     - Use simple, BIG UI elements
     - Spread complexity across multiple swipeable screens
  
  3. **View Wearables as Accessories**
     - Quick input devices/shortcuts
     - Bridge between digital and physical
     - Core processing on main device

- **Key Differences from Mobile UX:**
  - Glanceable information (< 2 seconds to understand)
  - Context-aware interactions
  - Haptic feedback over visual/audio

#### Part 1.2: Project Setup in Xcode (40 min)
```
📁 Hands-on: Create new watchOS project
📁 Explore project structure
📁 Understand SwiftUI basics for watchOS
```

**Code Along:**
- Create new Xcode project (watchOS App)
- Name: "WearableWellness"
- Review generated files
- Run on simulator

---

### Hour 2: Building Core Features (60 min)

#### Part 2.1: Main Dashboard (20 min)
**Concept:** Glanceable wellness metrics

```
📁 File: ContentView.swift
📁 Implement: Tab-based navigation
📁 Focus: Large, readable metrics
```

**UX Principles Applied:**
- Large fonts for readability while moving
- High contrast colors
- Minimal text, maximum clarity

#### Part 2.2: Health Metrics View (20 min)
**Concept:** Simple health tracking display

```
📁 File: HealthMetricsView.swift
📁 Implement: Heart rate, steps, calories
📁 Focus: Circular progress indicators
```

**UX Principles Applied:**
- Visual progress indicators (not just numbers)
- Color-coded status (green/yellow/red)
- One metric dominates the screen

#### Part 2.3: Quick Actions View (20 min)
**Concept:** Core features as big buttons

```
📁 File: QuickActionsView.swift
📁 Implement: Start workout, log water, breathing exercise
📁 Focus: Tap-friendly buttons
```

**UX Principles Applied:**
- Buttons large enough for any finger size
- Clear iconography
- Immediate haptic feedback

---

### Hour 3: Advanced Features & Polish (60 min)

#### Part 3.1: Notifications System (15 min)
**Concept:** Non-intrusive alerts

```
📁 File: NotificationManager.swift
📁 Implement: Local notifications
📁 Focus: Contextual, timely alerts
```

**UX Principles Applied:**
- Notifications only when relevant
- Quick actions from notification
- Haptic patterns for different alert types

#### Part 3.2: Settings & Customization (15 min)
**Concept:** User preferences

```
📁 File: SettingsView.swift
📁 Implement: Toggle preferences
📁 Focus: Simple on/off switches
```

**UX Principles Applied:**
- Limit options (decision fatigue)
- Use toggles, not complex forms
- Remember user preferences

#### Part 3.3: Haptic Feedback & Polish (15 min)
**Concept:** Physical feedback

```
📁 File: HapticManager.swift
📁 Implement: Different haptic patterns
📁 Focus: Feedback for user actions
```

**UX Principles Applied:**
- Confirm actions without looking
- Different patterns = different meanings
- Subtle but noticeable

#### Part 3.4: Final Review & Q&A (15 min)
- Run complete app
- Review all UX principles implemented
- Discussion: Future of wearable UX
- Q&A session

---

## 📁 Project File Structure

```
WearableWellness/
├── WearableWellnessApp.swift          # App entry point
├── ContentView.swift                   # Main tab view
├── Views/
│   ├── HealthMetricsView.swift        # Health dashboard
│   ├── QuickActionsView.swift         # Action buttons
│   ├── SettingsView.swift             # User preferences
│   └── Components/
│       ├── MetricCard.swift           # Reusable metric display
│       ├── ActionButton.swift         # Large tap button
│       └── CircularProgress.swift     # Progress indicator
├── Managers/
│   ├── HapticManager.swift            # Haptic feedback
│   └── NotificationManager.swift      # Local notifications
└── Models/
    └── WellnessData.swift             # Data models
```

---

## 🎨 Design Guidelines for Project

### Colors (High Contrast)
- **Primary:** Electric Blue (#007AFF)
- **Success:** Vibrant Green (#34C759)
- **Warning:** Bright Orange (#FF9500)
- **Danger:** Bold Red (#FF3B30)
- **Background:** True Black (#000000)
- **Text:** Pure White (#FFFFFF)

### Typography
- **Metrics:** SF Pro Rounded, 42pt
- **Labels:** SF Pro Text, 14pt
- **Buttons:** SF Pro Text Medium, 17pt

### Spacing
- Minimum tap target: 44x44 points
- Edge padding: 8 points
- Between elements: 12 points

---

## ✅ Assessment Criteria

Students will be evaluated on:
1. **Usability (30%)** - Are UI elements appropriately sized?
2. **Simplicity (25%)** - Is the app focused on core features?
3. **Code Quality (25%)** - Is the code clean and organized?
4. **Creativity (20%)** - Did they add thoughtful enhancements?

---

## 📖 Reference Material

- Article: [Designing A User Experience For Wearable Devices](https://usabilitygeek.com/wearable-devices-user-experience/)
- Apple Human Interface Guidelines: watchOS
- SwiftUI Documentation

---

## 🚀 Extension Activities (Homework)

1. Add a complication for the watch face
2. Implement HealthKit integration
3. Add workout tracking with GPS
4. Create widget for iPhone companion app






