import Foundation

struct TextMatch: Equatable {
    let range: Range<String.Index>
    /// NSRange in UTF-16 for AppKit interop.
    let nsRange: NSRange
}

enum FindReplaceSupport {
    static func matches(
        in text: String,
        query: String,
        caseSensitive: Bool
    ) -> [TextMatch] {
        guard !query.isEmpty else { return [] }
        let options: String.CompareOptions = caseSensitive ? [] : [.caseInsensitive]
        var result: [TextMatch] = []
        var searchStart = text.startIndex

        while searchStart < text.endIndex {
            guard let found = text.range(of: query, options: options, range: searchStart..<text.endIndex) else {
                break
            }
            let ns = NSRange(found, in: text)
            result.append(TextMatch(range: found, nsRange: ns))
            searchStart = found.upperBound
            // Avoid infinite loop on empty match
            if found.isEmpty {
                searchStart = text.index(after: searchStart)
            }
        }
        return result
    }

    static func replaceAll(
        in text: String,
        query: String,
        replacement: String,
        caseSensitive: Bool
    ) -> String {
        guard !query.isEmpty else { return text }
        if caseSensitive {
            return text.replacingOccurrences(of: query, with: replacement)
        }
        // Case-insensitive replace while preserving non-overlapping scans
        var output = ""
        var searchStart = text.startIndex
        while searchStart < text.endIndex {
            if let found = text.range(of: query, options: [.caseInsensitive], range: searchStart..<text.endIndex) {
                output += text[searchStart..<found.lowerBound]
                output += replacement
                searchStart = found.upperBound
            } else {
                output += text[searchStart...]
                break
            }
        }
        return output
    }

    static func lineNumber(of match: TextMatch, in text: String) -> Int {
        let prefix = text[text.startIndex..<match.range.lowerBound]
        return prefix.filter { $0.isNewline }.count + 1
    }
}
