import SwiftUI

@main
struct GruMDApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            EditorView(document: file.$document, fileURL: file.fileURL)
        }
        // Larger default workspace — not a tiny utility window.
        .defaultSize(width: 1320, height: 860)
        .commands {
            CommandGroup(after: .textEditing) {
                Button("Find…") {
                    NotificationCenter.default.post(name: .grumdShowFind, object: nil)
                }
                .keyboardShortcut("f", modifiers: [.command])

                Button("Find and Replace…") {
                    NotificationCenter.default.post(name: .grumdShowReplace, object: nil)
                }
                .keyboardShortcut("f", modifiers: [.command, .option])
            }

            CommandGroup(after: .saveItem) {
                Button("Export HTML…") {
                    NotificationCenter.default.post(name: .grumdExportHTML, object: nil)
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])

                Button("Print…") {
                    NotificationCenter.default.post(name: .grumdPrint, object: nil)
                }
                .keyboardShortcut("p", modifiers: [.command])
            }
        }

        Settings {
            SettingsView()
        }
    }
}

struct SettingsView: View {
    @AppStorage("defaultLayout") private var defaultLayout: String = LayoutMode.previewOnly.rawValue
    @AppStorage("previewFontSize") private var previewFontSize: Double = 17
    @AppStorage("editorFontSize") private var editorFontSize: Double = 13.5
    @AppStorage("autoReloadExternal") private var autoReloadExternal: Bool = true
    @AppStorage("showStatusBar") private var showStatusBar: Bool = true
    @AppStorage("editorMono") private var editorMono: Bool = true
    @AppStorage("editorLineWrapping") private var editorLineWrapping: Bool = true
    @AppStorage("previewMaxWidth") private var previewMaxWidth: Double = 42
    @AppStorage("previewLineHeight") private var previewLineHeight: Double = 1.7

    var body: some View {
        TabView {
            Form {
                Section {
                    Picker("Default layout", selection: $defaultLayout) {
                        ForEach(LayoutMode.chromeModes) { mode in
                            Label(mode.title, systemImage: mode.systemImage)
                                .tag(mode.rawValue)
                        }
                    }
                    Toggle("Show status bar", isOn: $showStatusBar)
                    Toggle("Reload when file changes on disk", isOn: $autoReloadExternal)
                } header: {
                    Text("General")
                }
                Section("About") {
                    LabeledContent("Version", value: "1.3.3")
                    LabeledContent("Build", value: "Local Markdown · Offline")
                }
            }
            .formStyle(.grouped)
            .padding()
            .frame(width: 480, height: 320)
            .tabItem { Label("General", systemImage: "gearshape") }

            Form {
                Section {
                    Toggle("Monospaced font", isOn: $editorMono)
                    Toggle("Line wrapping (preferred)", isOn: $editorLineWrapping)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Font size")
                            Spacer()
                            Text("\(editorFontSize, specifier: "%.1f") pt")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        Slider(value: $editorFontSize, in: 11...20, step: 0.5)
                    }
                } header: {
                    Text("Editor")
                } footer: {
                    Text("Line wrapping is a preference for future enhanced editors; system TextEditor follows system behavior.")
                }
            }
            .formStyle(.grouped)
            .padding()
            .frame(width: 480, height: 300)
            .tabItem { Label("Editor", systemImage: "square.and.pencil") }

            Form {
                Section("Preview") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Font size")
                            Spacer()
                            Text("\(previewFontSize, specifier: "%.0f") pt")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        Slider(value: $previewFontSize, in: 13...24, step: 1)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Max width")
                            Spacer()
                            Text("\(previewMaxWidth, specifier: "%.0f") rem")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        Slider(value: $previewMaxWidth, in: 28...64, step: 1)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Line height")
                            Spacer()
                            Text("\(previewLineHeight, specifier: "%.2f")")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        Slider(value: $previewLineHeight, in: 1.35...2.0, step: 0.05)
                    }
                }
            }
            .formStyle(.grouped)
            .padding()
            .frame(width: 480, height: 340)
            .tabItem { Label("Preview", systemImage: "eye") }
        }
    }
}
