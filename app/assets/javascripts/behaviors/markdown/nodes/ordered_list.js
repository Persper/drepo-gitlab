import { OrderedListNode as BaseOrderedListNode } from 'tiptap-extensions';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class OrderedListNode extends BaseOrderedListNode {
  toMarkdown(state, node) {
    state.renderList(node, '   ', () => '1. ')
  }
}
