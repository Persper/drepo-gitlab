import updateProfileSettings from '../../../profile/update_profile_settings';

document.addEventListener('DOMContentLoaded', () => {
    const userDataFormWrapper = document.querySelector('.edit-user');

    if (userDataFormWrapper) {
        new updateProfileSettings(userDataFormWrapper);
    }
});
