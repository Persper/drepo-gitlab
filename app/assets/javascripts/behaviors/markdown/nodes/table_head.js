import { Node } from 'tiptap'

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
