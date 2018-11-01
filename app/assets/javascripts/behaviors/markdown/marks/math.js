import { Mark } from 'tiptap'
import { toggleMark, markInputRule } from 'tiptap-commands'
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

export default class MathMark extends Mark {
  get name() {
    return 'math'
  }

  get schema() {
    return {
      parseDOM: [
        {
          tag: 'code.code.math[data-math-style=inline]',
          priority: 51
        },
        { tag: 'span.katex', contentElement: 'annotation[encoding="application/x-tex"]' }
      ],
      toDOM: node => ['code', { class: 'code math', 'data-math-style': 'inline' }, 0],
    }
  }

  get toMarkdown() {
    return {
      escape: false,
      around(state, mark, text) {
        [open, close] = defaultMarkdownSerializer.marks.code.around(state, mark, text)
        return ['$' + open, close + '$']
      }
    }
  }

  command({ type }) {
    return toggleMark(type)
  }

  inputRules({ type }) {
    return [
      markInputRule(/(?:\$`)([^`]+)(?:`)$/, type),
    ]
  }
}
