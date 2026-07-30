import AppKit
import SwiftUI

struct MarkdownCodeBlockView: View {
    let code: String
    let language: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                if let language, !language.isEmpty {
                    Text(language)
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                Button {
                    MarkdownCodeBlockCopyAction.copy(code)
                } label: {
                    Label("复制代码", systemImage: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("复制此代码块")
                .accessibilityLabel("复制此代码块")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)

            Divider()

            Text(code.isEmpty ? " " : code)
                .font(.callout.monospaced())
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
        }
        .background(Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 7))
        .overlay {
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.secondary.opacity(0.14), lineWidth: 0.5)
        }
    }
}

enum MarkdownCodeBlockCopyAction {
    @discardableResult
    static func copy(
        _ code: String,
        to pasteboard: NSPasteboard = .general
    ) -> Bool {
        pasteboard.clearContents()
        return pasteboard.setString(code, forType: .string)
    }
}
