import { ListItemNode as BaseListItemNode } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class ListItemNode extends BaseListItemNode {
  toMarkdown(state, node) {
    defaultMarkdownSerializer.nodes.list_item(state, node);
  }
}
