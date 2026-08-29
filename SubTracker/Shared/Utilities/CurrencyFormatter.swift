//
//  CurrencyFormatter.swift
//  SubTracker
//

import Foundation

enum AppCurrency: String, CaseIterable, Identifiable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case bdt = "BDT"
    case inr = "INR"
    case cad = "CAD"
    case aud = "AUD"
    case jpy = "JPY"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .bdt: return "Bangladeshi Taka"
        case .inr: return "Indian Rupee"
        case .cad: return "Canadian Dollar"
        case .aud: return "Australian Dollar"
        case .jpy: return "Japanese Yen"
        }
    }

    static func isSupported(_ code: String) -> Bool {
        AppCurrency(rawValue: code.uppercased()) != nil
    }
}

enum CurrencyFormatter {
    static func format(_ amount: Decimal, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode.uppercased()
        formatter.maximumFractionDigits = currencyCode.uppercased() == "JPY" ? 0 : 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }

    static func symbol(for currencyCode: String) -> String {
        format(0, currencyCode: currencyCode)
            .replacingOccurrences(of: "0", with: "")
            .replacingOccurrences(of: ".00", with: "")
            .replacingOccurrences(of: ",00", with: "")
            .trimmingCharacters(in: .whitespaces)
    }

    /// Groups amounts by currency — never sums mixed currencies.
    static func totalsByCurrency(
        subscriptions: [Subscription],
        keyPath: KeyPath<Subscription, Decimal>
    ) -> [(currency: String, total: Decimal)] {
        Dictionary(grouping: subscriptions, by: \.currency)
            .map { currency, subs in
                (currency: currency, total: subs.reduce(0) { $0 + $1[keyPath: keyPath] })
            }
            .sorted { $0.currency < $1.currency }
    }
}
