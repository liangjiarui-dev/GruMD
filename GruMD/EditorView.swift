import SwiftUI

struct EditorView: View {
    @Binding var document: MarkdownDocument
    var fileURL: URL?

    @AppStorage("defaultLayout") private var defaultLayoutRaw: String = LayoutMode.split.rawValue
    @AppStorage("previewFontSize") private var previewFontSize: Double = 16
    @AppStorage("editorFontSize") private var editorFontSize: Double = 14
    @AppStorage("autoReloadExternal") private var autoReloadExternal: Bool = true

    @State private var layout: LayoutMode = .split
    @State private var didApplyDefaultLayout = false
    @State private var showReloadAlert = false
    @State private var pendingDiskText: String?
    @State private var lastKnownTextOnDisk: String = ""
    @State private var isReloading = false

    /// Held via reference box so SwiftUI does not re-create the watcher every body pass.
    @State private var watcherBox = FileWatcherBox()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 0) {
            layoutBar
            Divider()
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(nsColor: .textBackgroundColor))
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

    /// In-window control (avoids macOS 26 toolbar hosting crash with segmented Picker).
    private var layoutBar: some View {
        HStack(spacing: 8) {
            Text("Layout")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("", selection: $layout) {
                Text("Split").tag(LayoutMode.split)
                Text("Editor").tag(LayoutMode.editorOnly)
                Text("Preview").tag(LayoutMode.previewOnly)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 260)
            .labelsHidden()
            .controlSize(.small)

            Spacer()

            if let fileURL {
                Text(fileURL.lastPathComponent)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.bar)
    }

    @ViewBuilder
    private var content: some View {
        switch layout {
        case .split:
            HSplitView {
                editorPane
                    .frame(minWidth: 200)
                previewPane
                    .frame(minWidth: 200)
            }
        case .editorOnly:
            editorPane
        case .previewOnly:
            previewPane
        }
    }

    private var editorPane: some View {
        TextEditor(text: $document.text)
            .font(.system(size: editorFontSize, design: .monospaced))
            .scrollContentBackground(.hidden)
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .textBackgroundColor))
            .accessibilityLabel("Markdown editor")
    }

    private var previewPane: some View {
        MarkdownPreview(
            markdown: document.text,
            baseURL: fileURL?.deletingLastPathComponent(),
            fontSize: previewFontSize,
            isDark: colorScheme == .dark
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
        .accessibilityLabel("Markdown preview")
    }

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

/// Stable box for FileWatcher identity under `@State`.
private final class FileWatcherBox {
    let watcher = FileWatcher()
}
