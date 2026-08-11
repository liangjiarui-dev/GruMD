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

    /// Empty by default — no built-in welcome / sample Markdown.
    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
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
