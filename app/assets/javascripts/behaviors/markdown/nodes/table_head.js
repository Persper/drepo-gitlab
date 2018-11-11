import { Node } from 'tiptap'

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class TableHeadNode extends Node {
  get name() {
    return 'table_head'
  }

  get schema() {
    return {
      content: 'table_header_row',
      parseDOM: [
        { tag: 'thead' },
      ],
      toDOM: node => ['thead', 0],
    }
  }

  toMarkdown(state, node) {
    state.flushClose(1);
    state.renderContent(node);
    state.closeBlock(node);
  }
}
