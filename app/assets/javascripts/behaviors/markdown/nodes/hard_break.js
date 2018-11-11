import { HardBreakNode as BaseHardBreakNode } from 'tiptap-extensions';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class HardBreakNode extends BaseHardBreakNode {
  toMarkdown(state, node) {
    if (!state.atBlank()) state.write("  \n");
  }
}
