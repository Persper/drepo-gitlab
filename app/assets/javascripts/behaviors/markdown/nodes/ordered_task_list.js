import { Node } from 'tiptap'

export default class OrderedTaskListNode extends Node {
  get name() {
    return 'ordered_task_list'
  }

  get schema() {
    return {
      group: 'block',
      content: '(task_list_item|list_item)+',
      parseDOM: [
        {
          priority: 51,
          tag: 'ol.task-list',
        }
      ],
      toDOM: node => ['ol', { class: 'task-list' }, 0],
    }
  }

  toMarkdown(state, node) {
    state.renderList(node, '   ', () => '1. ')
  }
}
