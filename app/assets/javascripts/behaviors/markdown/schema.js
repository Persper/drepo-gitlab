import { Schema } from 'prosemirror-model'
import editorExtensions from './editor_extensions';

const nodes = editorExtensions
  .filter(extension => extension.type === 'node')
  .reduce((nodes, { name, schema }) => ({
    ...nodes,
    [name]: schema,
  }), {})

const marks = editorExtensions
  .filter(extension => extension.type === 'mark')
  .reduce((marks, { name, schema }) => ({
    ...marks,
    [name]: schema,
  }), {});

export default new Schema({ nodes, marks });
