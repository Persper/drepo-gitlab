import { Node } from 'tiptap'
import { InputRule } from 'prosemirror-inputrules'
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

export default class HorizontalRuleNode extends Node {
  get name() {
    return 'horizontal_rule'
  }

  get schema() {
    return {
      group: 'block',
      parseDOM: [
        { tag: 'hr' },
      ],
      toDOM: node => ['hr'],
    }
  }

  toMarkdown(state, node) {
    defaultMarkdownSerializer.nodes.horizontal_rule(state, node);
  }

  command({ type, attrs }) {
    return (state, dispatch) => {
      const { selection } = state
      const position = selection.$cursor ? selection.$cursor.pos : selection.$to.pos
      const node = type.create(attrs)
      const transaction = state.tr.insert(position, node)
      dispatch(transaction)
    }
  }

  inputRules({ type }) {
    return [
      new InputRule(/^---$/, (state, match, start, end) => {
        const node = type.create()
        return state.tr.replaceWith(start, end, node);
      })
    ]
  }
}
