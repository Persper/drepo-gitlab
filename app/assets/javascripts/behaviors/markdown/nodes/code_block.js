import { CodeBlockNode as BaseCodeBlockNode } from 'tiptap-extensions'

export default class CodeBlockNode extends BaseCodeBlockNode {
  get schema() {
    return {
      content: 'text*',
      marks: '',
      group: 'block',
      code: true,
      defining: true,
      attrs: {
        lang: { default: '' }
      },
      parseDOM: [
        {
          tag: 'pre.code.highlight',
          preserveWhitespace: 'full',
          getAttrs: (el) => {
            let lang = el.getAttribute('lang');
            if (!lang || lang == 'plaintext') lang = '';

            return { lang };
          }
        },
        {
          tag: 'span.katex-display',
          preserveWhitespace: 'full',
          contentElement: 'annotation[encoding="application/x-tex"]',
          attrs: { lang: 'math' }
        },
        {
          tag: 'svg.mermaid',
          preserveWhitespace: 'full',
          contentElement: 'text.source',
          attrs: { lang: 'mermaid' }
        }
      ],
      toDOM: node => ['pre', { class: 'code highlight', lang: node.attrs.lang || 'plaintext' }, ['code', 0]],
    }
  }

  toMarkdown(state, node) {
    if (!node.childCount) return;

    const text = node.textContent;
    const lang = node.attrs.lang;
    // Prefixes lines with 4 spaces if the code contains a line that starts with triple backticks
    if (lang == '' && text.match(/^```/gm)) {
      state.wrapBlock("    ", null, node, () => state.text(text, false));
    } else {
      state.write("```" + lang + "\n");
      state.text(text, false);
      state.ensureNewLine();
      state.write("```");
      state.closeBlock(node);
    }
  }
}
