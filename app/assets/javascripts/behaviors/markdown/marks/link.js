import { LinkMark as BaseLinkMark } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class LinkMark extends BaseLinkMark {
  get toMarkdown() {
    return {
      mixable: true,
      around(state, mark, text) {
        if (text === mark.attrs.href) return ['', ''];

        const defaultLinkMark = defaultMarkdownSerializer.marks.link;
        return [defaultLinkMark.open, defaultLinkMark.close(state, mark)];
      }
    }
  }
}
