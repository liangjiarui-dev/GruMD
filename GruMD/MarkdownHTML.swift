import Foundation

/// Build offline HTML for export / print using the same marked.js + preview.css as the live preview.
enum MarkdownHTML {
    static func fullDocument(
        markdown: String,
        fontSize: Double = 17,
        maxWidthRem: Double = 42,
        isDark: Bool = false
    ) -> String {
        let marked = loadResource("marked", ext: "min.js")
            ?? "window.marked={parse:function(t){return t;}};"
        let css = loadResource("preview", ext: "css")
            ?? "body{font-family:-apple-system,sans-serif;padding:24px;}"
        let mdJSON = jsonString(markdown)
        let theme = isDark ? "theme-dark" : "theme-light"

        return """
        <!DOCTYPE html>
        <html class="\(theme)">
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>GruMD Export</title>
        <style>
        :root { --base-font-size: \(fontSize)px; }
        \(css)
        .markdown-body { max-width: \(maxWidthRem)rem; }
        @media print {
          body { background: white !important; }
          .theme-dark { --text: #111; --heading: #111; --muted: #444; }
        }
        </style>
        <script>\(marked)</script>
        </head>
        <body>
        <article id="content" class="markdown-body"></article>
        <script>
        (function() {
          try {
            if (window.marked && marked.setOptions) {
              marked.setOptions({ gfm: true, breaks: false, headerIds: true, mangle: false });
            }
            var md = \(mdJSON);
            document.getElementById('content').innerHTML =
              (window.marked && marked.parse) ? marked.parse(md) : md;
          } catch (e) {
            document.getElementById('content').innerHTML = '<pre>' + String(e) + '</pre>';
          }
        })();
        </script>
        </body>
        </html>
        """
    }

    private static func loadResource(_ name: String, ext: String) -> String? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }

    private static func jsonString(_ value: String) -> String {
        if let data = try? JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed]),
           let encoded = String(data: data, encoding: .utf8) {
            return encoded
        }
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "\t", with: "\\t")
        return "\"\(escaped)\""
    }
}
