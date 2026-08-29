//
//  PaymentRecord.swift
//  SubTracker
//

import Foundation
import SwiftData

enum PaymentStatus: String, Codable, CaseIterable {
    case paid = "Paid"
    case upcoming = "Upcoming"
    case missed = "Missed"
}

@Model
final class PaymentRecord {
    var id: UUID
    var subscriptionID: UUID
    var amount: Decimal
    var currency: String
    var date: Date
    var status: PaymentStatus

    init(
        id: UUID = UUID(),
        subscriptionID: UUID,
        amount: Decimal,
        currency: String,
        date: Date,
        status: PaymentStatus
    ) {
        self.id = id
        self.subscriptionID = subscriptionID
        self.amount = amount
        self.currency = currency
        self.date = date
        self.status = status
    }
}
