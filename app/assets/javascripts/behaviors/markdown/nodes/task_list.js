import { Node } from 'tiptap'

export default class TaskListNode extends Node {
  get name() {
    return 'task_list'
  }

  get schema() {
    return {
      group: 'block',
      content: '(task_list_item|list_item)+',
      parseDOM: [
        {
          priority: 51,
          tag: 'ul.task-list',
        }
      ],
      toDOM: node => ['ul', { class: 'task-list' }, 0],
    }
  }

  toMarkdown(state, node) {
    state.renderList(node, '  ', () => "* ");
  }
}
