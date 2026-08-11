import AppKit

/// Blocks automatic Untitled creation (DocumentGroup / AppKit launch path).
/// File → New sets `userInitiatedNew` so an empty document is still allowed.
final class GruMDDocumentController: NSDocumentController {
    /// True only while handling an explicit New Document command.
    var userInitiatedNew = false

    override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {
        if !userInitiatedNew {
            // Refuse auto-Untitled at launch / restore noise.
            // Throwing userCancelled avoids creating a visible window.
            throw NSError(
                domain: NSCocoaErrorDomain,
                code: NSUserCancelledError,
                userInfo: nil
            )
        }
        return try super.openUntitledDocumentAndDisplay(displayDocument)
    }

    override func newDocument(_ sender: Any?) {
        userInitiatedNew = true
        super.newDocument(sender)
        // Reset on next runloop so programmatic paths stay blocked.
        DispatchQueue.main.async { [weak self] in
            self?.userInitiatedNew = false
        }
    }
}
