import AppKit
import WebKit

enum PrintSupport {
    /// Load HTML into a temporary WKWebView and run the system print panel.
    static func printHTML(_ html: String, jobTitle: String) {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        let webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 800, height: 1000), configuration: config)
        // Keep a strong reference until print finishes.
        PrintSession.shared.begin(webView: webView, html: html, jobTitle: jobTitle)
    }
}

private final class PrintSession: NSObject, WKNavigationDelegate {
    static let shared = PrintSession()
    private var webView: WKWebView?
    private var jobTitle: String = "GruMD"

    func begin(webView: WKWebView, html: String, jobTitle: String) {
        self.webView = webView
        self.jobTitle = jobTitle
        webView.navigationDelegate = self
        webView.loadHTMLString(html, baseURL: nil)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let info = NSPrintInfo.shared
            info.horizontalPagination = .fit
            info.verticalPagination = .automatic
            info.isHorizontallyCentered = true
            info.isVerticallyCentered = false
            let op = webView.printOperation(with: info)
            op.jobTitle = self.jobTitle
            op.showsPrintPanel = true
            op.showsProgressPanel = true
            if let window = NSApp.keyWindow {
                op.runModal(for: window, delegate: self, didRun: #selector(self.printDidRun(_:success:contextInfo:)), contextInfo: nil)
            } else {
                op.run()
                self.webView = nil
            }
        }
    }

    @objc private func printDidRun(_ op: NSPrintOperation, success: Bool, contextInfo: UnsafeMutableRawPointer?) {
        webView = nil
    }
}
