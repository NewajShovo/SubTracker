//
//  OnboardingPage.swift
//  SubTracker
//

import SwiftUI

struct OnboardingPage: Identifiable, Equatable {
    enum Visual: Equatable {
        case spending
        case reminders
        case scan
        case insights
    }

    let id: Int
    let visual: Visual
    let title: String
    let description: String
    let accent: Color
}

extension OnboardingPage {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            visual: .spending,
            title: "Know Where It Goes",
            description: "See monthly and yearly subscription spending at a glance.",
            accent: Color(hex: "3B82F6")
        ),
        OnboardingPage(
            id: 1,
            visual: .reminders,
            title: "Never Miss a Renewal",
            description: "Get smart reminders before you're charged again.",
            accent: Color(hex: "F97316")
        ),
        OnboardingPage(
            id: 2,
            visual: .scan,
            title: "Scan Instead of Type",
            description: "Snap a screenshot and let SubTracker extract the details for you.",
            accent: Color(hex: "8B5CF6")
        ),
        OnboardingPage(
            id: 3,
            visual: .insights,
            title: "Ready to Take Control?",
            description: "Review spending patterns and find subscriptions worth revisiting.",
            accent: Color(hex: "10B981")
        )
    ]
}
