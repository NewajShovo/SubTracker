# SubTracker Purchase Flow Diagram

## Complete User Journey

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          APP LAUNCH                                      │
│                              ↓                                           │
│                      FeatureManager checks                               │
│                      StoreManager for Pro status                         │
└─────────────────────────────────────────────────────────────────────────┘
                                   ↓
                          ┌────────┴────────┐
                          │                 │
                    FREE USER          PRO USER
                          │                 │
                          ↓                 ↓
    ┌─────────────────────────────────────────────────────────┐
    │                                                           │
    │  FREE USER EXPERIENCE                  PRO USER          │
    │                                        EXPERIENCE         │
    │  Dashboard Tab                                           │
    │  ┌──────────────────────┐            Dashboard Tab      │
    │  │ Good evening, Shovo  │            ┌────────────────┐ │
    │  │ Your subscriptions   │ 3/5 ←      │ Good evening   │ │
    │  └──────────────────────┘            │ Your subs      │ │
    │                                       └────────────────┘ │
    │  Shows counter (3/5)                 No counter          │
    │  Shows warning at 4/5                No limits           │
    │  Shows limit banner at 5/5           All features        │
    │                                                           │
    └─────────────────────────────────────────────────────────┘
                          │
                          ↓
            User tries to add 6th subscription
                          │
                          ↓
    ┌─────────────────────────────────────────────────────────┐
    │                 LIMIT CHECK                             │
    │                                                          │
    │  if featureManager.canAddSubscription(count) {          │
    │      → Allow                                            │
    │  } else {                                               │
    │      → Show SubscriptionLimitView                       │
    │  }                                                      │
    └─────────────────────────────────────────────────────────┘
                          │
                          ↓ (Limit reached)
    ┌─────────────────────────────────────────────────────────┐
    │          SUBSCRIPTION LIMIT DIALOG                       │
    │                                                          │
    │          ⚠️                                              │
    │     Subscription Limit Reached                          │
    │                                                          │
    │  You've reached the free limit                          │
    │  of 5 subscriptions.                                    │
    │                                                          │
    │  ┌────────────────────────┐                            │
    │  │  👑 Upgrade to Pro     │                            │
    │  └────────────────────────┘                            │
    │                                                          │
    │  [ Maybe Later ]                                        │
    └─────────────────────────────────────────────────────────┘
                          │
                          ↓ (Taps "Upgrade to Pro")
    ┌─────────────────────────────────────────────────────────┐
    │                    PAYWALL VIEW                          │
    │                                                          │
    │              👑                                          │
    │          Unlock Pro                                     │
    │                                                          │
    │    Get unlimited subscriptions                          │
    │    and advanced features                                │
    │                                                          │
    │  ────────────────────────────────────                   │
    │                                                          │
    │  ✓ Unlimited Subscriptions                             │
    │  ✓ Advanced Analytics                                  │
    │  ✓ iCloud Sync                                         │
    │  ✓ Multiple Widgets                                    │
    │  ✓ Smart Reminders                                     │
    │  ✓ Export Data                                         │
    │  ✓ Multiple Currencies                                 │
    │  ✓ Priority Support                                    │
    │                                                          │
    │  ────────────────────────────────────                   │
    │                                                          │
    │  ┌────────────────────────────────────┐                │
    │  │  🏷️ BEST VALUE                    │                │
    │  │  Yearly Pro              $14.99    │ ← Selected     │
    │  │  per year                      ✓   │                │
    │  │  Save 37%                          │                │
    │  └────────────────────────────────────┘                │
    │                                                          │
    │  ┌────────────────────────────────────┐                │
    │  │  Monthly Pro             $1.99     │                │
    │  │  per month                     ○   │                │
    │  └────────────────────────────────────┘                │
    │                                                          │
    │  ┌────────────────────────────────────┐                │
    │  │     Subscribe Now                  │                │
    │  └────────────────────────────────────┘                │
    │                                                          │
    │         Restore Purchases                               │
    └─────────────────────────────────────────────────────────┘
                          │
                          ↓ (Taps "Subscribe Now")
    ┌─────────────────────────────────────────────────────────┐
    │               STOREKIT PURCHASE FLOW                     │
    │                                                          │
    │  1. StoreManager.purchase(product)                      │
    │     ↓                                                    │
    │  2. Product.purchase() → Shows Apple dialog             │
    │     ↓                                                    │
    │  3. User confirms with Face ID/Touch ID                 │
    │     ↓                                                    │
    │  4. Transaction verified automatically                  │
    │     ↓                                                    │
    │  5. Transaction finished                                │
    │     ↓                                                    │
    │  6. StoreManager updates purchasedProductIDs            │
    │     ↓                                                    │
    │  7. StoreManager.isPro = true                           │
    │     ↓                                                    │
    │  8. FeatureManager.isPro = true                         │
    │     ↓                                                    │
    │  9. UI updates automatically (@Published)               │
    └─────────────────────────────────────────────────────────┘
                          │
                          ↓
    ┌─────────────────────────────────────────────────────────┐
    │               POST-PURCHASE STATE                        │
    │                                                          │
    │  Dashboard Tab:                                         │
    │  - Counter badge disappears                             │
    │  - Warning banners disappear                            │
    │  - Can add unlimited subscriptions                      │
    │                                                          │
    │  Settings Tab:                                          │
    │  ┌────────────────────────────────────┐                │
    │  │ 👑 Pro Subscriber                  │                │
    │  │ Thank you for your support!   ✓   │                │
    │  └────────────────────────────────────┘                │
    │                                                          │
    │  Analytics Tab:                                         │
    │  - Full advanced analytics unlocked                     │
    │                                                          │
    │  Future Features:                                       │
    │  - iCloud Sync enabled                                  │
    │  - Export features enabled                              │
    │  - Multiple widgets available                           │
    └─────────────────────────────────────────────────────────┘
