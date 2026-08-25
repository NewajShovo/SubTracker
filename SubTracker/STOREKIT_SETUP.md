# StoreKit Setup Guide for SubTracker

## 📱 What We've Built

A complete **Pro subscription system** with:

- ✅ **Paywall** - Beautiful upgrade screen with features list
- ✅ **Settings** - Pro status display and manage subscription
- ✅ **Free Tier Limits** - 5 subscriptions max for free users
- ✅ **Feature Gating** - Smart checks for Pro features
- ✅ **Banners** - Contextual upgrade prompts
- ✅ **StoreKit 2** - Modern async/await implementation

## 🎯 Pricing Strategy

### Free Tier
- Up to **5 subscriptions**
- Basic dashboard
- Basic notifications (when implemented)
- One widget (when implemented)

### Pro Subscription
- **$1.99/month** or **$14.99/year** (37% savings)
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

## 📁 Files Created

1. **StoreManager.swift** - Manages StoreKit transactions and entitlements
2. **PaywallView.swift** - Beautiful upgrade screen
3. **SettingsView.swift** - Settings tab with Pro status
4. **FeatureManager.swift** - Feature gating and limits
5. **ProBanner.swift** - Reusable upgrade banners
6. **StoreKitConfiguration.storekit** - Test configuration

## 🚀 Setup Instructions

### Step 1: Add StoreKit Configuration to Xcode

1. The `StoreKitConfiguration.storekit` file is already created
2. In Xcode, go to **Product** → **Scheme** → **Edit Scheme**
3. Select **Run** in the left sidebar
4. Go to the **Options** tab
5. Under **StoreKit Configuration**, select `StoreKitConfiguration.storekit`
6. This allows you to test purchases without real money!

### Step 2: Test in Simulator/Device

Now you can run the app and test purchases:

1. Run the app
2. Go to **Settings** tab
3. Tap **"Upgrade to Pro"**
4. You'll see the paywall with two options:
   - Monthly Pro ($1.99/month)
   - Yearly Pro ($14.99/year) - **BEST VALUE** badge
5. Select a plan and tap **"Subscribe Now"**
6. StoreKit will show a test purchase dialog
7. Approve the purchase
8. You're now a Pro user! 🎉

### Step 3: Testing the Free Limit

1. From the Dashboard, tap + to add subscriptions
2. Add 5 subscriptions (you can use the presets)
3. Try to add a 6th subscription
4. You'll see the **"Subscription Limit Reached"** dialog
5. Tap **"Upgrade to Pro"** to see the paywall
6. After upgrading, you can add unlimited subscriptions!

### Step 4: Test Restore Purchases

1. In Settings, tap **"Restore Purchases"**
2. Your Pro status should be maintained
3. This simulates users switching devices

## 🔧 Before Publishing to App Store

### 1. Create Products in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **Features** → **In-App Purchases**
4. Create a **Subscription Group** called "Pro Subscription"
5. Add two **Auto-Renewable Subscriptions**:

#### Monthly Pro
- **Product ID**: `com.shovo.subtracker.pro.monthly`
- **Reference Name**: Monthly Pro
- **Subscription Duration**: 1 Month
- **Price**: $1.99 (or your local equivalent)

#### Yearly Pro
- **Product ID**: `com.shovo.subtracker.pro.yearly`
- **Reference Name**: Yearly Pro
- **Subscription Duration**: 1 Year
- **Price**: $14.99 (or your local equivalent)
- **Free Trial**: 1 Week (optional but recommended!)

### 2. Update Product IDs (if different)

If you use different product IDs, update them in `StoreManager.swift`:

```swift
enum ProductIdentifier: String, CaseIterable {
    case monthlyPro = "YOUR_MONTHLY_ID_HERE"
    case yearlyPro = "YOUR_YEARLY_ID_HERE"
}
```

### 3. Add Required Info.plist Keys

No special keys required for StoreKit 2! 🎉

### 4. Test with Sandbox Accounts

1. In App Store Connect, go to **Users and Access** → **Sandbox Testers**
2. Create test accounts
3. On your device, go to **Settings** → **App Store** → **Sandbox Account**
4. Sign in with your test account
5. Test real purchases (no money charged)

### 5. Add Legal Documents

Update these URLs in `PaywallView.swift` and `SettingsView.swift`:

