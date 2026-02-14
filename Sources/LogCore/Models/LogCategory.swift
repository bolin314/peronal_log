import SwiftUI

public enum LogCategory: String, Codable, CaseIterable, Sendable {
    case todo
    case thoughts
    case log
    case mood

    public var displayName: String {
        switch self {
        case .todo: "To-Do"
        case .thoughts: "Thoughts"
        case .log: "Log"
        case .mood: "Mood"
        }
    }

    public var systemImage: String {
        switch self {
        case .todo: "checklist"
        case .thoughts: "brain.head.profile"
        case .log: "text.book.closed"
        case .mood: "heart.fill"
        }
    }

    public var color: Color {
        switch self {
        case .todo: .blue
        case .thoughts: .purple
        case .log: .green
        case .mood: .orange
        }
    }
}
