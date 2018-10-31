import { ListItemNode as BaseListItemNode } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

export default class ListItemNode extends BaseListItemNode {
  toMarkdown(state, node) {
    defaultMarkdownSerializer.nodes.list_item(state, node);
  }
}
