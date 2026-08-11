import SwiftUI

@main
struct GruMDApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            EditorView(document: file.$document, fileURL: file.fileURL)
        }
        .defaultSize(width: 1040, height: 700)
        .commands {
            CommandGroup(after: .toolbar) {
                // Reserved for future View menu items.
            }
        }

        Settings {
            SettingsView()
        }
    }
}

struct SettingsView: View {
    @AppStorage("defaultLayout") private var defaultLayout: String = LayoutMode.split.rawValue
    @AppStorage("previewFontSize") private var previewFontSize: Double = 17
    @AppStorage("editorFontSize") private var editorFontSize: Double = 13.5
    @AppStorage("autoReloadExternal") private var autoReloadExternal: Bool = true
    @AppStorage("showStatusBar") private var showStatusBar: Bool = true

    var body: some View {
        TabView {
            Form {
                Section {
                    Picker("Default layout", selection: $defaultLayout) {
                        ForEach(LayoutMode.allCases) { mode in
                            Label(mode.title, systemImage: mode.systemImage)
                                .tag(mode.rawValue)
                        }
                    }
                    Toggle("Show status bar", isOn: $showStatusBar)
                    Toggle("Reload when file changes on disk", isOn: $autoReloadExternal)
                } header: {
                    Text("General")
                } footer: {
                    Text("External reload keeps GruMD in sync when another app saves the same file.")
                }

                Section("Typography") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Editor")
                            Spacer()
                            Text("\(editorFontSize, specifier: "%.1f") pt")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        Slider(value: $editorFontSize, in: 11...20, step: 0.5)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Preview")
                            Spacer()
                            Text("\(previewFontSize, specifier: "%.0f") pt")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        Slider(value: $previewFontSize, in: 13...24, step: 1)
                    }
                }

                Section("About") {
                    LabeledContent("Version", value: "1.1.2")
                    LabeledContent("Build", value: "Local Markdown · Offline")
                }
            }
            .formStyle(.grouped)
            .padding()
            .frame(width: 460, height: 420)
            .tabItem {
                Label("General", systemImage: "gearshape")
            }
        }
    }
}