```swift
// Replace with your actual URLs
Link(destination: URL(string: "https://yourwebsite.com/terms")!)
Link(destination: URL(string: "https://yourwebsite.com/privacy")!)
```

## 🎨 How It Works in the App

### Dashboard
- Shows subscription count (e.g., "3/5") for free users
- Shows warning banner when approaching limit (4/5)
- Shows limit reached banner at 5/5
- Tapping + at limit shows upgrade dialog

### Settings Tab
- **Free Users**: See "Upgrade to Pro" with arrow
- **Pro Users**: See "Pro Subscriber" with crown and checkmark
- **Restore Purchases**: Always available

### Paywall Features
- Beautiful gradient background
- 8 key Pro features highlighted with icons
- Two pricing options (monthly & yearly)
- "BEST VALUE" badge on yearly plan
- Shows savings (37%) on yearly plan
- Restore purchases button
- Terms and Privacy links

### Analytics (Future Enhancement)
Can add Pro banner for advanced analytics:
```swift
if !featureManager.isPro {
    ProBanner(
        title: "Unlock Advanced Analytics",
        message: "Get deeper insights with category breakdowns and trends"
    ) {
        showingPaywall = true
    }
    .padding(.horizontal)
}
```

## 🧪 Testing Checklist

- [ ] Paywall displays correctly
- [ ] Both products load and show prices
- [ ] Can purchase monthly subscription
- [ ] Can purchase yearly subscription
- [ ] Settings shows Pro status after purchase
- [ ] Free limit enforced (can't add 6th subscription)
- [ ] Upgrade banner appears at 4/5 and 5/5
- [ ] Subscription limit dialog works
- [ ] Restore purchases works
- [ ] Pro users can add unlimited subscriptions
- [ ] Subscription count badge disappears for Pro users

## 💡 Revenue Optimization Tips

### 1. Offer a Free Trial
Consider adding a 7-day free trial to the yearly plan. This significantly increases conversions:

In App Store Connect:
- Set **Introductory Offer**: 7 days free trial
- After trial, $14.99/year

### 2. Show Value Early
The current implementation is good - we show:
- How much they're spending (motivates upgrades)
- Approaching limit warnings (timely upgrades)
- Clear feature list (communicates value)

### 3. Consider Price Points
Current prices:
- **Monthly**: $1.99 (yearly equivalent: $23.88)
- **Yearly**: $14.99 (save $8.89)

This creates a **37% discount** incentive for yearly, which is excellent!

### 4. Future A/B Testing Ideas
- Try $0.99/month and $9.99/year
- Try $2.99/month and $19.99/year
- Test different free limits (3 vs 5 vs 10)

## 🔐 Security Notes

### ✅ What We Handle
- Transaction verification (StoreKit 2 does this automatically)
- Revocation checking
- Subscription status updates
- Restore purchases

### ✅ What StoreKit 2 Handles
- Receipt validation (no server needed!)
- Cryptographic verification
- Subscription renewals
- Family Sharing (if you enable it)

## 📊 Analytics to Track (Future)

Consider adding analytics to track:
- **Paywall Views**: How many people see it
- **Purchase Conversion**: What % actually buy
- **Monthly vs Yearly**: Which plan is more popular
- **Churn Rate**: How many cancel
- **Upgrade Trigger**: Which banner/button drove the purchase

Use Apple's App Analytics or tools like:
- RevenueCat (handles StoreKit + analytics)
- TelemetryDeck (privacy-focused analytics)

## 🆘 Troubleshooting

### "No products found"
- Ensure StoreKit Configuration is selected in scheme
- Check product IDs match in `StoreManager.swift`
- Wait a moment - products load async

### "Purchase failed"
- In testing: Check StoreKit Configuration
- In production: Verify products are approved in App Store Connect
- Check sandbox account is signed in

### "Restore purchases doesn't work"
- StoreKit Configuration doesn't persist between runs
- In production, this will work correctly
- Use `AppStore.sync()` which we already call

## 📝 Next Steps

1. **Test thoroughly** with StoreKit Configuration
2. **Create App Store Connect products**
3. **Test with Sandbox accounts**
4. **Add Terms & Privacy pages**
5. **Submit for review**

## 🎉 You're Ready!

Your app now has a complete, production-ready subscription system using StoreKit 2. The implementation follows Apple's best practices and provides a great user experience.

**Questions?** Email: zihadulkabir206@gmail.com

---

**Built with StoreKit 2 & SwiftUI** 💙
