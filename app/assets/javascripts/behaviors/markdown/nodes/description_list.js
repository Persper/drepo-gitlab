import { Node } from 'tiptap'

export default class DescriptionListNode extends Node {
  get name() {
    return 'description_list'
  }

  get schema() {
    return {
      content: '(description_term+ description_details+)+',
      group: 'block',
      parseDOM: [
        { tag: 'dl' },
      ],
      toDOM: node => ['dl', 0],
    }
  }

  toMarkdown(state, node) {
    state.write("<dl>\n");
    state.wrapBlock("  ", null, node, () => state.renderContent(node))
    state.flushClose(1);
    state.ensureNewLine();
    state.write('</dl>');
    state.closeBlock(node);
  }
}