```

## Alternative Entry Points to Paywall

```
Entry Point 1: Dashboard Limit Banner
┌────────────────────────────────┐
│ ⚠️ Almost at Your Limit        │
│ 4 of 5 subscriptions remaining │
│                                │
│ [Upgrade to Pro]     ──────────┼──┐
└────────────────────────────────┘  │
                                    ↓
                               PaywallView


Entry Point 2: Settings Tab
┌────────────────────────────────┐
│ Subscription                   │
│ ┌────────────────────────────┐ │
│ │ 👑 Upgrade to Pro      →   │─┼──┐
│ │ Unlock all features        │ │  │
│ └────────────────────────────┘ │  ↓
└────────────────────────────────┘ PaywallView


Entry Point 3: Add Button (at limit)
Tap + Button → Limit Check → SubscriptionLimitView
                                      │
                                      ↓
                              [Upgrade to Pro]
                                      │
                                      ↓
                                 PaywallView
```

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                              │
│                                                                  │
│  StoreKit 2 (Apple)                                             │
│       ↓                                                          │
│  StoreManager (@MainActor)                                      │
│   - products: [Product]                                         │
│   - purchasedProductIDs: Set<String>                            │
│   - isPro: Bool                                                 │
│       ↓                                                          │
│  FeatureManager (@MainActor)                                    │
│   - isPro: Bool (synced from StoreManager)                      │
│   - canAddSubscription() → Bool                                 │
│   - hasAdvancedAnalytics() → Bool                               │
│   - etc.                                                        │
└─────────────────────────────────────────────────────────────────┘
                          │ (@Published properties)
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│                          UI LAYER                               │
│                                                                  │
│  ContentView (TabView)                                          │
│   ├─ DashboardView                                              │
│   │   @StateObject featureManager                               │
│   │   Shows: counter, banners, limits                           │
│   │                                                              │
│   ├─ AllSubscriptionsView                                       │
│   │   Full list access                                          │
│   │                                                              │
│   ├─ AnalyticsView                                              │
│   │   Can add Pro banners for advanced features                 │
│   │                                                              │
│   └─ SettingsView                                               │
│       @StateObject storeManager                                 │
│       Shows: Pro status, upgrade button                         │
│                                                                  │
│  Modal Presentations:                                           │
│   ├─ PaywallView                                                │
│   │   @StateObject storeManager                                 │
│   │   Handles: purchase flow                                    │
│   │                                                              │
│   └─ SubscriptionLimitView                                      │
│       Shows when limit reached                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Transaction Listener

```
App Launch
    ↓
StoreManager.init()
    ↓
Starts Transaction Listener (runs forever)
    ↓
┌──────────────────────────────────┐
│  for await result in             │
│  Transaction.updates {           │
│                                  │
│    Verify transaction            │
│    Update isPro status           │
│    Finish transaction            │
│  }                               │
└──────────────────────────────────┘
    ↑
    │ Listens for:
    │ - New purchases
    │ - Renewals
    │ - Cancellations
    │ - Refunds
    │ - Family Sharing changes
    │
    └─ Updates UI automatically
       via @Published properties
```

## Feature Gate Example

```swift
// In any view
@StateObject private var featureManager = FeatureManager.shared

// Before adding subscription
if featureManager.canAddSubscription(currentCount: subscriptions.count) {
    // ✅ Allow
    modelContext.insert(newSubscription)
} else {
    // ❌ Block
    showingSubscriptionLimit = true
}

// For other features
if featureManager.hasAdvancedAnalytics() {
    // Show advanced charts
} else {
    // Show basic charts + upgrade banner
}

if featureManager.hasExportFeature() {
    // Enable export button
} else {
    // Show "Pro only" badge
}
```

## Testing Flow

```
Development/Testing:
    ↓
StoreKitConfiguration.storekit
    ↓
Mock products with test prices
    ↓
Can purchase without real money
    ↓
Test all flows completely


Production:
    ↓
App Store Connect Products
    ↓
Real product IDs
    ↓
Sandbox Testing Accounts
    ↓
Real purchase flow (no charge)
    ↓
Live Users (real charges)
```

## Restore Purchases Flow

```
User taps "Restore Purchases"
    ↓
StoreManager.restorePurchases()
    ↓
AppStore.sync() (syncs with Apple servers)
    ↓
Transaction.currentEntitlements (checks all active)
    ↓
Updates purchasedProductIDs
    ↓
Sets isPro = true (if any active)
    ↓
UI updates automatically
    ↓
User sees Pro status restored
```

---

**This complete system is now live in your app!** 🚀

Test it by:
1. Running the app
2. Going to Settings tab (4th tab)
3. Tapping "Upgrade to Pro"
4. Seeing the beautiful paywall!

