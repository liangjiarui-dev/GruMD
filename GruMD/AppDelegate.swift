import AppKit

/// TextEdit-style launch without a visible Untitled flash.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var openedFromFileEvent = false
    private var didOfferOpenPanel = false
    private var windowObserver: NSObjectProtocol?

    func applicationWillFinishLaunching(_ notification: Notification) {
        // Must install custom controller before anything touches `.shared`.
        _ = GruMDDocumentController()

        // Catch any window the moment it becomes key/main and hide stray Untitled.
        windowObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.suppressUntitledWindowIfNeeded(note.object as? NSWindow)
        }
    }

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        openedFromFileEvent = true
        for url in urls {
            NSDocumentController.shared.openDocument(withContentsOf: url, display: true) { _, _, _ in }
        }
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        openedFromFileEvent = true
        let url = URL(fileURLWithPath: filename)
        NSDocumentController.shared.openDocument(withContentsOf: url, display: true) { _, _, _ in }
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide any window that already appeared (prevents one-frame flash).
        for window in NSApp.windows where isLikelyUntitledDocumentWindow(window) {
            window.alphaValue = 0
            window.orderOut(nil)
        }
        closeStrayUntitledDocuments()

        DispatchQueue.main.async {
            self.closeStrayUntitledDocuments()
            self.presentOpenPanelIfIdle()
        }
        // Late DocumentGroup Untitled (if any)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.closeStrayUntitledDocuments()
            self.presentOpenPanelIfIdle()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            didOfferOpenPanel = false
            openedFromFileEvent = false
            NSDocumentController.shared.openDocument(self)
            return false
        }
        return true
    }

    deinit {
        if let windowObserver {
            NotificationCenter.default.removeObserver(windowObserver)
        }
    }

    // MARK: - Helpers

    private func presentOpenPanelIfIdle() {
        if openedFromFileEvent { return }
        if NSDocumentController.shared.documents.contains(where: { $0.fileURL != nil }) { return }
        if !NSDocumentController.shared.documents.isEmpty { return }
        guard !didOfferOpenPanel else { return }
        didOfferOpenPanel = true
        NSDocumentController.shared.openDocument(self)
    }

    private func closeStrayUntitledDocuments() {
        for document in NSDocumentController.shared.documents {
            guard document.fileURL == nil else { continue }
            // Don't kill a user-created New that already has edits.
            if document.isDocumentEdited { continue }
            // If New was just requested, keep it.
            if let controller = NSDocumentController.shared as? GruMDDocumentController,
               controller.userInitiatedNew {
                continue
            }
            document.close()
        }
    }

    private func suppressUntitledWindowIfNeeded(_ window: NSWindow?) {
        guard let window else { return }
        if let controller = NSDocumentController.shared as? GruMDDocumentController,
           controller.userInitiatedNew {
            return
        }
        // If every open document is file-backed, leave windows alone.
        let onlyUntitled = NSDocumentController.shared.documents.allSatisfy { $0.fileURL == nil }
            && !NSDocumentController.shared.documents.isEmpty
        let noRealFiles = !NSDocumentController.shared.documents.contains { $0.fileURL != nil }

        if noRealFiles && onlyUntitled || (window.title == "Untitled" && noRealFiles && !openedFromFileEvent) {
            if isLikelyUntitledDocumentWindow(window) {
                window.alphaValue = 0
                window.orderOut(nil)
            }
            closeStrayUntitledDocuments()
        }
    }

    private func isLikelyUntitledDocumentWindow(_ window: NSWindow) -> Bool {
        if window.title == "Untitled" { return true }
        // SwiftUI document windows often have no title yet for a moment.
        if window.isFloatingPanel { return false }
        if window.level != .normal { return false }
        // Avoid killing the Open panel.
        if window.frameAutosaveName.contains("NSNav") { return false }
        let className = String(describing: type(of: window))
        if className.contains("OpenPanel") || className.contains("NSSavePanel") { return false }
        // If there is no file-backed document, treat normal windows as suppressible at launch.
        let hasFileDoc = NSDocumentController.shared.documents.contains { $0.fileURL != nil }
        return !hasFileDoc && !openedFromFileEvent
    }
}
