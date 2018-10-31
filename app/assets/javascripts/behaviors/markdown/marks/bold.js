import { BoldMark as BaseBoldMark } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

export default class BoldMark extends BaseBoldMark {
  get toMarkdown() {
    return defaultMarkdownSerializer.marks.strong;
  }
}
