import { BulletListNode as BaseBulletListNode } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class BulletListNode extends BaseBulletListNode {
  toMarkdown(state, node) {
    defaultMarkdownSerializer.nodes.bullet_list(state, node)
  }
}
