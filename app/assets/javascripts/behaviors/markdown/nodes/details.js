import { Node } from 'tiptap'

export default class DetailsNode extends Node {
  get name() {
    return 'details'
  }

  get schema() {
    return {
      content: 'summary block*',
      group: 'block',
      parseDOM: [
        { tag: 'details' },
      ],
      toDOM: node => ['details', { open: true, onclick: 'return false', tabindex: '-1' }, 0],
    }
  }

  toMarkdown(state, node) {
    state.write("<details>\n");
    state.renderContent(node);
    state.flushClose(1);
    state.ensureNewLine();
    state.write('</details>');
    state.closeBlock(node);
  }
}
