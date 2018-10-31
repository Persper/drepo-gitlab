import { LinkMark as BaseLinkMark } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

export default class LinkMark extends BaseLinkMark {
  get toMarkdown() {
    return {
      around(state, mark, text) {
        if (text == mark.attrs.href) return ['', ''];

        const defaultLinkMark = defaultMarkdownSerializer.marks.link;
        return [defaultLinkMark.open, defaultLinkMark.close(state, mark)];
      }
    }
  }
}
