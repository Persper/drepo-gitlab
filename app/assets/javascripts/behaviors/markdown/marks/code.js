import { CodeMark as BaseCodeMark } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class CodeMark extends BaseCodeMark {
  get toMarkdown() {
    return defaultMarkdownSerializer.marks.code;
  }
}
