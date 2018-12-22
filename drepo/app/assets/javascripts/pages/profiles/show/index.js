/* eslint-disable no-new */

import '~/pages/profiles/show/index';
import UpdateProfileSettings from '../../../profile/update_profile_settings';

document.addEventListener('DOMContentLoaded', () => {
  const userDataFormWrapper = document.querySelector('.drepo-sync-container');

  if (userDataFormWrapper) {
    new UpdateProfileSettings(userDataFormWrapper);
  }
});
