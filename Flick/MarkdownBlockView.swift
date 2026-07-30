import Markdown
import SwiftUI

struct MarkdownBlockView: View {
    let source: String

    var body: some View {
        let document = Document(parsing: source)

        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(document.children.enumerated()), id: \.offset) { _, block in
                MarkdownBlockRenderer.view(for: block)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

enum MarkdownBlockRenderer {
    static func view(for markup: Markup) -> AnyView {
        if let heading = markup as? Heading {
            return AnyView(
                SwiftUI.Text(MarkdownInlineRenderer.renderChildren(of: heading))
                    .font(headingFont(for: heading.level))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
        }

        if let paragraph = markup as? Paragraph {
            return AnyView(
                SwiftUI.Text(MarkdownInlineRenderer.renderChildren(of: paragraph))
                    .font(.callout)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            )
        }

        if let orderedList = markup as? OrderedList {
            return listView(
                items: Array(orderedList.children),
                marker: { index in "\(Int(orderedList.startIndex) + index)." }
            )
        }

        if let unorderedList = markup as? UnorderedList {
            return listView(
                items: Array(unorderedList.children),
                marker: { _ in "•" }
            )
        }

        if let blockQuote = markup as? BlockQuote {
            return AnyView(
                HStack(alignment: .top, spacing: 8) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.secondary.opacity(0.45))
                        .frame(width: 3)

                    childBlocks(of: blockQuote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 2)
            )
        }

        if let codeBlock = markup as? CodeBlock {
            return AnyView(
                MarkdownCodeBlockView(
                    code: codeBlock.code,
                    language: codeBlock.language
                )
            )
        }

        if markup is ThematicBreak {
            return AnyView(Divider().padding(.vertical, 4))
        }

        return AnyView(childBlocks(of: markup))
    }

    private static func listView(
        items: [Markup],
        marker: @escaping (Int) -> String
    ) -> AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 7) {
                        SwiftUI.Text(marker(index))
                            .font(.callout.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 16, alignment: .trailing)

                        childBlocks(of: item)
                    }
                }
            }
            .padding(.leading, 4)
        )
    }

    private static func childBlocks(of markup: Markup) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(markup.children.enumerated()), id: \.offset) { _, child in
                view(for: child)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private static func headingFont(for level: Int) -> Font {
        switch level {
        case 1:
            return .title2.bold()
        case 2:
            return .title3.bold()
        case 3:
            return .headline
        default:
            return .subheadline.bold()
        }
    }
}
