import { OrderedListNode as BaseOrderedListNode } from 'tiptap-extensions';

export default class OrderedListNode extends BaseOrderedListNode {
  toMarkdown(state, node) {
    state.renderList(node, '   ', () => '1. ')
  }
}
