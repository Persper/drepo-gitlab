import initMrNotes from '../../../../drepo_mr_notes';
import initShow from './init_merge_request_show';

document.addEventListener('DOMContentLoaded', () => {
  initShow();
  initMrNotes();
});
