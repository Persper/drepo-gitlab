import { Node } from 'tiptap'

export default class DescriptionTermNode extends Node {
  get name() {
    return 'description_term'
  }

  get schema() {
    return {
      content: 'text*',
      marks: '',
      defining: true,
      parseDOM: [
        { tag: 'dt' },
      ],
      toDOM: node => ['dt', 0],
    }
  }

  toMarkdown(state, node) {
    state.flushClose(state.closed && state.closed.type === node.type ? 1 : 2);
    state.write('<dt>');
    state.text(node.textContent, false);
    state.write('</dt>');
    state.closeBlock(node);
  }
}
