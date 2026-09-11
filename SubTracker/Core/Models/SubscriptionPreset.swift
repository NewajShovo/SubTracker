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
    
    /// Common receipt / screenshot names that should map to a catalog preset.
    static let aliases: [String: String] = [
        "disney plus": "Disney+",
        "disney+": "Disney+",
        "hbo max": "HBO Max",
        "max": "HBO Max",
        "prime video": "Amazon Prime",
        "amazon prime video": "Amazon Prime",
        "youtube": "YouTube Premium",
        "yt premium": "YouTube Premium",
        "chatgpt": "ChatGPT Plus",
        "openai": "ChatGPT Plus",
        "microsoft office": "Microsoft 365",
        "office 365": "Microsoft 365",
        "icloud": "iCloud+",
        "icloud+": "iCloud+",
        "ps plus": "PlayStation Plus",
        "playstation": "PlayStation Plus",
        "xbox game pass": "Xbox Game Pass",
        "game pass": "Xbox Game Pass",
        "switch online": "Nintendo Switch Online",
        "nyt": "The New York Times",
        "new york times": "The New York Times",
        "creative cloud": "Adobe Creative Cloud",
        "adobe": "Adobe Creative Cloud",
        "github copilot": "GitHub",
        "google drive": "Google One"
    ]

    static func preset(for name: String) -> SubscriptionPreset? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let exact = presets.first(where: { $0.name.compare(trimmed, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }) {
            return exact
        }

        let key = trimmed.lowercased()
        if let canonical = aliases[key],
           let preset = presets.first(where: { $0.name == canonical }) {
            return preset
        }

        return matchInText(trimmed)
    }

    /// Longest catalog / alias match inside OCR text.
    static func matchInText(_ text: String) -> SubscriptionPreset? {
        let lower = text.lowercased()
        var best: (preset: SubscriptionPreset, length: Int)?

        for preset in presets {
            let needle = preset.name.lowercased()
            if needle.count >= 3, containsWord(needle, in: lower), needle.count > (best?.length ?? 0) {
                best = (preset, needle.count)
            }
        }

        for (alias, canonical) in aliases {
            guard alias.count >= 3, containsWord(alias, in: lower) else { continue }
            if alias.count > (best?.length ?? 0),
               let preset = presets.first(where: { $0.name == canonical }) {
                best = (preset, alias.count)
            }
        }

        if best == nil {
            best = fuzzyPreset(in: lower)
        }

        return best?.preset
    }

    private static func containsWord(_ needle: String, in haystack: String) -> Bool {
        let escaped = NSRegularExpression.escapedPattern(for: needle)
        if needle.count <= 4 {
            return haystack.range(of: #"\b"# + escaped + #"\b"#, options: .regularExpression) != nil
        }
        return haystack.contains(needle)
    }

    private static func fuzzyPreset(in lowerText: String) -> (preset: SubscriptionPreset, length: Int)? {
        let tokens = lowerText.split(whereSeparator: { !$0.isLetter }).map(String.init).filter { $0.count >= 5 }
        var best: (preset: SubscriptionPreset, length: Int)?
        for preset in presets {
            let name = preset.name.lowercased().filter(\.isLetter)
            guard name.count >= 5 else { continue }
            for token in tokens where levenshtein(token, name) <= (name.count >= 8 ? 2 : 1) {
                if name.count > (best?.length ?? 0) {
                    best = (preset, name.count)
                }
            }
        }
        return best
    }

    private static func levenshtein(_ a: String, _ b: String) -> Int {
        let aChars = Array(a)
        let bChars = Array(b)
        if aChars.isEmpty { return bChars.count }
        if bChars.isEmpty { return aChars.count }

        var previous = Array(0...bChars.count)
        for (i, aChar) in aChars.enumerated() {
            var current = [i + 1] + Array(repeating: 0, count: bChars.count)
            for (j, bChar) in bChars.enumerated() {
                let cost = aChar == bChar ? 0 : 1
                current[j + 1] = min(
                    previous[j + 1] + 1,
                    current[j] + 1,
                    previous[j] + cost
                )
            }
            previous = current
        }
        return previous[bChars.count]
    }
}
