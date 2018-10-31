import TableRowNode from './table_row'

const CENTER_ALIGN = 'center';

export default class TableHeaderRowNode extends TableRowNode {
  get name() {
    return 'table_header_row'
  }

  get schema() {
    return {
      content: 'table_cell+',
      parseDOM: [
        {
          tag: 'thead tr',
          priority: 51
        },
      ],
      toDOM: node => ['tr', 0],
    }
  }

  toMarkdown(state, node) {
    let cellWidths = super.toMarkdown(state, node)

    state.flushClose(1)

    state.write('|')
    node.forEach((cell, _, i) => {
      if (i) state.write('|')

      state.write(cell.attrs.align === CENTER_ALIGN ? ':' : '-')
      state.write(state.repeat('-', cellWidths[i]))
      state.write(cell.attrs.align === CENTER_ALIGN || cell.attrs.align === 'right' ? ':' : '-')
    })
    state.write('|')

    state.closeBlock(node)
  }
}
