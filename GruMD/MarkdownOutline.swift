import Foundation

struct OutlineItem: Identifiable, Hashable {
    let id: String
    let level: Int
    let title: String
    /// UTF-16 offset into the full document string (NSString compatible).
    let utf16Location: Int
    let lineIndex: Int
}

enum MarkdownOutline {
    /// Parse ATX headings `#` … `###` (levels 1–3).
    static func items(in text: String) -> [OutlineItem] {
        var result: [OutlineItem] = []
        let ns = text as NSString
        var lineStart = 0
        var lineIndex = 0

        while lineStart <= ns.length {
            let lineEnd: Int
            if lineStart >= ns.length {
                break
            }
            let rest = NSRange(location: lineStart, length: ns.length - lineStart)
            let nl = ns.rangeOfCharacter(from: .newlines, options: [], range: rest)
            if nl.location == NSNotFound {
                lineEnd = ns.length
            } else {
                lineEnd = nl.location
            }

            let lineRange = NSRange(location: lineStart, length: lineEnd - lineStart)
            let line = ns.substring(with: lineRange)
            if let item = parseLine(line, utf16Location: lineStart, lineIndex: lineIndex) {
                result.append(item)
            }

            if nl.location == NSNotFound {
                break
            }
            lineStart = nl.location + nl.length
            lineIndex += 1
        }

        return result
    }

    private static func parseLine(_ line: String, utf16Location: Int, lineIndex: Int) -> OutlineItem? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("#") else { return nil }

        var level = 0
        for ch in trimmed {
            if ch == "#" { level += 1 } else { break }
        }
        guard level >= 1, level <= 3 else { return nil }
        guard trimmed.count > level else { return nil }
        let after = trimmed.index(trimmed.startIndex, offsetBy: level)
        guard trimmed[after].isWhitespace || after == trimmed.endIndex else { return nil }

        let title = trimmed[after...].trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return nil }

        return OutlineItem(
            id: "\(lineIndex)-\(utf16Location)-\(title)",
            level: level,
            title: title,
            utf16Location: utf16Location,
            lineIndex: lineIndex
        )
    }
}
