/* eslint-disable no-new */

import UpdateProfileSettings from '../../../profile/update_profile_settings';

document.addEventListener('DOMContentLoaded', () => {
  const userDataFormWrapper = document.querySelector('.drepo-sync-container');

  if (userDataFormWrapper) {
    new UpdateProfileSettings(userDataFormWrapper);
  }
});
