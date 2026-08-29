//
//  WidgetDeepLink.swift
//  SubTracker
//

import Foundation

enum WidgetDeepLink {
    static let scheme = "subtracker"

    enum Destination: Equatable {
        case dashboard
        case subscriptions
        case subscription(UUID)
    }

    static func destination(from url: URL) -> Destination? {
        guard url.scheme == scheme else { return nil }
        switch url.host {
        case "dashboard":
            return .dashboard
        case "subscriptions":
            return .subscriptions
        case "subscription":
            guard let idString = url.pathComponents.last,
                  let id = UUID(uuidString: idString) else { return .subscriptions }
            return .subscription(id)
        default:
            return .dashboard
        }
    }
}
