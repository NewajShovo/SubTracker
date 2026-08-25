//
//  SubscriptionPreset.swift
//  SubTracker
//
//  Created by Shovo on 22/8/26.
//

import Foundation

struct SubscriptionPreset: Identifiable {
    let id = UUID()
    let name: String
    let category: Category
    let iconName: String
    let color: String
    let suggestedPrice: Decimal?
    let billingCycle: BillingCycle
    
    static let presets: [SubscriptionPreset] = [
        // Entertainment & Video
        SubscriptionPreset(name: "Netflix", category: .video, iconName: "tv.fill", color: "#E50914", suggestedPrice: 15.99, billingCycle: .monthly),
        SubscriptionPreset(name: "Disney+", category: .video, iconName: "sparkles.tv.fill", color: "#113CCF", suggestedPrice: 7.99, billingCycle: .monthly),
        SubscriptionPreset(name: "HBO Max", category: .video, iconName: "play.tv.fill", color: "#9B30FF", suggestedPrice: 14.99, billingCycle: .monthly),
        SubscriptionPreset(name: "Amazon Prime", category: .video, iconName: "shippingbox.fill", color: "#FF9900", suggestedPrice: 14.99, billingCycle: .monthly),
        SubscriptionPreset(name: "YouTube Premium", category: .video, iconName: "play.rectangle.fill", color: "#FF0000", suggestedPrice: 11.99, billingCycle: .monthly),
        SubscriptionPreset(name: "Apple TV+", category: .video, iconName: "appletv.fill", color: "#000000", suggestedPrice: 6.99, billingCycle: .monthly),
        
        // Music
        SubscriptionPreset(name: "Spotify", category: .music, iconName: "music.note", color: "#1DB954", suggestedPrice: 10.99, billingCycle: .monthly),
        SubscriptionPreset(name: "Apple Music", category: .music, iconName: "music.note.list", color: "#FA243C", suggestedPrice: 10.99, billingCycle: .monthly),
        SubscriptionPreset(name: "YouTube Music", category: .music, iconName: "music.quarternote.3", color: "#FF0000", suggestedPrice: 10.99, billingCycle: .monthly),
        
        // Cloud & Storage
        SubscriptionPreset(name: "iCloud+", category: .cloud, iconName: "icloud.fill", color: "#007AFF", suggestedPrice: 2.99, billingCycle: .monthly),
        SubscriptionPreset(name: "Google One", category: .cloud, iconName: "cloud.fill", color: "#4285F4", suggestedPrice: 1.99, billingCycle: .monthly),
        SubscriptionPreset(name: "Dropbox", category: .cloud, iconName: "folder.fill", color: "#0061FF", suggestedPrice: 11.99, billingCycle: .monthly),
        SubscriptionPreset(name: "OneDrive", category: .cloud, iconName: "icloud.and.arrow.up.fill", color: "#0078D4", suggestedPrice: 6.99, billingCycle: .monthly),
        
        // Software & Productivity
        SubscriptionPreset(name: "Adobe Creative Cloud", category: .software, iconName: "paintbrush.fill", color: "#FF0000", suggestedPrice: 54.99, billingCycle: .monthly),
        SubscriptionPreset(name: "Microsoft 365", category: .productivity, iconName: "doc.text.fill", color: "#D83B01", suggestedPrice: 6.99, billingCycle: .monthly),
        SubscriptionPreset(name: "Notion", category: .productivity, iconName: "list.bullet.clipboard.fill", color: "#000000", suggestedPrice: 10.00, billingCycle: .monthly),
        SubscriptionPreset(name: "ChatGPT Plus", category: .productivity, iconName: "text.bubble.fill", color: "#10A37F", suggestedPrice: 20.00, billingCycle: .monthly),
        SubscriptionPreset(name: "GitHub", category: .software, iconName: "chevron.left.forwardslash.chevron.right", color: "#181717", suggestedPrice: 4.00, billingCycle: .monthly),
        SubscriptionPreset(name: "Setapp", category: .software, iconName: "app.connected.to.app.below.fill", color: "#4A48E4", suggestedPrice: 9.99, billingCycle: .monthly),
        
        // News & Media
        SubscriptionPreset(name: "Apple News+", category: .news, iconName: "newspaper.fill", color: "#FF3B30", suggestedPrice: 9.99, billingCycle: .monthly),
        SubscriptionPreset(name: "The New York Times", category: .news, iconName: "doc.plaintext.fill", color: "#000000", suggestedPrice: 17.00, billingCycle: .monthly),
        
        // Gaming
        SubscriptionPreset(name: "PlayStation Plus", category: .gaming, iconName: "gamecontroller.fill", color: "#003087", suggestedPrice: 9.99, billingCycle: .monthly),
        SubscriptionPreset(name: "Xbox Game Pass", category: .gaming, iconName: "logo.xbox", color: "#107C10", suggestedPrice: 14.99, billingCycle: .monthly),
        SubscriptionPreset(name: "Apple Arcade", category: .gaming, iconName: "arcade.stick.console", color: "#FF9500", suggestedPrice: 4.99, billingCycle: .monthly),
        SubscriptionPreset(name: "Nintendo Switch Online", category: .gaming, iconName: "gamecontroller.fill", color: "#E60012", suggestedPrice: 3.99, billingCycle: .monthly),
        
        // Fitness & Health
        SubscriptionPreset(name: "Apple Fitness+", category: .fitness, iconName: "figure.run", color: "#FA243C", suggestedPrice: 9.99, billingCycle: .monthly),
        SubscriptionPreset(name: "Peloton", category: .fitness, iconName: "bicycle", color: "#000000", suggestedPrice: 44.00, billingCycle: .monthly),
        SubscriptionPreset(name: "Planet Fitness", category: .fitness, iconName: "dumbbell.fill", color: "#7B2F8E", suggestedPrice: 10.00, billingCycle: .monthly),
        
        // Utilities & Services
        SubscriptionPreset(name: "VPN Service", category: .utilities, iconName: "network.badge.shield.half.filled", color: "#34C759", suggestedPrice: 9.99, billingCycle: .monthly),
        SubscriptionPreset(name: "Domain Registration", category: .utilities, iconName: "globe", color: "#007AFF", suggestedPrice: 12.00, billingCycle: .yearly),
    ]
    
    static func preset(for name: String) -> SubscriptionPreset? {
        presets.first { $0.name.lowercased() == name.lowercased() }
    }
}
