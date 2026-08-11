import SwiftUI

struct EditorView: View {
    @Binding var document: MarkdownDocument
    var fileURL: URL?

    @AppStorage("defaultLayout") private var defaultLayoutRaw: String = LayoutMode.split.rawValue
    @AppStorage("previewFontSize") private var previewFontSize: Double = 17
    @AppStorage("editorFontSize") private var editorFontSize: Double = 13.5
    @AppStorage("autoReloadExternal") private var autoReloadExternal: Bool = true
    @AppStorage("showStatusBar") private var showStatusBar: Bool = true

    @State private var layout: LayoutMode = .split
    @State private var didApplyDefaultLayout = false
    @State private var showReloadAlert = false
    @State private var pendingDiskText: String?
    @State private var lastKnownTextOnDisk: String = ""
    @State private var isReloading = false
    @State private var watcherBox = FileWatcherBox()
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
        VStack(spacing: 0) {
            chromeBar
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if showStatusBar {
                statusBar
            }
        }
        .background(GruMDTheme.windowBackground)
        .onAppear {
            if !didApplyDefaultLayout {
                layout = LayoutMode(rawValue: defaultLayoutRaw) ?? .split
                didApplyDefaultLayout = true
            }
            lastKnownTextOnDisk = document.text
            rebindWatcher()
        }
        .onDisappear {
            watcherBox.watcher.stop()
        }
        .onChange(of: fileURL?.path) { _ in
            lastKnownTextOnDisk = document.text
            rebindWatcher()
        }
        .onChange(of: document.text) { newValue in
            if newValue == lastKnownTextOnDisk {
                watcherBox.watcher.ignoreEvents(for: 1.0)
            }
        }
        .onChange(of: autoReloadExternal) { _ in
            rebindWatcher()
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
            Button("Keep My Edits", role: .cancel) {
                pendingDiskText = nil
            }
        } message: {
            Text("This Markdown file was modified by another app. Reload and discard unsaved changes in GruMD, or keep your current edits?")
        }
    }

    // MARK: - Chrome

    private var chromeBar: some View {
        HStack(spacing: 14) {
            layoutControl

            Spacer(minLength: 8)

            fileTitle

            Spacer(minLength: 8)

            // Visual balance for traffic lights / title
            Color.clear.frame(width: 120, height: 1)
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
            Rectangle()
                .fill(Color.primary.opacity(0.06))
                .frame(height: 0.5)
        }
    }

    private var layoutControl: some View {
        HStack(spacing: 0) {
            ForEach(LayoutMode.allCases) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        layout = mode
                    }
                } label: {
                    Image(systemName: mode.systemImage)
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 34, height: 26)
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
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
        }
    }

    private var fileTitle: some View {
        HStack(spacing: 6) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(GruMDTheme.accent)
            Text(fileURL?.lastPathComponent ?? "Untitled")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
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
        switch layout {
        case .split:
            HSplitView {
                editorPane
                    .frame(minWidth: 260)
                previewPane
                    .frame(minWidth: 280)
            }
        case .editorOnly:
            editorPane
        case .previewOnly:
            previewPane
        }
    }

    private var editorPane: some View {
        VStack(spacing: 0) {
            paneHeader(title: "Editor", systemImage: "chevron.left.forwardslash.chevron.right")
            TextEditor(text: $document.text)
                .font(GruMDTheme.editorFont(size: editorFontSize))
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(GruMDTheme.contentBackground)
                .accessibilityLabel("Markdown editor")
        }
    }

    private var previewPane: some View {
        VStack(spacing: 0) {
            paneHeader(title: "Preview", systemImage: "eye")
            MarkdownPreview(
                markdown: document.text,
                baseURL: fileURL?.deletingLastPathComponent(),
                fontSize: previewFontSize,
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
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(Color.primary.opacity(colorScheme == .dark ? 0.06 : 0.03))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.primary.opacity(0.06))
                .frame(height: 0.5)
        }
    }

    // MARK: - Status

    private var statusBar: some View {
        HStack(spacing: 14) {
            Label("\(lineCount) lines", systemImage: "text.alignleft")
            Label("\(wordCount) words", systemImage: "textformat.abc")
            Label("\(charCount) chars", systemImage: "character")

            Spacer()

            if autoReloadExternal {
                Label("Live reload", systemImage: "arrow.triangle.2.circlepath")
                    .foregroundStyle(.secondary)
            }

            Text("GruMD 1.1.1")
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
            Rectangle()
                .fill(Color.primary.opacity(0.06))
                .frame(height: 0.5)
        }
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
              let diskText = String(data: data, encoding: .utf8) else {
            return
        }

        if diskText == document.text {
            lastKnownTextOnDisk = diskText
            return
        }
        if diskText == lastKnownTextOnDisk {
            return
        }

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
