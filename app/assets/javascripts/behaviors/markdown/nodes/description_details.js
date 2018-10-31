import { Node } from 'tiptap'

export default class DescriptionDetailsNode extends Node {
  get name() {
    return 'description_details'
  }

  get schema() {
    return {
      content: 'text*',
      marks: '',
      defining: true,
      parseDOM: [
        { tag: 'dd' },
      ],
      toDOM: node => ['dd', 0],
    }
  }

  toMarkdown(state, node) {
    state.flushClose(1);
    state.write('<dd>');
    state.text(node.textContent, false);
    state.write('</dd>');
    state.closeBlock(node);
  }
}
