import DropLab from '~/droplab/drop_lab';
import ISetter from '~/droplab/plugins/input_setter';

const InputSetter = Object.assign({}, ISetter);

const UPDATE_PROFILE_SETTINGS = 'update-profile-settings';
const UPDATE_AND_SYNC_DREPO = 'update-and-sync-drepo';

export default class UpdateProfileSettings {
  constructor(buttonWrapper) {
    this.buttonWrapper = buttonWrapper;
    this.updateProfileSettingsButton = this.buttonWrapper.querySelector(
      '.js-update-profile-settings',
    );
    this.dropdownToggle = this.buttonWrapper.querySelector('.js-dropdown-toggle');
    this.dropdownList = this.buttonWrapper.querySelector('.dropdown-menu');

    this.init();
  }

  init() {
    this.initDroplab();
    this.bindEvents();
  }

  initDroplab() {
    this.droplab = new DropLab();
    this.droplab.init(
      this.dropdownToggle,
      this.dropdownList,
      [InputSetter],
      this.getDroplabConfig(),
    );
  }

  getDroplabConfig() {
    return {
      InputSetter: [
        {
          input: this.updateProfileSettingsButton,
          valueAttribute: 'data-value',
          inputAttribute: 'data-action',
        },
        {
          input: this.updateProfileSettingsButton,
          valueAttribute: 'data-text',
        },
      ],
    };
  }

  bindEvents() {
    this.updateProfileSettingsButton.addEventListener(
      'click',
      this.onClickUpdateSyncProfile.bind(this),
    );
  }

  onClickUpdateSyncProfile(e) {
    if (e.target.dataset.action === UPDATE_AND_SYNC_DREPO) {
      console.log("do updating and sync drepo")
    }
  }
}
