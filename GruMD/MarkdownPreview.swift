import SwiftUI
import WebKit

/// Offline GFM preview: vendored marked.js + local CSS, no network.
struct MarkdownPreview: NSViewRepresentable {
    let markdown: String
    let baseURL: URL?
    let fontSize: Double
    var maxWidthRem: Double = 42
    var lineHeight: Double = 1.7
    var isDark: Bool

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        // Block all network loads; only allow about:blank / file / data.
        let controller = config.userContentController
        let blockRemote = """
        // no-op marker for offline preview
        """
        controller.addUserScript(WKUserScript(source: blockRemote, injectionTime: .atDocumentStart, forMainFrameOnly: true))

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = context.coordinator
        // Avoid zero-size intrinsic content surprises during first layout.
        webView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        webView.setContentHuggingPriority(.defaultLow, for: .vertical)
        webView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        webView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        // Defer HTML load to next runloop so hosting layout can finish first.
        let md = markdown
        let base = baseURL
        let size = fontSize
        let maxW = maxWidthRem
        let lh = lineHeight
        let dark = isDark
        DispatchQueue.main.async {
            context.coordinator.load(
                markdown: md,
                into: webView,
                baseURL: base,
                fontSize: size,
                maxWidthRem: maxW,
                lineHeight: lh,
                isDark: dark
            )
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private var lastSignature: String = ""
        private lazy var markedJS: String = {
            guard let url = Bundle.main.url(forResource: "marked", withExtension: "min.js"),
                  let src = try? String(contentsOf: url, encoding: .utf8) else {
                return "window.marked={parse:function(t){return '<pre>marked.js missing</pre>';}};"
            }
            return src
        }()

        private lazy var previewCSS: String = {
            guard let url = Bundle.main.url(forResource: "preview", withExtension: "css"),
                  let src = try? String(contentsOf: url, encoding: .utf8) else {
                return "body{font-family:-apple-system,sans-serif;padding:24px;}"
            }
            return src
        }()

        func load(
            markdown: String,
            into webView: WKWebView,
            baseURL: URL?,
            fontSize: Double,
            maxWidthRem: Double,
            lineHeight: Double,
            isDark: Bool
        ) {
            let signature = "\(isDark)|\(fontSize)|\(maxWidthRem)|\(lineHeight)|\(baseURL?.path ?? "")|\(markdown)"
            guard signature != lastSignature else { return }
            lastSignature = signature

            let escaped = Self.jsonString(markdown)
            let themeClass = isDark ? "theme-dark" : "theme-light"
            let html = """
            <!DOCTYPE html>
            <html class="\(themeClass)">
            <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
            :root { --base-font-size: \(fontSize)px; }
            \(previewCSS)
            body { line-height: \(lineHeight); }
            .markdown-body { max-width: \(maxWidthRem)rem; line-height: \(lineHeight); }
            </style>
            <script>
            \(markedJS)
            </script>
            </head>
            <body>
            <article id="content" class="markdown-body"></article>
            <script>
            (function() {
              try {
                if (window.marked && marked.setOptions) {
                  marked.setOptions({
                    gfm: true,
                    breaks: false,
                    headerIds: true,
                    mangle: false
                  });
                }
                var md = \(escaped);
                var html = (window.marked && marked.parse) ? marked.parse(md) : md;
                document.getElementById('content').innerHTML = html;
              } catch (e) {
                document.getElementById('content').innerHTML =
                  '<pre class="error">' + String(e) + '</pre>';
              }
            })();
            </script>
            </body>
            </html>
            """

            let base = baseURL ?? URL(fileURLWithPath: "/")
            webView.loadHTMLString(html, baseURL: base)
        }

        /// Encode a Swift string as a JSON string literal for safe JS embedding.
        private static func jsonString(_ value: String) -> String {
            // Top-level String needs `.fragmentsAllowed`; without it JSONSerialization throws.
            if let data = try? JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed]),
               let encoded = String(data: data, encoding: .utf8) {
                return encoded
            }
            // Manual fallback (should rarely run).
            let escaped = value
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\r", with: "\\r")
                .replacingOccurrences(of: "\t", with: "\\t")
            return "\"\(escaped)\""
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            // Allow initial document load.
            if navigationAction.navigationType == .other {
                decisionHandler(.allow)
                return
            }

            // Open external links in the default browser.
            if url.scheme == "http" || url.scheme == "https" || url.scheme == "mailto" {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            // Allow same-document fragment navigation.
            if url.scheme == "about" {
                decisionHandler(.allow)
                return
            }

            // Local file links: open with system if it's a navigation click.
            if url.isFileURL, navigationAction.navigationType == .linkActivated {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.cancel)
        }
    }
}
