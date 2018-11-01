import { BlockquoteNode as BaseBlockquoteNode } from 'tiptap-extensions'
import { wrappingInputRule } from 'tiptap-commands'
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

export default class BlockquoteNode extends BaseBlockquoteNode {
  toMarkdown(state, node) {
    if (!node.childCount) return;

    defaultMarkdownSerializer.nodes.blockquote(state, node)
  }

  inputRules({ type }) {
    return [
      wrappingInputRule(/^\s*>\s$/, type),
      wrappingInputRule(/^>>>$/, type),
    ]
  }
}
