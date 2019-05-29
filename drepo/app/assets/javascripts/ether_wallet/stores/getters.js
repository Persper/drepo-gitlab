export const isUnlocked = state => state.accountAddress !== '' && state.accountBalance !== '';

export const isConnectToMetaMaskButtonClickable = state =>
  !state.isConnectToMetaMaskButtonClicked && state.isMetaMaskLoggedIn;

export const isUnlockByPrivateKeyButtonClickable = state =>
  !state.isUnlockByPrivateKeyButtonClicked && state.privateKeyInput.trim().match(/^\w{64}$/);

export const isUnlockByMnemonicPhraseButtonClickable = state =>
  !state.isUnlockByMnemonicPhraseButtonClicked && state.mnemonicPhraseInput.trim().length > 11;

// export const isStartDrepoSyncButtonClickable = state => !state.isStartDrepoSyncButtonClicked && state.isUnlocked;

// prevent babel-plugin-rewire from generating an invalid default during karma tests
//export default () => {};
