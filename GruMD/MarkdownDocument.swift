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
# GruMD

A quiet place for local Markdown.

## Start here

- Open a `.md` file, or just start typing
- Save with **⌘S**
- Switch layout with the control at the top-left

## Sample

| GFM | Supported |
|-----|-----------|
| Tables | Yes |
| Task lists | Yes |
| Code blocks | Yes |

- [x] Read
- [x] Edit
- [ ] Ship something nice

```swift
print("Hello from GruMD 1.1")
```

> Designed to feel like a first-party macOS app — small, local, offline.

---

*No vault. No plugins. No AI.*
"""
