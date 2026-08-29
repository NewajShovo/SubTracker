# 🧪 Complete Purchase Testing Guide

## Option 1: Quick Test in Simulator (Recommended for Now)

### Step 1: Enable StoreKit Testing in Xcode

1. Open your project in Xcode
2. Click on your **target** (SubTracker) in the project navigator
3. Go to the **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **"In-App Purchase"**

### Step 2: Configure StoreKit Testing

1. In Xcode menu: **Product** → **Scheme** → **Edit Scheme...**
2. Select **Run** in the left sidebar
3. Go to the **Options** tab
4. Under **StoreKit Configuration**, click the dropdown
5. Select **"None"** for now (we'll use manual testing)

### Step 3: Test with Manual Purchases (Easiest Way)

Since you're just starting, the easiest way is to **bypass StoreKit temporarily** and test the UI:

#### A. Test the Paywall UI (Without Real Purchase)

1. Run your app
2. Go to **Settings** tab
3. Tap **"Upgrade to Pro"**
4. You'll see the paywall!

The paywall will show but products might not load without StoreKit configuration. That's OK for now!

#### B. Test Pro Features Directly

Add this temporary code to `FeatureManager.swift` for testing:

```swift
private init() {
    // 🧪 TESTING ONLY - Set to true to test Pro features
    #if DEBUG
    self.isPro = true  // Change to true to test Pro mode
    #else
    // Check Pro status from StoreManager
    Task {
        let store = StoreManager()
        self.isPro = store.isPro
    }
    #endif
}
```

Now:
- Set `isPro = true` → Test Pro features
- Set `isPro = false` → Test free tier limits

### Step 4: Test Free Tier Limits

1. Make sure `isPro = false` in FeatureManager
2. Run the app
3. Add 5 subscriptions (use presets for speed)
4. Try to add a 6th → You'll see the limit dialog!
5. This works without any purchase system

### Step 5: Test the Complete Purchase Flow (Advanced)

For this, you need a proper StoreKit configuration file.

## Option 2: Full StoreKit Testing Configuration

### Create Products.storekit File

1. In Xcode, **File** → **New** → **File...**
2. Search for **"StoreKit Configuration File"**
3. Name it: `Products.storekit`
4. Save it in your project

### Add Test Products

The file I created (`StoreKitConfiguration.storekit`) should be added to your project:

1. In Xcode, right-click your project
2. **Add Files to "SubTracker"...**
3. Select `StoreKitConfiguration.storekit`
4. Make sure **"Copy items if needed"** is checked

### Enable the Configuration

1. **Product** → **Scheme** → **Edit Scheme...**
2. **Run** → **Options** tab
3. **StoreKit Configuration**: Select `StoreKitConfiguration.storekit`
4. Click **Close**

### Test Real Purchases (No Money!)

1. Run the app
2. Go to Settings → Tap "Upgrade to Pro"
3. Select a plan → Tap "Subscribe Now"
4. You'll see a dialog: **"Environment: Xcode"**
5. Tap **"Subscribe"**
6. ✅ You're now Pro! (No credit card needed)

### Verify Purchase Worked

- Settings should show "👑 Pro Subscriber"
- Dashboard should hide the "3/5" counter
- You can add unlimited subscriptions

## 🐛 Troubleshooting

### "No Products Found"

If the paywall shows but no products appear:

**Quick Fix:**
```swift
// In PaywallView.swift, add this for testing:

var body: some View {
    NavigationStack {
        ScrollView {
            // Add this at the top to debug
            if storeManager.products.isEmpty {
                VStack {
                    Text("⚠️ No products loaded")
                    Text("This is normal without StoreKit config")
                        .font(.caption)
                }
                .padding()
            }
            // ... rest of code
        }
    }
}
```

### "Purchase Failed"

This is expected without StoreKit configuration. Use the debug mode instead:
```swift
// In FeatureManager
#if DEBUG
self.isPro = true  // Simulate Pro purchase
#endif
```

## Option 3: Skip StoreKit for Now

Want to keep building features first? Here's how:

### Temporary "Free Pro for Everyone" Mode

In `FeatureManager.swift`:

```swift
private init() {
    // 🎁 Everyone gets Pro for testing!
    #if DEBUG
    self.isPro = true
    print("🧪 DEBUG MODE: Pro features enabled for testing")
    #else
    Task {
        let store = StoreManager()
        self.isPro = store.isPro
    }
    #endif
}
```

Or add a secret button:

```swift
// In SettingsView.swift, add:

#if DEBUG
Section {
    Button("🧪 Toggle Pro (Debug Only)") {
        FeatureManager.shared.isPro.toggle()
    }
} header: {
    Text("Debug")
}
#endif
```

Now you can test Pro features without any purchase!

## My Recommendation

**For right now:**

1. ✅ Use the debug toggle method
2. ✅ Test all your app features (subscriptions, analytics, etc.)
3. ✅ Build the rest of your app
4. ⏰ Set up real StoreKit testing later (before App Store submission)

**Before App Store submission:**

1. Add proper StoreKit configuration
2. Create products in App Store Connect
3. Test with Sandbox accounts
4. Remove all debug code

## Quick Debug Toggle Implementation

Let me update FeatureManager with a debug toggle:

```swift
@MainActor
final class FeatureManager: ObservableObject {
    static let shared = FeatureManager()
    
    @Published var isPro: Bool = false
    
    // Free tier limits
    static let freeSubscriptionLimit = 5
    
    private init() {
        #if DEBUG
        // 🧪 DEBUG MODE: Start with Pro enabled for testing
        // Change this to false to test free tier
        self.isPro = false  // Set to true to test Pro features
        print("🧪 DEBUG MODE: isPro = \(isPro)")
        #else
        // Production: Check real purchase status
        Task {
            let store = StoreManager()
            self.isPro = store.isPro
        }
        #endif
    }
    
    // MARK: - Debug Helper
    #if DEBUG
    func toggleProForTesting() {
        isPro.toggle()
        print("🧪 DEBUG: Toggled Pro to \(isPro)")
    }
    #endif
    
    // ... rest of your code
}
```

Would you like me to implement this debug mode for you?

---

## 📌 Bottom Line

**Right now, you can:**
1. ✅ Test the UI/UX without real purchases
2. ✅ Toggle Pro mode with a debug flag
3. ✅ Test free tier limits perfectly

**Later (before launch):**
1. Set up StoreKit configuration
2. Test real purchase flow
3. Submit to App Store

Want me to add the debug toggle feature? It's the easiest way to test everything!
