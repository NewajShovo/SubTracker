//
//  ExportService.swift
//  SubTracker
//

import Foundation
import UIKit

enum ExportService {
    static func csvData(from subscriptions: [Subscription]) -> Data {
        var rows = ["Name,Category,Price,Currency,Billing Cycle,Next Payment,Active,Trial,Payment Method,Notes"]
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        for sub in subscriptions.sorted(by: { $0.name < $1.name }) {
            let fields = [
                escape(sub.name),
                escape(sub.category.rawValue),
                "\(sub.price)",
                sub.currency,
                sub.billingCycle.rawValue,
                formatter.string(from: sub.nextPaymentDate),
                sub.isActive ? "Yes" : "No",
                sub.isTrial ? "Yes" : "No",
                escape(sub.paymentMethod),
                escape(sub.notes)
            ]
            rows.append(fields.joined(separator: ","))
        }
        return rows.joined(separator: "\n").data(using: .utf8) ?? Data()
    }

    static func pdfData(from subscriptions: [Subscription]) -> Data {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        return renderer.pdfData { context in
            context.beginPage()
            let title = "SubTracker Export"
            let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 22)]
            title.draw(at: CGPoint(x: 40, y: 40), withAttributes: attrs)

            var y: CGFloat = 80
            let bodyAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12)]

            for sub in subscriptions.sorted(by: { $0.name < $1.name }) {
                if y > pageHeight - 60 {
                    context.beginPage()
                    y = 40
                }
                let line = "\(sub.name) — \(CurrencyFormatter.format(sub.price, currencyCode: sub.currency)) / \(sub.billingCycle.rawValue) — Next: \(sub.nextPaymentDate.formatted(date: .abbreviated, time: .omitted))"
                line.draw(at: CGPoint(x: 40, y: y), withAttributes: bodyAttrs)
                y += 20
            }
        }
    }

    private static func escape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }
}
