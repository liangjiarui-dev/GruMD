import AppKit

/// Prevents launching into a blank Untitled document.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // After state restoration, if nothing is open, show the Open dialog
        // instead of creating Untitled.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if NSDocumentController.shared.documents.isEmpty {
                NSDocumentController.shared.openDocument(self)
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag, NSDocumentController.shared.documents.isEmpty {
            NSDocumentController.shared.openDocument(self)
            return false
        }
        return true
    }
}
