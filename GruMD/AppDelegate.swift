import AppKit

/// Launch policy for GruMD.
///
/// We allow a single startup window (SwiftUI `DocumentGroup` needs one),
/// but that window shows the in-app launcher — not a sample Markdown file.
/// Automatic "open a file panel after closing Untitled" is intentionally gone
/// (that caused the flash you saw).
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        // Let DocumentGroup create one window so the app isn't windowless.
        // EditorView renders the launcher when fileURL == nil.
        true
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // Dock click with no windows: open panel (user-driven, no flash).
            NSDocumentController.shared.openDocument(self)
            return false
        }
        return true
    }
}
