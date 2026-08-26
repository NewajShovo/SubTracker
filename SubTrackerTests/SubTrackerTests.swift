//
//  SubTrackerTests.swift
//  SubTrackerTests
//

import XCTest
@testable import SubTracker

final class SubscriptionCalculationTests: XCTestCase {
    func testWeeklyToMonthly() {
        let sub = Subscription(name: "Test", price: 10, billingCycle: .weekly, nextPaymentDate: Date())
        XCTAssertEqual(sub.monthlyEquivalent, 10 * 52 / 12)
    }

    func testMonthlyToYearly() {
        let sub = Subscription(name: "Test", price: 10, billingCycle: .monthly, nextPaymentDate: Date())
        XCTAssertEqual(sub.yearlyEquivalent, 120)
    }

    func testQuarterlyToYearly() {
        let sub = Subscription(name: "Test", price: 30, billingCycle: .quarterly, nextPaymentDate: Date())
        XCTAssertEqual(sub.yearlyEquivalent, 120)
    }

    func testYearlyToMonthly() {
        let sub = Subscription(name: "Test", price: 120, billingCycle: .yearly, nextPaymentDate: Date())
        XCTAssertEqual(sub.monthlyEquivalent, 10)
    }
}

final class FeatureGateTests: XCTestCase {
    @MainActor
    func testFreeLimit() {
        let gate = FeatureGate(storeManager: StoreManager.shared)
        XCTAssertTrue(gate.canAddSubscription(totalCount: 4))
        XCTAssertFalse(gate.canAddSubscription(totalCount: 5))
    }
}

final class ExtractedSubscriptionValidationTests: XCTestCase {
    func testValidExtraction() {
        let extracted = ExtractedSubscription(
            name: "Netflix",
            price: 17.99,
            currency: "USD",
            billingCycle: .monthly,
            nextPaymentDate: Date(),
            category: .video,
            paymentMethod: nil,
            confidence: 0.9,
            source: .ruleBased,
            rawText: "Netflix $17.99"
        )
        XCTAssertTrue(extracted.isValid)
        XCTAssertNotNil(ExtractedSubscriptionValidator.validate(extracted))
    }

    func testInvalidPriceRejected() {
        let extracted = ExtractedSubscription(
            name: "Netflix",
            price: 0,
            currency: "USD",
            billingCycle: .monthly,
            nextPaymentDate: Date(),
            category: nil,
            paymentMethod: nil,
            confidence: 0.2,
            source: .ruleBased,
            rawText: ""
        )
        XCTAssertFalse(extracted.isValid)
        XCTAssertNil(ExtractedSubscriptionValidator.validate(extracted))
    }
}

final class CurrencyFormatterTests: XCTestCase {
    func testDoesNotMixCurrenciesInTotals() {
        let subs = [
            Subscription(name: "A", price: 10, currency: "USD", nextPaymentDate: Date()),
            Subscription(name: "B", price: 10, currency: "EUR", nextPaymentDate: Date())
        ]
        let totals = CurrencyFormatter.totalsByCurrency(subscriptions: subs, keyPath: \.monthlyEquivalent)
        XCTAssertEqual(totals.count, 2)
    }
}

final class RuleBasedProviderTests: XCTestCase {
    @MainActor
    func testExtractsNetflixFromText() async throws {
        let provider = RuleBasedSubscriptionProvider()
        let text = """
        Netflix Premium
        Your next payment is $17.99
        September 3, 2026
        """
        let result = try await provider.extractSubscription(from: text)
        XCTAssertEqual(result.name, "Netflix")
        XCTAssertEqual(result.price, Decimal(string: "17.99"))
        XCTAssertEqual(result.currency, "USD")
        XCTAssertEqual(result.billingCycle, .monthly)
    }

    @MainActor
    func testMatchesDisneyPlusAliasAndMonthlyShorthand() async throws {
        let provider = RuleBasedSubscriptionProvider()
        let result = try await provider.extractSubscription(from: """
        Disney Plus
        $7.99/mo
        Renews August 26, 2026
        """)
        XCTAssertEqual(result.name, "Disney+")
        XCTAssertEqual(result.price, Decimal(string: "7.99"))
        XCTAssertEqual(result.billingCycle, .monthly)
        XCTAssertEqual(result.category, .video)
    }

    @MainActor
    func testParsesEuropeanAmountAndPrefersTotal() async throws {
        let provider = RuleBasedSubscriptionProvider()
        let result = try await provider.extractSubscription(from: """
        Spotify
        Tax 1,44 EUR
        Total 9,99 EUR
        billed monthly
        """)
        XCTAssertEqual(result.name, "Spotify")
        XCTAssertEqual(result.price, Decimal(string: "9.99"))
        XCTAssertEqual(result.currency, "EUR")
        XCTAssertEqual(result.billingCycle, .monthly)
    }

    @MainActor
    func testParsesThousandsSeparatorAndYearlyCycle() async throws {
        let provider = RuleBasedSubscriptionProvider()
        let result = try await provider.extractSubscription(from: """
        Adobe Creative Cloud
        $1,199.00 billed annually
        """)
        XCTAssertEqual(result.name, "Adobe Creative Cloud")
        XCTAssertEqual(result.price, 1199)
        XCTAssertEqual(result.billingCycle, .yearly)
    }

    @MainActor
    func testSkipsChromeAndPrefersRenewalDate() async throws {
        let provider = RuleBasedSubscriptionProvider()
        let result = try await provider.extractSubscription(from: """
        Manage subscription
        Account settings
        Member since January 1, 2020
        ChatGPT
        $20.00 per month
        Renews September 3, 2026
        Visa
        """)
        XCTAssertEqual(result.name, "ChatGPT Plus")
        XCTAssertEqual(result.price, 20)
        XCTAssertEqual(result.paymentMethod, "Visa")

        let date = result.nextPaymentDate ?? .distantPast
        let components = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: date)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 9)
        XCTAssertEqual(components.day, 3)
    }
}

final class PresetMatchingTests: XCTestCase {
    @MainActor
    func testFuzzyOCRName() {
        XCTAssertEqual(SubscriptionPreset.matchInText("Nelflix Standard")?.name, "Netflix")
        XCTAssertEqual(SubscriptionPreset.preset(for: "disney plus")?.name, "Disney+")
    }
}
