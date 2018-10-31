import { HardBreakNode as BaseHardBreakNode } from 'tiptap-extensions';

export default class HardBreakNode extends BaseHardBreakNode {
  toMarkdown(state, node) {
    if (!state.atBlank()) state.write("  \n");
  }
}
