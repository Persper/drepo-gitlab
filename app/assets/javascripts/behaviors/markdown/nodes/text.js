import { Node } from 'tiptap'
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

export default class TextNode extends Node {
  get name() {
    return 'text'
  }

  get schema() {
    return {
      group: 'inline',
    }
  }

  toMarkdown(state, node) {
    defaultMarkdownSerializer.nodes.text(state, node)
  }
}
