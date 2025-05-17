import UIKit

enum MainColor: Int, CaseIterable {
    case system = 0
    case blue
    case green
    case orange

    var uiColor: UIColor {
        switch self {
        case .system:
            return .systemBackground
        case .blue:
            return .systemBlue
        case .green:
            return .systemGreen
        case .orange:
            return .systemOrange
        }
    }

    var title: String {
        switch self {
        case .system: return "System"
        case .blue: return "Blue"
        case .green: return "Green"
        case .orange: return "Orange"
        }
    }
}

struct Theme {
    private static let key = "MainColor"

    static var current: MainColor {
        get {
            let raw = UserDefaults.standard.integer(forKey: key)
            return MainColor(rawValue: raw) ?? .system
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }

    static var color: UIColor {
        return current.uiColor
    }
}
