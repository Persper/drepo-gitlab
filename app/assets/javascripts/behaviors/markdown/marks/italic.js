import { ItalicMark as BaseItalicMark } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

export default class ItalicMark extends BaseItalicMark {
  get toMarkdown() {
    return defaultMarkdownSerializer.marks.em;
  }
}
