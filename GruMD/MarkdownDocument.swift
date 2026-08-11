import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var markdownText: UTType {
        UTType(importedAs: "net.daringfireball.markdown")
    }
}

struct MarkdownDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        [.markdownText, .plainText, UTType(filenameExtension: "md") ?? .plainText, UTType(filenameExtension: "markdown") ?? .plainText]
    }

    static var writableContentTypes: [UTType] {
        [.markdownText, .plainText]
    }

    var text: String

    init(text: String = defaultWelcome) {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        // Prefer UTF-8; fall back to lossy conversion so files still open.
        if let string = String(data: data, encoding: .utf8) {
            text = string
        } else if let string = String(data: data, encoding: .isoLatin1) {
            text = string
        } else {
            text = String(decoding: data, as: UTF8.self)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8) ?? Data()
        return .init(regularFileWithContents: data)
    }
}

private let defaultWelcome = """
# Welcome to GruMD

A minimal Markdown reader & light editor for macOS.

## What you can do

- Open local `.md` files (double-click in Finder)
- Edit and **save** with ⌘S
- Preview common [GFM](https://github.github.com/gfm/) cleanly
- Optional reload when the file changes on disk

## GFM samples

| Feature | Status |
|--------|--------|
| Tables | ✓ |
| Task lists | ✓ |
| Code | ✓ |

- [x] Open a file
- [ ] Write something nice

```swift
print("Hello, GruMD")
```

> Keep it small. Keep it local. Keep it fast.

![Local images work relative to the file](./example.png)

---

*No knowledge base. No plugins. No AI. Just Markdown.*
"""
