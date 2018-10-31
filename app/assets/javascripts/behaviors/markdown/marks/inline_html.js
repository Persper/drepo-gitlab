import { Mark } from 'tiptap'

const tags = 'sup sub kbd q samp var'.split(' ');

export default class InlineHTMLMark extends Mark {
  get name() {
    return 'inline_html'
  }

  get schema() {
    return {
      excludes: '',
      attrs: {
        tag: {},
        title: { default: null }
      },
      parseDOM: [
        {
          tag: tags.join(', '),
          getAttrs: (el) => ({ tag: el.nodeName.toLowerCase() })
        },
        {
          tag: 'abbr',
          getAttrs: (el) => ({ tag: 'abbr', title: el.getAttribute('title') })
        },
      ],
      toDOM: node => [node.attrs.tag, { title: node.attrs.title }, 0],
    }
  }

  get toMarkdown() {
    return {
      mixable: true,
      open(state, mark) {
        return `<${mark.attrs.tag}${mark.attrs.title ? ` title="${state.esc(mark.attrs.title)}"` : ''}>`;
      },
      close(state, mark) {
        return `</${mark.attrs.tag}>`;
      }
    }
  }
}
