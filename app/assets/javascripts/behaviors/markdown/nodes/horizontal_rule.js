import { Node } from 'tiptap'
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class HorizontalRuleNode extends Node {
  get name() {
    return 'horizontal_rule'
  }

  get schema() {
    return {
      group: 'block',
      parseDOM: [
        { tag: 'hr' },
      ],
      toDOM: node => ['hr'],
    }
  }

  toMarkdown(state, node) {
    defaultMarkdownSerializer.nodes.horizontal_rule(state, node);
  }
}
