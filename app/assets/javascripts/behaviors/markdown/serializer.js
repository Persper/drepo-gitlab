import { MarkdownSerializer } from 'prosemirror-markdown';
import editorExtensions from './editor_extensions';

const nodes = editorExtensions
  .filter(extension => extension.type === 'node')
  .reduce((nodes, { name, toMarkdown }) => ({
    ...nodes,
    [name]: toMarkdown,
  }), {})

const marks = editorExtensions
  .filter(extension => extension.type === 'mark')
  .reduce((marks, { name, toMarkdown }) => ({
    ...marks,
    [name]: toMarkdown,
  }), {})

export default new MarkdownSerializer(nodes, marks);
