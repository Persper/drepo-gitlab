import { Node } from 'tiptap'

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class SummaryNode extends Node {
  get name() {
    return 'summary'
  }

  get schema() {
    return {
      content: 'text*',
      marks: '',
      defining: true,
      parseDOM: [
        { tag: 'summary' },
      ],
      toDOM: node => ['summary', 0],
    }
  }

  toMarkdown(state, node) {
    state.write('<summary>');
    state.text(node.textContent, false);
    state.write('</summary>');
    state.closeBlock(node);
  }
}
