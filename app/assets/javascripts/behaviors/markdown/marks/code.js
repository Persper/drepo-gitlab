import { CodeMark as BaseCodeMark } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

export default class CodeMark extends BaseCodeMark {
  get toMarkdown() {
    return defaultMarkdownSerializer.marks.code;
  }
}
