import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// Full-window home screen when no file is open (replaces the old "welcome Markdown" Untitled).
struct LauncherView: View {
    var onOpen: () -> Void
    var onNew: () -> Void
    var onOpenRecent: (URL) -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var recentURLs: [URL] {
        NSDocumentController.shared.recentDocumentURLs.filter {
            ["md", "markdown", "mdown", "mkd", "txt"].contains($0.pathExtension.lowercased())
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)

            VStack(spacing: 28) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 96, height: 96)
                    .shadow(color: .black.opacity(0.2), radius: 12, y: 6)

                VStack(spacing: 8) {
                    Text("GruMD")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text("Open a Markdown file to get started.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    Button(action: onOpen) {
                        Label("Open…", systemImage: "folder")
                            .frame(minWidth: 120)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .keyboardShortcut("o", modifiers: [.command])

                    Button(action: onNew) {
                        Label("New", systemImage: "doc.badge.plus")
                            .frame(minWidth: 100)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .keyboardShortcut("n", modifiers: [.command])
                }
                .padding(.top, 4)

                if !recentURLs.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)

                        VStack(spacing: 0) {
                            ForEach(Array(recentURLs.prefix(8).enumerated()), id: \.offset) { index, url in
                                Button {
                                    onOpenRecent(url)
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: "doc.richtext")
                                            .foregroundStyle(GruMDTheme.accent)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(url.lastPathComponent)
                                                .font(.system(size: 13, weight: .medium))
                                                .lineLimit(1)
                                            Text(url.deletingLastPathComponent().path)
                                                .font(.system(size: 11))
                                                .foregroundStyle(.tertiary)
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                if index < min(recentURLs.count, 8) - 1 {
                                    Divider().padding(.leading, 36)
                                }
                            }
                        }
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.04))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
                        }
                    }
                    .frame(maxWidth: 420)
                    .padding(.top, 12)
                }
            }

            Spacer(minLength: 40)

            Text("GruMD 1.3.4")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GruMDTheme.windowBackground)
        .onAppear {
            // Prefer a friendly title over "Untitled" while on the home screen.
            if let window = NSApp.keyWindow {
                window.title = "GruMD"
                window.representedURL = nil
            }
        }
    }
}
