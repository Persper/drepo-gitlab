import { Mark } from 'tiptap'
import { toggleMark, markInputRule } from 'tiptap-commands'

export default class InlineDiffMark extends Mark {
  get name() {
    return 'inline_diff'
  }

  get schema() {
    return {
      attrs: {
        addition: {
          default: true
        }
      },
      parseDOM: [
        { tag: 'span.idiff.addition', attrs: { addition: true } },
        { tag: 'span.idiff.deletion', attrs: { addition: false } },
      ],
      toDOM: node => ['span', { class: `idiff left right ${node.attrs.addition ? 'addition' : 'deletion'}` }, 0],
    }
  }

  get toMarkdown() {
    return {
      mixable: true,
      around(state, mark, text) {
        return mark.attrs.addition ? ['{+', '+}'] : ['{-', '-}'];
      },
    }
  }

  command({ type }) {
    return toggleMark(type)
  }

  inputRules({ type }) {
    return [
      markInputRule(/(?:\[\+|\{\+)([^\+]+)(?:\+\]|\+\})$/, type, { addition: true }),
      markInputRule(/(?:\[-|\{-)([^-]+)(?:-\]|-\})$/, type, { addition: false }),
    ]
  }
}
