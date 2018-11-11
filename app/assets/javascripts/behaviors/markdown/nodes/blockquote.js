import { BlockquoteNode as BaseBlockquoteNode } from 'tiptap-extensions'
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class BlockquoteNode extends BaseBlockquoteNode {
  toMarkdown(state, node) {
    if (!node.childCount) return;

    defaultMarkdownSerializer.nodes.blockquote(state, node)
  }
}
