# SubTracker - Subscription Management App

A modern iOS subscription tracker built with SwiftUI and SwiftData that helps users manage their recurring payments and understand their spending patterns.

## Features (V1 MVP)

### ✅ Core Features Implemented

#### 1. **Add & Manage Subscriptions**
- Manual entry of subscription details
- Quick presets for popular services (Netflix, Spotify, etc.)
- Custom categories (Entertainment, Software, Cloud, Fitness, etc.)
- Flexible billing cycles (Weekly, Monthly, Quarterly, Yearly)
- Payment method tracking
- Customizable reminders
- Notes field for additional details

#### 2. **Dashboard**
- Personalized greeting (Good morning/afternoon/evening)
- At-a-glance monthly and yearly cost overview
- Upcoming payments within 30 days
- Color-coded urgency indicators:
  - 🔴 Red: Due today or overdue
  - 🟠 Orange: Due within 3 days
  - 🟡 Yellow: Due within 7 days
  - 🟢 Green: Due later

#### 3. **All Subscriptions View**
- Complete list of all subscriptions
- Organized by category
- Filter between active and inactive subscriptions
- Quick access to subscription details

#### 4. **Analytics**
- Total monthly and yearly spending
- Category breakdown with pie chart
- Average cost per subscription
- Top 3 most expensive subscriptions
- Visual insights into spending patterns

#### 5. **Subscription Details**
- Full subscription information
- Cost breakdown (weekly, monthly, yearly)
- Next payment date and countdown
- Payment history view
- Edit and delete functionality

## Technical Architecture

### Built With
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Persistent data storage with @Model
- **Swift Charts**: Data visualization for analytics
- **Swift 6.0+**: Latest language features

### Data Model

```swift
@Model
final class Subscription {
    var name: String
    var category: Category
    var price: Decimal
    var currency: String
    var billingCycle: BillingCycle
    var nextPaymentDate: Date
    var paymentMethod: String
    var reminderDaysBefore: Int
    var notes: String
    var isActive: Bool
    var iconName: String
    var color: String
}
```

### Key Design Patterns
- **MVVM Architecture**: Separation of concerns with SwiftUI views and SwiftData models
- **Reactive Updates**: @Query for automatic UI updates when data changes
- **Computed Properties**: Dynamic calculations for monthly/yearly equivalents
- **Predicates**: Filtered queries for active/inactive subscriptions
- **Reusable Components**: Modular view components (CostCard, SubscriptionRow, etc.)

## File Structure

```
SubTracker/
├── Models/
│   ├── Subscription.swift          # Core data model
│   └── SubscriptionPreset.swift    # Preset subscriptions
│
├── Views/
│   ├── ContentView.swift           # Tab bar container
│   ├── DashboardView.swift         # Main dashboard
│   ├── AddSubscriptionView.swift   # Add/Edit form
│   ├── SubscriptionDetailView.swift # Detail view
│   ├── AllSubscriptionsView.swift  # List view
│   └── AnalyticsView.swift         # Analytics & insights
│
├── Components/
│   ├── CostCard.swift             # Cost display card
│   ├── SubscriptionRow.swift      # Subscription list item
│   └── DetailRow.swift            # Detail information row
│
└── SubTrackerApp.swift            # App entry point
```

## Roadmap

### Phase 2: Notifications
- [ ] Local notifications for upcoming payments
- [ ] Configurable reminder preferences
- [ ] Notification actions (snooze, view details)

### Phase 3: Widgets
- [ ] Small widget: Next upcoming payment
- [ ] Medium widget: Multiple upcoming payments
- [ ] Large widget: Monthly overview

### Phase 4: Pro Features
- [ ] iCloud sync across devices
- [ ] Multiple currency support
- [ ] Export to CSV/PDF
- [ ] Payment history tracking
- [ ] Custom categories
- [ ] Family/shared subscriptions
- [ ] Advanced analytics
- [ ] Subscription review prompts

### Phase 5: Advanced Features
- [ ] Calendar integration
- [ ] Siri shortcuts
- [ ] Apple Watch companion app
- [ ] Dark mode optimization
- [ ] App Intents for Shortcuts

### Phase 6: Beyond Subscriptions
- [ ] Bills tracking
- [ ] Insurance renewal tracking
- [ ] Warranty expiration tracking
- [ ] Document expiration (passports, licenses)
- [ ] Domain renewal tracking

## Monetization Strategy

### Free Tier
- Up to 5 subscriptions
- Basic dashboard
- Basic notifications
- Basic widget

### Pro Subscription ($1.99/month or $14.99/year)
- Unlimited subscriptions
- Advanced analytics
- Multiple widgets
- Custom categories
- Payment history
- iCloud sync
- Advanced reminders
- Export functionality
- Multiple currencies
- Priority support

## Getting Started

### Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 6.0+

### Installation
1. Clone the repository
2. Open `SubTracker.xcodeproj` in Xcode
3. Build and run on your device or simulator

### First Launch
1. Tap the + button to add your first subscription
2. Either choose from presets or create a custom subscription
3. View your dashboard for spending overview
4. Explore analytics to understand your spending patterns

## Design Philosophy

### User-Centric Design
- **Immediate Value**: Show total spending upfront
- **Visual Clarity**: Color-coded urgency indicators
- **Honest Communication**: No false promises about automation
- **Progressive Disclosure**: Advanced features available but not overwhelming

### Privacy First
- **On-Device Storage**: All data stored locally with SwiftData
- **No Tracking**: No analytics or user tracking
- **Optional Sync**: iCloud sync is opt-in (Pro feature)

### Performance
- **Efficient Queries**: SwiftData predicates for filtered views
- **Computed Values**: Real-time calculations without database overhead
- **Lazy Loading**: ScrollView-based layouts for smooth performance

## Contributing

This is currently a personal project, but suggestions and feedback are welcome!

## License

Copyright © 2026 Shovo. All rights reserved.

---

**Built with ❤️ using SwiftUI**
