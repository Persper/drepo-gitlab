import { Node } from 'tiptap'

export default class TableCellNode extends Node {
  get name() {
    return 'table_cell'
  }

  get schema() {
    return {
      attrs: {
        header: { default: false },
        align: { default: null }
      },
      content: 'inline*',
      isolating: true,
      parseDOM: [
        {
          tag: 'td, th',
          getAttrs: el => ({ header: el.tagName === 'TH', align: el.getAttribute('align') || el.style.textAlign })
        }
      ],
      toDOM: node => [node.attrs.header ? 'th' : 'td', { align: node.attrs.align }, 0],
    }
  }

  toMarkdown(state, node) {
    state.renderInline(node)
  }
}
