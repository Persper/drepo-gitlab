import { HeadingNode as BaseHeadingNode } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class HeadingNode extends BaseHeadingNode {
  toMarkdown(state, node) {
    if (!node.childCount) return;

    defaultMarkdownSerializer.nodes.heading(state, node)
  }
}
