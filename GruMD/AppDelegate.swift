import AppKit

/// TextEdit-style launch:
/// - Cold start with no file → Open panel only (no home window, no Untitled)
/// - Open via double-click / “Open With” → that document only
/// - File → New still creates an empty Untitled when the user asks
final class AppDelegate: NSObject, NSApplicationDelegate {
    /// Set when the system hands us files at launch (before didFinishLaunching work).
    private var openedDocumentFromExternalRequest = false
    private var didPresentOpenPanel = false

    func applicationWillFinishLaunching(_ notification: Notification) {
        // Ensure we win the shared document-controller race early.
        _ = NSDocumentController.shared
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }

    /// Finder / “Open With” / double-click.
    func application(_ application: NSApplication, open urls: [URL]) {
        openedDocumentFromExternalRequest = true
        for url in urls {
            NSDocumentController.shared.openDocument(withContentsOf: url, display: true) { _, _, _ in }
        }
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        openedDocumentFromExternalRequest = true
        let url = URL(fileURLWithPath: filename)
        NSDocumentController.shared.openDocument(withContentsOf: url, display: true) { _, _, _ in }
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Wait briefly so file-open events from Finder can register first.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.finishLaunchIfNeeded()
        }
        // One more pass: DocumentGroup sometimes creates a late Untitled.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.closeStrayUntitledDocuments()
            self.finishLaunchIfNeeded()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            didPresentOpenPanel = false
            openedDocumentFromExternalRequest = false
            NSDocumentController.shared.openDocument(self)
            return false
        }
        return true
    }

    private func finishLaunchIfNeeded() {
        closeStrayUntitledDocuments()

        let hasRealDocument = NSDocumentController.shared.documents.contains { $0.fileURL != nil }
        if hasRealDocument || openedDocumentFromExternalRequest {
            return
        }
        if NSDocumentController.shared.documents.isEmpty, !didPresentOpenPanel {
            didPresentOpenPanel = true
            NSDocumentController.shared.openDocument(self)
        }
    }

    /// Drop empty Untitled windows DocumentGroup may still spawn at launch.
    private func closeStrayUntitledDocuments() {
        for document in NSDocumentController.shared.documents {
            // Only auto-created, never-saved, empty-ish untitled docs.
            guard document.fileURL == nil, !document.isDocumentEdited else { continue }
            document.close()
        }
    }
}
