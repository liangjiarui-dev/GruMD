import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// Full-window home screen when no file is open.
/// Stays inside product boundaries: local files only, no vault / cloud / AI.
struct LauncherView: View {
    var onOpen: () -> Void
    var onNew: () -> Void
    var onOpenRecent: (URL) -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var hoveredRecent: String?

    private var recentURLs: [URL] {
        NSDocumentController.shared.recentDocumentURLs.filter {
            ["md", "markdown", "mdown", "mkd", "txt"].contains($0.pathExtension.lowercased())
        }
    }

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Text("LOCAL · OFFLINE")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background {
                            Capsule(style: .continuous)
                                .fill(Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.05))
                        }
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)

                Spacer(minLength: 24)

                // Main content: two columns when wide enough
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: 40) {
                        heroColumn
                            .frame(maxWidth: 340, alignment: .leading)
                        recentColumn
                            .frame(maxWidth: 380)
                    }
                    .padding(.horizontal, 48)

                    VStack(spacing: 32) {
                        heroColumn
                        recentColumn
                            .frame(maxWidth: 440)
                    }
                    .padding(.horizontal, 36)
                }

                Spacer(minLength: 24)

                footer
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if let window = NSApp.keyWindow {
                window.title = "GruMD"
                window.representedURL = nil
            }
        }
    }

    // MARK: - Layers

    private var backgroundLayer: some View {
        ZStack {
            GruMDTheme.windowBackground

            // Soft accent wash (top-leading), Apple-like restraint
            RadialGradient(
                colors: [
                    GruMDTheme.accent.opacity(colorScheme == .dark ? 0.18 : 0.10),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 20,
                endRadius: 420
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.primary.opacity(colorScheme == .dark ? 0.06 : 0.03),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 10,
                endRadius: 360
            )
            .ignoresSafeArea()
        }
    }

    private var heroColumn: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .center, spacing: 16) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.45 : 0.15), radius: 14, y: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("GruMD")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("Markdown, kept local.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            Text("Read and lightly edit a single `.md` file. No knowledge base, no plugins, no AI, no cloud.")
                .font(.system(size: 13.5, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)

            VStack(spacing: 10) {
                actionCard(
                    title: "Open File…",
                    subtitle: "Choose a Markdown file on this Mac",
                    systemImage: "folder.fill",
                    prominent: true,
                    shortcut: "⌘O",
                    action: onOpen
                )
                actionCard(
                    title: "New Document",
                    subtitle: "Blank file — write, then save where you want",
                    systemImage: "doc.badge.plus",
                    prominent: false,
                    shortcut: "⌘N",
                    action: onNew
                )
            }
            .padding(.top, 4)

            // Boundary reminders as quiet chips
            HStack(spacing: 8) {
                boundaryChip("Single file")
                boundaryChip("GFM preview")
                boundaryChip("Save with ⌘S")
            }
            .padding(.top, 4)
        }
    }

    private var recentColumn: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                Spacer()
                if !recentURLs.isEmpty {
                    Text("\(min(recentURLs.count, 10)) files")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
            }

            if recentURLs.isEmpty {
                emptyRecentCard
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(recentURLs.prefix(10).enumerated()), id: \.offset) { index, url in
                        recentRow(url)
                        if index < min(recentURLs.count, 10) - 1 {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.07), lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.25 : 0.06), radius: 16, y: 6)
            }
        }
    }

    private var emptyRecentCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(.tertiary)
            Text("No recent files yet")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
            Text("Files you open will show up here for quick access.")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 20)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.07), lineWidth: 0.5)
        }
    }

    private var footer: some View {
        HStack(spacing: 16) {
            Text("Local files only")
            Text("·")
                .foregroundStyle(.quaternary)
            Text("No account")
            Text("·")
                .foregroundStyle(.quaternary)
            Text("v1.3.5")
        }
        .font(.system(size: 11, design: .rounded))
        .foregroundStyle(.tertiary)
        .padding(.bottom, 18)
    }

    // MARK: - Pieces

    private func actionCard(
        title: String,
        subtitle: String,
        systemImage: String,
        prominent: Bool,
        shortcut: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(prominent ? Color.white : GruMDTheme.accent)
                    .frame(width: 36, height: 36)
                    .background {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(prominent ? Color.white.opacity(0.2) : GruMDTheme.accent.opacity(0.12))
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(prominent ? Color.white : Color.primary)
                    Text(subtitle)
                        .font(.system(size: 11.5, design: .rounded))
                        .foregroundStyle(prominent ? Color.white.opacity(0.85) : Color.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                Text(shortcut)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(prominent ? Color.white.opacity(0.7) : Color.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background {
                        Capsule(style: .continuous)
                            .fill(prominent ? Color.white.opacity(0.15) : Color.primary.opacity(0.06))
                    }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(prominent ? GruMDTheme.accent : Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.04))
            }
            .overlay {
                if !prominent {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                }
            }
            .shadow(
                color: prominent ? GruMDTheme.accent.opacity(0.35) : .clear,
                radius: 10,
                y: 4
            )
        }
        .buttonStyle(.plain)
        .keyboardShortcut(
            KeyEquivalent(shortcut.contains("O") ? "o" : "n"),
            modifiers: [.command]
        )
    }

    private func recentRow(_ url: URL) -> some View {
        let key = url.path
        return Button {
            onOpenRecent(url)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "doc.richtext.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(GruMDTheme.accent)
                    .frame(width: 28, height: 28)
                    .background {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(GruMDTheme.accent.opacity(0.12))
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(url.lastPathComponent)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                    Text(url.deletingLastPathComponent().path)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.quaternary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background {
                if hoveredRecent == key {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.05))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoveredRecent = hovering ? key : (hoveredRecent == key ? nil : hoveredRecent)
        }
    }

    private func boundaryChip(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background {
                Capsule(style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)
                    .background(Capsule(style: .continuous).fill(Color.primary.opacity(0.03)))
            }
    }
}
