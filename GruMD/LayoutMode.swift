import Foundation

enum LayoutMode: String, CaseIterable, Identifiable {
    case split
    case editorOnly
    case previewOnly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .split: return "Split"
        case .editorOnly: return "Editor"
        case .previewOnly: return "Preview"
        }
    }

    var systemImage: String {
        switch self {
        case .split: return "rectangle.split.2x1"
        case .editorOnly: return "square.and.pencil"
        case .previewOnly: return "eye"
        }
    }
}
