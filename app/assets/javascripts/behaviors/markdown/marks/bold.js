import { BoldMark as BaseBoldMark } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class BoldMark extends BaseBoldMark {
  get toMarkdown() {
    return defaultMarkdownSerializer.marks.strong;
  }
}
