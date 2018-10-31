import { Node } from 'tiptap'
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

export default class ParagraphNode extends Node {
  get name() {
    return 'paragraph'
  }

  get schema() {
    return {
      content: 'inline*',
      group: 'block',
      parseDOM: [
        { tag: 'p' }
      ],
      toDOM: node => ['p', 0],
    }
  }

  toMarkdown(state, node) {
    defaultMarkdownSerializer.nodes.paragraph(state, node)
  }
}
