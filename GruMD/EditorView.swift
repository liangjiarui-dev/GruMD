import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct EditorView: View {
    @Binding var document: MarkdownDocument
    var fileURL: URL?

    @AppStorage("defaultLayout") private var defaultLayoutRaw: String = LayoutMode.previewOnly.rawValue
    @AppStorage("previewFontSize") private var previewFontSize: Double = 17
    @AppStorage("editorFontSize") private var editorFontSize: Double = 13.5
    @AppStorage("autoReloadExternal") private var autoReloadExternal: Bool = true
    @AppStorage("showStatusBar") private var showStatusBar: Bool = true
    @AppStorage("editorMono") private var editorMono: Bool = true
    @AppStorage("editorLineWrapping") private var editorLineWrapping: Bool = true
    @AppStorage("previewMaxWidth") private var previewMaxWidth: Double = 42
    @AppStorage("previewLineHeight") private var previewLineHeight: Double = 1.7

    @State private var layout: LayoutMode = .previewOnly

    private var findAvailable: Bool { layout == .split }
    @State private var didApplyDefaultLayout = false
    @State private var showReloadAlert = false
    @State private var pendingDiskText: String?
    @State private var lastKnownTextOnDisk: String = ""
    @State private var isReloading = false
    @State private var watcherBox = FileWatcherBox()

    // Find / replace
    @State private var showFindBar = false
    @State private var showReplaceFields = false
    @State private var findQuery = ""
    @State private var replaceText = ""
    @State private var findCaseSensitive = false
    @State private var findMatches: [TextMatch] = []
    @State private var findIndex: Int = -1
    @State private var findLineHint: Int?

    @State private var dropTargeted = false
    @State private var exportError: String?

    @Environment(\.colorScheme) private var colorScheme

    private var wordCount: Int {
        document.text.split { $0.isWhitespace || $0.isNewline }.count
    }

    private var lineCount: Int {
        max(document.text.components(separatedBy: .newlines).count, 1)
    }

    private var charCount: Int {
        document.text.count
    }

    var body: some View {
        documentWorkspace
        .background(GruMDTheme.windowBackground)
        .onAppear {
            if !didApplyDefaultLayout {
                layout = LayoutMode.resolved(defaultLayoutRaw)
                didApplyDefaultLayout = true
            }
            lastKnownTextOnDisk = document.text
            rebindWatcher()
        }
        .onDisappear { watcherBox.watcher.stop() }
        .onChange(of: fileURL?.path) { _ in
            lastKnownTextOnDisk = document.text
            rebindWatcher()
        }
        .onChange(of: document.text) { newValue in
            if newValue == lastKnownTextOnDisk {
                watcherBox.watcher.ignoreEvents(for: 1.0)
            }
            refreshFindMatches(resetIndex: false)
        }
        .onChange(of: findQuery) { _ in refreshFindMatches(resetIndex: true) }
        .onChange(of: findCaseSensitive) { _ in refreshFindMatches(resetIndex: true) }
        .onChange(of: autoReloadExternal) { _ in rebindWatcher() }
        .onChange(of: layout) { newLayout in
            // Find works on the editor text — hide it in Preview-only.
            if newLayout == .previewOnly {
                closeFind()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .grumdShowFind)) { _ in
            guard findAvailable else { return }
            openFind(replace: false)
        }
        .onReceive(NotificationCenter.default.publisher(for: .grumdShowReplace)) { _ in
            guard findAvailable else { return }
            openFind(replace: true)
        }
        .onReceive(NotificationCenter.default.publisher(for: .grumdExportHTML)) { _ in
            exportHTML()
        }
        .onReceive(NotificationCenter.default.publisher(for: .grumdPrint)) { _ in
            printDocument()
        }
        .alert("File Changed on Disk", isPresented: $showReloadAlert) {
            Button("Reload from Disk", role: .destructive) {
                if let pending = pendingDiskText {
                    isReloading = true
                    document.text = pending
                    lastKnownTextOnDisk = pending
                    isReloading = false
                }
                pendingDiskText = nil
            }
            Button("Keep My Edits", role: .cancel) { pendingDiskText = nil }
        } message: {
            Text("This Markdown file was modified by another app. Reload and discard unsaved changes in GruMD, or keep your current edits?")
        }
        .alert("Export Failed", isPresented: Binding(
            get: { exportError != nil },
            set: { if !$0 { exportError = nil } }
        )) {
            Button("OK", role: .cancel) { exportError = nil }
        } message: {
            Text(exportError ?? "")
        }
    }

    private var documentWorkspace: some View {
        VStack(spacing: 0) {
            chromeBar
            if showFindBar && layout != .previewOnly {
                FindReplaceBar(
                    query: $findQuery,
                    replacement: $replaceText,
                    caseSensitive: $findCaseSensitive,
                    showReplace: $showReplaceFields,
                    matchCount: findMatches.count,
                    currentIndex: findIndex,
                    onNext: { stepFind(1) },
                    onPrevious: { stepFind(-1) },
                    onReplace: replaceCurrent,
                    onReplaceAll: replaceAll,
                    onClose: closeFind
                )
            }
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if showStatusBar {
                statusBar
            }
        }
    }

    // MARK: - Chrome

    private var chromeBar: some View {
        HStack(spacing: 12) {
            layoutControl

            Button {
                toggleFind(replace: false)
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(
                        !findAvailable
                            ? Color.secondary.opacity(0.35)
                            : (showFindBar ? GruMDTheme.accent : Color.secondary)
                    )
                    .frame(width: 28, height: 26)
            }
            .buttonStyle(.plain)
            .disabled(!findAvailable)
            .help(
                findAvailable
                    ? (showFindBar ? "Hide find" : "Find")
                    : "Switch to Split to search in the editor"
            )
            Spacer(minLength: 8)
            fileTitle
            Spacer(minLength: 8)

            Menu {
                Button("Export HTML…") { exportHTML() }
                Button("Print…") { printDocument() }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .menuStyle(.borderlessButton)
            .frame(width: 36)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            ZStack {
                Rectangle().fill(.ultraThinMaterial)
                LinearGradient(
                    colors: [
                        Color.primary.opacity(colorScheme == .dark ? 0.06 : 0.03),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.primary.opacity(0.06)).frame(height: 0.5)
        }
    }

    private var layoutControl: some View {
        HStack(spacing: 0) {
            ForEach(LayoutMode.chromeModes) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) { layout = mode }
                } label: {
                    Image(systemName: mode.systemImage)
                        .font(.system(size: 12, weight: .semibold))
                        .frame(width: 30, height: 26)
                        .foregroundStyle(layout == mode ? Color.white : Color.secondary)
                        .background {
                            if layout == mode {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(GruMDTheme.accent)
                                    .shadow(color: GruMDTheme.accent.opacity(0.35), radius: 3, y: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
                .help(mode.title)
            }
        }
        .padding(3)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.06))
        }
    }

    private var fileTitle: some View {
        HStack(spacing: 6) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(GruMDTheme.accent)
            Text(fileURL?.lastPathComponent ?? "Untitled")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            Capsule(style: .continuous)
                .fill(Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.05))
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        mainWorkspace
    }

    @ViewBuilder
    private var mainWorkspace: some View {
        switch layout {
        case .split:
            HSplitView {
                editorColumn.frame(minWidth: 280)
                previewColumn.frame(minWidth: 300)
            }
        case .previewOnly:
            previewColumn
        }
    }

    private var editorColumn: some View {
        VStack(spacing: 0) {
            paneHeader(title: "Editor", systemImage: "chevron.left.forwardslash.chevron.right")
            TextEditor(text: $document.text)
                .font(editorFont)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(GruMDTheme.contentBackground)
                .overlay {
                    if dropTargeted {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(GruMDTheme.accent, lineWidth: 2)
                            .padding(6)
                    }
                }
                .onDrop(of: [UTType.fileURL], isTargeted: $dropTargeted, perform: handleDrop)
                .accessibilityLabel("Markdown editor")
        }
    }

    private var previewColumn: some View {
        VStack(spacing: 0) {
            paneHeader(title: "Preview", systemImage: "eye")
            MarkdownPreview(
                markdown: document.text,
                baseURL: fileURL?.deletingLastPathComponent(),
                fontSize: previewFontSize,
                maxWidthRem: previewMaxWidth,
                lineHeight: previewLineHeight,
                isDark: colorScheme == .dark
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GruMDTheme.contentBackground)
            .accessibilityLabel("Markdown preview")
        }
    }

    private func paneHeader(title: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(GruMDTheme.accent)
            Text(title.uppercased())
                .font(GruMDTheme.paneLabel)
                .foregroundStyle(.secondary)
                .tracking(0.6)
            Spacer()
            if let findLineHint {
                Text("Line \(findLineHint)")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(Color.primary.opacity(colorScheme == .dark ? 0.06 : 0.03))
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.primary.opacity(0.06)).frame(height: 0.5)
        }
    }

    private var statusBar: some View {
        HStack(spacing: 14) {
            Label("\(lineCount) lines", systemImage: "text.alignleft")
            Label("\(wordCount) words", systemImage: "textformat.abc")
            Label("\(charCount) chars", systemImage: "character")
            if showFindBar, !findQuery.isEmpty {
                Text(findMatches.isEmpty ? "No matches" : "Find \(max(findIndex, 0) + 1)/\(findMatches.count)")
                    .foregroundStyle(GruMDTheme.accent)
            }
            Spacer()
            if autoReloadExternal {
                Label("Live reload", systemImage: "arrow.triangle.2.circlepath")
            }
            Text("GruMD 1.3.4")
                .foregroundStyle(.tertiary)
        }
        .labelStyle(.titleAndIcon)
        .font(GruMDTheme.statusFont)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background {
            ZStack {
                Rectangle().fill(.bar)
                Rectangle().fill(Color.primary.opacity(0.02))
            }
        }
        .overlay(alignment: .top) {
            Rectangle().fill(Color.primary.opacity(0.06)).frame(height: 0.5)
        }
    }

    private var editorFont: Font {
        if editorMono {
            return .system(size: editorFontSize, design: .monospaced)
        }
        return .system(size: editorFontSize, design: .default)
    }

    // MARK: - Find

    private func toggleFind(replace: Bool) {
        guard findAvailable else { return }
        if showFindBar && !replace {
            // Magnifier acts as toggle when find is already open.
            closeFind()
            return
        }
        openFind(replace: replace)
    }

    private func openFind(replace: Bool) {
        guard findAvailable else { return }
        showFindBar = true
        if replace {
            showReplaceFields = true
        }
        refreshFindMatches(resetIndex: true)
    }

    private func closeFind() {
        showFindBar = false
        findLineHint = nil
    }

    private func refreshFindMatches(resetIndex: Bool) {
        findMatches = FindReplaceSupport.matches(
            in: document.text,
            query: findQuery,
            caseSensitive: findCaseSensitive
        )
        if findMatches.isEmpty {
            findIndex = -1
            findLineHint = nil
        } else if resetIndex || findIndex < 0 || findIndex >= findMatches.count {
            findIndex = 0
            updateFindLineHint()
        } else {
            updateFindLineHint()
        }
    }

    private func stepFind(_ delta: Int) {
        guard !findMatches.isEmpty else { return }
        if findIndex < 0 {
            findIndex = 0
        } else {
            findIndex = (findIndex + delta + findMatches.count) % findMatches.count
        }
        updateFindLineHint()
    }

    private func updateFindLineHint() {
        guard findIndex >= 0, findIndex < findMatches.count else {
            findLineHint = nil
            return
        }
        findLineHint = FindReplaceSupport.lineNumber(of: findMatches[findIndex], in: document.text)
    }

    private func replaceCurrent() {
        guard findIndex >= 0, findIndex < findMatches.count else { return }
        let match = findMatches[findIndex]
        document.text.replaceSubrange(match.range, with: replaceText)
        refreshFindMatches(resetIndex: false)
        if findMatches.isEmpty {
            findIndex = -1
        } else {
            findIndex = min(findIndex, findMatches.count - 1)
            updateFindLineHint()
        }
    }

    private func replaceAll() {
        document.text = FindReplaceSupport.replaceAll(
            in: document.text,
            query: findQuery,
            replacement: replaceText,
            caseSensitive: findCaseSensitive
        )
        refreshFindMatches(resetIndex: true)
    }

    // MARK: - Export / Print / Open

    private func exportHTML() {
        let html = MarkdownHTML.fullDocument(
            markdown: document.text,
            fontSize: previewFontSize,
            maxWidthRem: previewMaxWidth,
            isDark: false
        )
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.html]
        panel.nameFieldStringValue = (fileURL?.deletingPathExtension().lastPathComponent ?? "Untitled") + ".html"
        panel.canCreateDirectories = true
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            do {
                try html.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                exportError = error.localizedDescription
            }
        }
    }

    private func printDocument() {
        let html = MarkdownHTML.fullDocument(
            markdown: document.text,
            fontSize: previewFontSize,
            maxWidthRem: previewMaxWidth,
            isDark: false
        )
        PrintSupport.printHTML(html, jobTitle: fileURL?.lastPathComponent ?? "GruMD")
    }

    private func openPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText, UTType(filenameExtension: "md") ?? .plainText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            openRecent(url)
        }
    }

    private func openRecent(_ url: URL) {
        NSDocumentController.shared.openDocument(withContentsOf: url, display: true) { _, _, _ in }
    }

    // MARK: - Drop images

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        var handled = false
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                    let url: URL?
                    if let data = item as? Data {
                        url = URL(dataRepresentation: data, relativeTo: nil)
                    } else if let u = item as? URL {
                        url = u
                    } else {
                        url = nil
                    }
                    guard let file = url else { return }
                    let ext = file.pathExtension.lowercased()
                    guard ["png", "jpg", "jpeg", "gif", "webp", "tiff", "bmp", "heic"].contains(ext) else { return }
                    DispatchQueue.main.async {
                        insertImageMarkdown(for: file)
                    }
                }
                handled = true
            }
        }
        return handled
    }

    private func insertImageMarkdown(for imageURL: URL) {
        let rel: String
        if let base = fileURL?.deletingLastPathComponent() {
            rel = relativePath(from: base, to: imageURL)
        } else {
            rel = imageURL.lastPathComponent
        }
        let alt = imageURL.deletingPathExtension().lastPathComponent
        let snippet = "![\(alt)](\(rel))"
        if document.text.isEmpty || document.text.hasSuffix("\n") {
            document.text += snippet + "\n"
        } else {
            document.text += "\n" + snippet + "\n"
        }
    }

    private func relativePath(from base: URL, to target: URL) -> String {
        let baseParts = base.standardizedFileURL.pathComponents
        let targetParts = target.standardizedFileURL.pathComponents
        var i = 0
        while i < baseParts.count, i < targetParts.count, baseParts[i] == targetParts[i] {
            i += 1
        }
        let ups = Array(repeating: "..", count: baseParts.count - i)
        let downs = Array(targetParts[i...])
        let parts = ups + downs
        return parts.isEmpty ? target.lastPathComponent : parts.joined(separator: "/")
    }

    // MARK: - File watch

    private func rebindWatcher() {
        watcherBox.watcher.stop()
        guard autoReloadExternal, let fileURL else { return }
        watcherBox.watcher.watch(url: fileURL) {
            handleExternalChange(at: fileURL)
        }
    }

    private func handleExternalChange(at url: URL) {
        guard !isReloading else { return }
        guard let data = try? Data(contentsOf: url),
              let diskText = String(data: data, encoding: .utf8) else { return }

        if diskText == document.text {
            lastKnownTextOnDisk = diskText
            return
        }
        if diskText == lastKnownTextOnDisk { return }

        if document.text == lastKnownTextOnDisk {
            isReloading = true
            document.text = diskText
            lastKnownTextOnDisk = diskText
            isReloading = false
            watcherBox.watcher.ignoreEvents(for: 0.5)
            return
        }

        pendingDiskText = diskText
        showReloadAlert = true
    }
}

private final class FileWatcherBox {
    let watcher = FileWatcher()
}

extension Notification.Name {
    static let grumdShowFind = Notification.Name("grumdShowFind")
    static let grumdShowReplace = Notification.Name("grumdShowReplace")
    static let grumdExportHTML = Notification.Name("grumdExportHTML")
    static let grumdPrint = Notification.Name("grumdPrint")
}
