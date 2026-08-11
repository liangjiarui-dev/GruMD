import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// Full-window home screen when no file is open.
/// Layout: one centered card — never dump content at the window bottom.
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

            // Vertically + horizontally center the home card.
            GeometryReader { geo in
                ScrollView {
                    VStack {
                        Spacer(minLength: 0)
                        homeCard
                            .frame(maxWidth: 720)
                            .padding(.horizontal, 32)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geo.size.height)
                }
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

    // MARK: - Card

    private var homeCard: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Header row
            HStack(alignment: .center, spacing: 16) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.12), radius: 10, y: 4)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        Text("GruMD")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                        Text("LOCAL")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .tracking(0.8)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background {
                                Capsule(style: .continuous)
                                    .fill(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.06))
                            }
                    }
                    Text("Markdown, kept local.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)
            }

            Text("Open a single `.md` file on this Mac. No knowledge base, no plugins, no AI, no cloud.")
                .font(.system(size: 13.5, design: .rounded))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Actions — always visible, full width of card
            HStack(spacing: 12) {
                actionButton(
                    title: "Open File…",
                    subtitle: "⌘O",
                    systemImage: "folder.fill",
                    prominent: true,
                    action: onOpen
                )
                actionButton(
                    title: "New Document",
                    subtitle: "⌘N",
                    systemImage: "doc.badge.plus",
                    prominent: false,
                    action: onNew
                )
            }

            Divider().opacity(0.5)

            // Recent
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)

                if recentURLs.isEmpty {
                    emptyRecent
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(recentURLs.prefix(8).enumerated()), id: \.offset) { index, url in
                            recentRow(url)
                            if index < min(recentURLs.count, 8) - 1 {
                                Divider().padding(.leading, 44)
                            }
                        }
                    }
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.primary.opacity(colorScheme == .dark ? 0.06 : 0.03))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
                    }
                }
            }

            // Footer
            HStack {
                Text("Crafted by Gru")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("v1.3.8")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.quaternary)
            }
        }
        .padding(28)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.35 : 0.08), radius: 24, y: 10)
    }

    private var emptyRecent: some View {
        HStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.tertiary)
            Text("No recent files — open a Markdown document to see it here.")
                .font(.system(size: 12.5, design: .rounded))
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(colorScheme == .dark ? 0.06 : 0.03))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            GruMDTheme.windowBackground
            RadialGradient(
                colors: [
                    GruMDTheme.accent.opacity(colorScheme == .dark ? 0.14 : 0.08),
                    Color.clear
                ],
                center: UnitPoint(x: 0.15, y: 0.1),
                startRadius: 10,
                endRadius: 480
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Controls

    private func actionButton(
        title: String,
        subtitle: String,
        systemImage: String,
        prominent: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(prominent ? Color.white : GruMDTheme.accent)
                    .frame(width: 32, height: 32)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(prominent ? Color.white.opacity(0.18) : GruMDTheme.accent.opacity(0.12))
                    }

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(prominent ? Color.white : Color.primary)
                    Text(subtitle)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(prominent ? Color.white.opacity(0.75) : Color.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(prominent ? GruMDTheme.accent : Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.05))
            }
            .overlay {
                if !prominent {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                }
            }
        }
        .buttonStyle(.plain)
        .keyboardShortcut(KeyEquivalent(subtitle.contains("O") ? "o" : "n"), modifiers: [.command])
    }

    private func recentRow(_ url: URL) -> some View {
        let key = url.path
        return Button {
            onOpenRecent(url)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "doc.richtext.fill")
                    .font(.system(size: 13))
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
                    Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.04)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            hoveredRecent = hovering ? key : (hoveredRecent == key ? nil : hoveredRecent)
        }
    }
}
