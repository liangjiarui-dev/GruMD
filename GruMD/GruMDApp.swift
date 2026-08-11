import SwiftUI

@main
struct GruMDApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            EditorView(document: file.$document, fileURL: file.fileURL)
        }
        .defaultSize(width: 960, height: 640)

        Settings {
            SettingsView()
        }
    }
}

struct SettingsView: View {
    @AppStorage("defaultLayout") private var defaultLayout: String = LayoutMode.split.rawValue
    @AppStorage("previewFontSize") private var previewFontSize: Double = 16
    @AppStorage("editorFontSize") private var editorFontSize: Double = 14
    @AppStorage("autoReloadExternal") private var autoReloadExternal: Bool = true

    var body: some View {
        Form {
            Picker("Default Layout", selection: $defaultLayout) {
                ForEach(LayoutMode.allCases) { mode in
                    Text(mode.title).tag(mode.rawValue)
                }
            }
            Slider(value: $editorFontSize, in: 11...22, step: 1) {
                Text("Editor Font Size")
            } minimumValueLabel: {
                Text("11")
            } maximumValueLabel: {
                Text("22")
            }
            Slider(value: $previewFontSize, in: 12...24, step: 1) {
                Text("Preview Font Size")
            } minimumValueLabel: {
                Text("12")
            } maximumValueLabel: {
                Text("24")
            }
            Toggle("Reload when file changes on disk", isOn: $autoReloadExternal)
        }
        .padding(20)
        .frame(width: 420)
    }
}
