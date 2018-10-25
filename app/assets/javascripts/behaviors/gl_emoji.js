import '@webcomponents/webcomponentsjs/webcomponents-loader';
import isEmojiUnicodeSupported from '../emoji/support';

export default function installGlEmojiElement() {
  class GlEmojiElement extends HTMLElement {
    constructor() {
      super();
      const emojiUnicode = this.textContent.trim();
      const { name, unicodeVersion, fallbackSrc, fallbackSpriteClass } = this.dataset;

      const isEmojiUnicode =
        this.childNodes &&
        Array.prototype.every.call(this.childNodes, childNode => childNode.nodeType === 3);

      if (
        emojiUnicode &&
        isEmojiUnicode &&
        !isEmojiUnicodeSupported(emojiUnicode, unicodeVersion)
      ) {
        const hasCssSpriteFalback = fallbackSpriteClass && fallbackSpriteClass.length > 0;

        // CSS sprite fallback takes precedence over image fallback
        if (hasCssSpriteFalback) {
          if (!gon.emoji_sprites_css_added && gon.emoji_sprites_css_path) {
            const emojiSpriteLinkTag = document.createElement('link');
            emojiSpriteLinkTag.setAttribute('rel', 'stylesheet');
            emojiSpriteLinkTag.setAttribute('href', gon.emoji_sprites_css_path);
            document.head.appendChild(emojiSpriteLinkTag);
            gon.emoji_sprites_css_added = true;
          }
          // IE 11 doesn't like adding multiple at once :(
          this.classList.add('emoji-icon');
          this.classList.add(fallbackSpriteClass);
        } else {
          const hasImageFallback = fallbackSrc && fallbackSrc.length > 0;

          import(/* webpackChunkName: 'emoji' */ '../emoji')
            .then(({ emojiImageTag, emojiFallbackImageSrc }) => {
              if (hasImageFallback) {
                this.innerHTML = emojiImageTag(name, fallbackSrc);
              } else {
                const src = emojiFallbackImageSrc(name);
                this.innerHTML = emojiImageTag(name, src);
              }
            })
            .catch(() => {
              // do nothing
            });
        }
      }
    }
  }

  window.WebComponents.waitFor(() => {
    window.customElements.define('gl-emoji', GlEmojiElement);
  });
}
