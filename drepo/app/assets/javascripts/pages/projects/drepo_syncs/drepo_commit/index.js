/* eslint-disable no-new */

import $ from 'jquery';
import Diff from '~/diff';
import ZenMode from '~/zen_mode';
import ShortcutsNavigation from '~/behaviors/shortcuts/shortcuts_navigation';
import initChangesDropdown from '~/init_changes_dropdown';
import { fetchCommitMergeRequests } from '~/commit_merge_requests';

document.addEventListener('DOMContentLoaded', () => {
  const hasPerfBar = document.querySelector('.with-performance-bar');
  const performanceHeight = hasPerfBar ? 35 : 0;
  new Diff();
  new ZenMode();
  new ShortcutsNavigation();
  initChangesDropdown(document.querySelector('.navbar-gitlab').offsetHeight + performanceHeight);
  $('.commit-info.branches').load(document.querySelector('.js-commit-box').dataset.commitPath);
  fetchCommitMergeRequests();
});
