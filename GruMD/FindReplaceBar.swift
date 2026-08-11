import SwiftUI

struct FindReplaceBar: View {
    @Binding var query: String
    @Binding var replacement: String
    @Binding var caseSensitive: Bool
    @Binding var showReplace: Bool

    let matchCount: Int
    let currentIndex: Int // 0-based, or -1
    let onNext: () -> Void
    let onPrevious: () -> Void
    let onReplace: () -> Void
    let onReplaceAll: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Find", text: $query)
                    .textFieldStyle(.plain)
                    .frame(minWidth: 140)

                Text(matchLabel)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 72, alignment: .leading)

                Button(action: onPrevious) {
                    Image(systemName: "chevron.up")
                }
                .buttonStyle(.borderless)
                .disabled(matchCount == 0)
                .help("Previous match")

                Button(action: onNext) {
                    Image(systemName: "chevron.down")
                }
                .buttonStyle(.borderless)
                .disabled(matchCount == 0)
                .help("Next match")

                Toggle("Aa", isOn: $caseSensitive)
                    .toggleStyle(.button)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .help("Case sensitive")

                Button {
                    showReplace.toggle()
                } label: {
                    Image(systemName: showReplace ? "chevron.up.circle" : "chevron.down.circle")
                }
                .buttonStyle(.borderless)
                .help("Show replace")

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
                .help("Close")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            if showReplace {
                HStack(spacing: 10) {
                    Image(systemName: "text.badge.plus")
                        .foregroundStyle(.secondary)
                    TextField("Replace with", text: $replacement)
                        .textFieldStyle(.plain)
                    Button("Replace", action: onReplace)
                        .disabled(matchCount == 0)
                    Button("Replace All", action: onReplaceAll)
                        .disabled(matchCount == 0 || query.isEmpty)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
        }
        .background(.bar)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.primary.opacity(0.08))
                .frame(height: 0.5)
        }
    }

    private var matchLabel: String {
        if query.isEmpty { return "" }
        if matchCount == 0 { return "No results" }
        let idx = max(currentIndex, 0) + 1
        return "\(idx) of \(matchCount)"
    }
}
