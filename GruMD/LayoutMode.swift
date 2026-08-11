import Foundation

enum LayoutMode: String, CaseIterable, Identifiable {
    case split
    case editorOnly
    case previewOnly
    case focus

    var id: String { rawValue }

    var title: String {
        switch self {
        case .split: return "Split"
        case .editorOnly: return "Editor"
        case .previewOnly: return "Preview"
        case .focus: return "Focus"
        }
    }

    var systemImage: String {
        switch self {
        case .split: return "rectangle.split.2x1"
        case .editorOnly: return "square.and.pencil"
        case .previewOnly: return "eye"
        case .focus: return "rectangle.inset.filled"
        }
    }

    /// Modes shown in the compact chrome segmented control.
    static var chromeModes: [LayoutMode] { [.split, .editorOnly, .previewOnly, .focus] }
}
