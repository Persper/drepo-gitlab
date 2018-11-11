import { Node } from 'tiptap'

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class TableNode extends Node {
  get name() {
    return 'table'
  }

  get schema() {
    return {
      content: 'table_head table_body',
      group: 'block',
      isolating: true,
      parseDOM: [
        { tag: 'table' },
      ],
      toDOM: node => ['table', 0],
    }
  }

  toMarkdown(state, node) {
    state.renderContent(node)
    state.closeBlock(node)
  }
}
