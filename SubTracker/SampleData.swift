//
//  SampleData.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import Foundation
import SwiftData

extension ModelContainer {
    /// Adds sample subscriptions for testing and previews
    @MainActor
    static func addSampleData(to container: ModelContainer) {
        let context = container.mainContext
        
        // Netflix
        let netflix = Subscription(
            name: "Netflix",
            category: .video,
            price: 15.99,
            billingCycle: .monthly,
            nextPaymentDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            paymentMethod: "Visa •••• 1234",
            reminderDaysBefore: 3,
            notes: "Premium plan - 4K streaming",
            iconName: "tv.fill",
            color: "#E50914"
        )
        
        // Spotify
        let spotify = Subscription(
            name: "Spotify",
            category: .music,
            price: 10.99,
            billingCycle: .monthly,
            nextPaymentDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            paymentMethod: "Mastercard •••• 5678",
            reminderDaysBefore: 3,
            iconName: "music.note",
            color: "#1DB954"
        )
        
        // iCloud+
        let icloud = Subscription(
            name: "iCloud+",
            category: .cloud,
            price: 2.99,
            billingCycle: .monthly,
            nextPaymentDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
            paymentMethod: "Apple Pay",
            reminderDaysBefore: 1,
            notes: "200GB storage plan",
            iconName: "icloud.fill",
            color: "#007AFF"
        )
        
        // ChatGPT Plus
        let chatgpt = Subscription(
            name: "ChatGPT Plus",
            category: .productivity,
            price: 20.00,
            billingCycle: .monthly,
            nextPaymentDate: Calendar.current.date(byAdding: .day, value: 20, to: Date())!,
            paymentMethod: "Visa •••• 1234",
            reminderDaysBefore: 5,
            notes: "Access to GPT-4",
            iconName: "text.bubble.fill",
            color: "#10A37F"
        )
        
        // Adobe Creative Cloud
        let adobe = Subscription(
            name: "Adobe Creative Cloud",
            category: .software,
            price: 54.99,
            billingCycle: .monthly,
            nextPaymentDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            paymentMethod: "Amex •••• 9012",
            reminderDaysBefore: 7,
            notes: "All apps plan",
            iconName: "paintbrush.fill",
            color: "#FF0000"
        )
        
        // Apple Music
        let appleMusic = Subscription(
            name: "Apple Music",
            category: .music,
            price: 10.99,
            billingCycle: .monthly,
            nextPaymentDate: Calendar.current.date(byAdding: .day, value: 12, to: Date())!,
            paymentMethod: "Apple Pay",
            reminderDaysBefore: 2,
            iconName: "music.note.list",
            color: "#FA243C"
        )
        
        // Planet Fitness
        let gym = Subscription(
            name: "Planet Fitness",
            category: .fitness,
            price: 10.00,
            billingCycle: .monthly,
            nextPaymentDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
            paymentMethod: "Bank Account",
            reminderDaysBefore: 3,
            notes: "Black Card membership",
            iconName: "dumbbell.fill",
            color: "#7B2F8E"
        )
        
        // YouTube Premium
        let youtube = Subscription(
            name: "YouTube Premium",
            category: .video,
            price: 11.99,
            billingCycle: .monthly,
            nextPaymentDate: Calendar.current.date(byAdding: .day, value: 25, to: Date())!,
            paymentMethod: "Google Pay",
            reminderDaysBefore: 3,
            notes: "Family plan",
            iconName: "play.rectangle.fill",
            color: "#FF0000"
        )
        
        // GitHub Pro (yearly)
        let github = Subscription(
            name: "GitHub Pro",
            category: .software,
            price: 48.00,
            billingCycle: .yearly,
            nextPaymentDate: Calendar.current.date(byAdding: .day, value: 45, to: Date())!,
            paymentMethod: "Visa •••• 1234",
            reminderDaysBefore: 30,
            notes: "Annual plan - saves money",
            iconName: "chevron.left.forwardslash.chevron.right",
            color: "#181717"
        )
        
        // Dropbox (quarterly)
        let dropbox = Subscription(
            name: "Dropbox",
            category: .cloud,
            price: 35.97,
            billingCycle: .quarterly,
            nextPaymentDate: Calendar.current.date(byAdding: .day, value: 60, to: Date())!,
            paymentMethod: "Mastercard •••• 5678",
            reminderDaysBefore: 7,
            notes: "Plus plan - 2TB storage",
            iconName: "folder.fill",
            color: "#0061FF"
        )
        
        // Insert all sample subscriptions
        context.insert(netflix)
        context.insert(spotify)
        context.insert(icloud)
        context.insert(chatgpt)
        context.insert(adobe)
        context.insert(appleMusic)
        context.insert(gym)
        context.insert(youtube)
        context.insert(github)
        context.insert(dropbox)
        
        // Save the context
        try? context.save()
    }
}

// MARK: - Preview Helper

extension ModelContainer {
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(
            for: Subscription.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        addSampleData(to: container)
        
        return container
    }
}
