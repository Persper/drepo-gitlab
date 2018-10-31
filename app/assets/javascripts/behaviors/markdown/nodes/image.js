import { ImageNode as BaseImageNode } from 'tiptap-extensions'
import { placeholderImage } from '~/lazy_loader';
import { defaultMarkdownSerializer } from 'prosemirror-markdown';

export default class ImageNode extends BaseImageNode {
  get schema() {
    return {
      attrs: {
        src: {},
        alt: {
          default: null,
        },
        title: {
          default: null,
        },
      },
      group: 'inline',
      inline: true,
      draggable: true,
      parseDOM: [
        {
          tag: 'a.no-attachment-icon',
          priority: 51,
          skip: true
        },
        {
          tag: 'img[src]',
          getAttrs: el => {
            const imageSrc = el.src;
            const imageUrl = imageSrc && imageSrc !== placeholderImage ? imageSrc : (el.dataset.src || '');

            return {
              src: imageUrl,
              title: el.getAttribute('title'),
              alt: el.getAttribute('alt'),
            };
          },
        },
      ],
      toDOM: node => ['img', node.attrs],
    }
  }

  toMarkdown(state, node) {
    defaultMarkdownSerializer.nodes.image(state, node);
  }
}
