import Foundation

enum LayoutMode: String, CaseIterable, Identifiable {
    case split
    case previewOnly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .split: return "Split"
        case .previewOnly: return "Preview"
        }
    }

    var systemImage: String {
        switch self {
        case .split: return "rectangle.split.2x1"
        case .previewOnly: return "eye"
        }
    }

    /// Modes shown in the chrome control.
    static var chromeModes: [LayoutMode] { [.split, .previewOnly] }

    /// Map legacy stored values (editorOnly / focus) to a supported mode.
    static func resolved(_ raw: String?) -> LayoutMode {
        switch raw {
        case LayoutMode.previewOnly.rawValue:
            return .previewOnly
        default:
            return .split
        }
    }
}
