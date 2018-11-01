import { Node } from 'tiptap'
import { splitListItem, liftListItem, sinkListItem } from 'tiptap-commands'

export default class TaskListItemNode extends Node {
  get name() {
    return 'task_list_item'
  }

  get schema() {
    return {
      attrs: {
        done: {
          default: false,
        },
      },
      defining: true,
      draggable: false,
      content: 'paragraph block*',
      parseDOM: [
        {
          priority: 51,
          tag: 'li.task-list-item',
          getAttrs: el => {
            const checkbox = el.querySelector('input[type=checkbox].task-list-item-checkbox');
            return { done: checkbox && checkbox.checked };
          },
        }
      ],
      toDOM(node) {
        return ['li', { class: 'task-list-item' },
          ['input', { type: 'checkbox', class: 'task-list-item-checkbox', checked: node.attrs.done }],
          ['div', { class: 'todo-content' }, 0],
        ]
      },
    }
  }

  toMarkdown(state, node) {
    state.write(`[${node.attrs.done ? 'x' : ' '}] `);
    state.renderContent(node);
  }

  get view() {
    return {
      props: ['node', 'updateAttrs', 'editable'],
      methods: {
        onChange() {
          this.updateAttrs({
            done: !this.node.attrs.done,
          })
        },
      },
      template: `
        <li class="task-list-item">
          <input type="checkbox" class="task-list-item-checkbox" :checked="node.attrs.done" @click="onChange"><div class="todo-content" ref="content" :contenteditable="editable"></div>
        </li>
      `,
    }
  }

  keys({ type }) {
    return {
      Enter: splitListItem(type),
      Tab: sinkListItem(type),
      'Shift-Tab': liftListItem(type),
    }
  }
}
