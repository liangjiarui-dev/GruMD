import AppKit

/// Launch without a sample Untitled document.
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var didOfferOpenPanel = false

    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // DocumentGroup may still create an Untitled window; close it and offer Open.
        DispatchQueue.main.async {
            self.dismissAutoUntitledAndOfferOpen()
        }
        // Second pass: SwiftUI sometimes creates the document a moment later.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.dismissAutoUntitledAndOfferOpen()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            didOfferOpenPanel = false
            DispatchQueue.main.async {
                self.dismissAutoUntitledAndOfferOpen()
            }
            return false
        }
        return true
    }

    private func dismissAutoUntitledAndOfferOpen() {
        // Close only unsaved, never-saved documents (Untitled).
        for document in NSDocumentController.shared.documents {
            if document.fileURL == nil, !document.isDocumentEdited {
                document.close()
            }
        }

        if NSDocumentController.shared.documents.isEmpty, !didOfferOpenPanel {
            didOfferOpenPanel = true
            NSDocumentController.shared.openDocument(self)
        }
    }
}
