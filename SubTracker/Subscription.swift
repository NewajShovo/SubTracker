//
//  Subscription.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import Foundation
import SwiftData

@Model
final class Subscription {
    var id: UUID
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
    var createdDate: Date
    var iconName: String // SF Symbol name
    var color: String // Hex color
    
    init(
        id: UUID = UUID(),
        name: String,
        category: Category = .other,
        price: Decimal,
        currency: String = "USD",
        billingCycle: BillingCycle = .monthly,
        nextPaymentDate: Date,
        paymentMethod: String = "",
        reminderDaysBefore: Int = 3,
        notes: String = "",
        isActive: Bool = true,
        createdDate: Date = Date(),
        iconName: String = "dollarsign.circle.fill",
        color: String = "#007AFF"
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.price = price
        self.currency = currency
        self.billingCycle = billingCycle
        self.nextPaymentDate = nextPaymentDate
        self.paymentMethod = paymentMethod
        self.reminderDaysBefore = reminderDaysBefore
        self.notes = notes
        self.isActive = isActive
        self.createdDate = createdDate
        self.iconName = iconName
        self.color = color
    }
    
    // Computed properties
    var monthlyEquivalent: Decimal {
        switch billingCycle {
        case .weekly:
            return price * 52 / 12
        case .monthly:
            return price
        case .quarterly:
            return price / 3
        case .yearly:
            return price / 12
        }
    }
    
    var yearlyEquivalent: Decimal {
        switch billingCycle {
        case .weekly:
            return price * 52
        case .monthly:
            return price * 12
        case .quarterly:
            return price * 4
        case .yearly:
            return price
        }
    }
    
    var daysUntilNextPayment: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: nextPaymentDate).day ?? 0
    }
}

// MARK: - Enums

enum BillingCycle: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
    
    var systemImageName: String {
        switch self {
        case .weekly:
            return "calendar.day.timeline.left"
        case .monthly:
            return "calendar"
        case .quarterly:
            return "calendar.badge.clock"
        case .yearly:
            return "calendar.circle"
        }
    }
}

enum Category: String, Codable, CaseIterable {
    case entertainment = "Entertainment"
    case software = "Software"
    case cloud = "Cloud Storage"
    case fitness = "Fitness"
    case news = "News & Media"
    case music = "Music"
    case video = "Video"
    case productivity = "Productivity"
    case gaming = "Gaming"
    case education = "Education"
    case health = "Health"
    case finance = "Finance"
    case utilities = "Utilities"
    case other = "Other"
    
    var systemImageName: String {
        switch self {
        case .entertainment:
            return "tv.fill"
        case .software:
            return "apps.iphone"
        case .cloud:
            return "icloud.fill"
        case .fitness:
            return "figure.run"
        case .news:
            return "newspaper.fill"
        case .music:
            return "music.note"
        case .video:
            return "play.rectangle.fill"
        case .productivity:
            return "list.bullet.clipboard.fill"
        case .gaming:
            return "gamecontroller.fill"
        case .education:
            return "graduationcap.fill"
        case .health:
            return "heart.fill"
        case .finance:
            return "dollarsign.circle.fill"
        case .utilities:
            return "wrench.and.screwdriver.fill"
        case .other:
            return "folder.fill"
        }
    }
    
    var defaultColor: String {
        switch self {
        case .entertainment:
            return "#FF2D55"
        case .software:
            return "#007AFF"
        case .cloud:
            return "#5856D6"
        case .fitness:
            return "#FF9500"
        case .news:
            return "#34C759"
        case .music:
            return "#FF2D55"
        case .video:
            return "#AF52DE"
        case .productivity:
            return "#5AC8FA"
        case .gaming:
            return "#FFCC00"
        case .education:
            return "#32ADE6"
        case .health:
            return "#FF3B30"
        case .finance:
            return "#34C759"
        case .utilities:
            return "#8E8E93"
        case .other:
            return "#8E8E93"
        }
    }
}
