import dompurify from 'dompurify';
import { getFirstCharacterCapitalized } from '~/lib/utils/text_utility';

export const DEFAULT_SIZE_CLASS = 's40';
export const IDENTICON_BG_COUNT = 7;

export function getIdenticonBackgroundClass(entityId) {
  const type = (entityId % IDENTICON_BG_COUNT) + 1;
  return `bg${type}`;
}

export function getIdenticonTitle(entityName) {
  return getFirstCharacterCapitalized(entityName) || ' ';
}

export function renderIdenticon(entity, options = {}) {
  const { sizeClass = DEFAULT_SIZE_CLASS } = options;

  const bgClass = getIdenticonBackgroundClass(entity.id);
  const title = getIdenticonTitle(entity.name);

  return `<div class="avatar identicon ${dompurify.sanitize(sizeClass)} ${dompurify.sanitize(
    bgClass,
  )}">${dompurify.sanitize(title)}</div>`;
}

export function renderAvatar(entity, options = {}) {
  if (!entity.avatar_url) {
    return renderIdenticon(entity, options);
  }

  const { sizeClass = DEFAULT_SIZE_CLASS } = options;

  return `<img src="${dompurify.sanitize(entity.avatar_url)}" class="avatar ${dompurify.sanitize(
    sizeClass,
  )}" />`;
}
