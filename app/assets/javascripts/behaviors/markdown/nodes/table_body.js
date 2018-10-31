import { Node } from 'tiptap'

export default class TableBodyNode extends Node {
  get name() {
    return 'table_body'
  }

  get schema() {
    return {
      content: 'table_row+',
      parseDOM: [
        { tag: 'tbody' },
      ],
      toDOM: node => ['tbody', 0],
    }
  }

  toMarkdown(state, node) {
    state.flushClose(1);
    state.renderContent(node);
    state.closeBlock(node);
  }
}
