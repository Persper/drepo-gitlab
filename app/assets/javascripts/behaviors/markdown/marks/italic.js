import { ItalicMark as BaseItalicMark } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class ItalicMark extends BaseItalicMark {
  get toMarkdown() {
    return defaultMarkdownSerializer.marks.em;
  }
}
