import { StrikeMark as BaseStrikeMark } from 'tiptap-extensions';

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
