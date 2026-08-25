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
    func testExtractsNetflixFromText() async throws {
        let provider = RuleBasedSubscriptionProvider()
        let text = """
        Netflix Premium
        Your next payment is $17.99
        September 3, 2026
        """
        let result = try await provider.extractSubscription(from: text)
        XCTAssertEqual(result.name, "Netflix")
        XCTAssertEqual(result.price, 17.99)
        XCTAssertEqual(result.currency, "USD")
    }
}
