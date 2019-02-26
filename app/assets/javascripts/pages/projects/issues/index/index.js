/* eslint-disable no-new */

import IssuableIndex from '~/issuable_index';
import ShortcutsNavigation from '~/behaviors/shortcuts/shortcuts_navigation';
import UsersSelect from '~/users_select';
import initFilteredSearch from '~/pages/search/init_filtered_search';
import IssuableFilteredSearchTokenKeys from '~/filtered_search/issuable_filtered_search_token_keys';
import { FILTERED_SEARCH } from '~/pages/constants';
import { ISSUABLE_INDEX } from '~/pages/projects/constants';

document.addEventListener('DOMContentLoaded', () => {
  initFilteredSearch({
    page: FILTERED_SEARCH.ISSUES,
    filteredSearchTokenKeys: IssuableFilteredSearchTokenKeys,
  });
  new IssuableIndex(ISSUABLE_INDEX.ISSUE);

  new ShortcutsNavigation();
  new UsersSelect();
});
