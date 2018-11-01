import { StrikeMark as BaseStrikeMark } from 'tiptap-extensions';
import { markInputRule } from 'tiptap-commands'

export default class StrikeMark extends BaseStrikeMark {
  get toMarkdown() {
    return {
      open: "~~",
      close: "~~",
      mixable: true,
      expelEnclosingWhitespace: true
    }
  }

  inputRules({ type }) {
    return [
      markInputRule(/~~([^~]+)~~$/, type),
    ]
  }
}
