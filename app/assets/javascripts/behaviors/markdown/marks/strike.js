import { StrikeMark as BaseStrikeMark } from 'tiptap-extensions';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class StrikeMark extends BaseStrikeMark {
  get toMarkdown() {
    return {
      open: "~~",
      close: "~~",
      mixable: true,
      expelEnclosingWhitespace: true
    }
  }
}
