import Foundation

enum LayoutMode: String, CaseIterable, Identifiable {
    case previewOnly
    case split

    var id: String { rawValue }

    var title: String {
        switch self {
        case .previewOnly: return "Preview"
        case .split: return "Split"
        }
    }

    var systemImage: String {
        switch self {
        case .previewOnly: return "eye"
        case .split: return "rectangle.split.2x1"
        }
    }

    /// Chrome order: Preview first, then Split (side‑by‑side).
    static var chromeModes: [LayoutMode] { [.previewOnly, .split] }

    /// Map legacy stored values to a supported mode.
    static func resolved(_ raw: String?) -> LayoutMode {
        switch raw {
        case LayoutMode.split.rawValue:
            return .split
        default:
            // previewOnly, editorOnly, focus, nil → default Preview
            return .previewOnly
        }
    }
}
