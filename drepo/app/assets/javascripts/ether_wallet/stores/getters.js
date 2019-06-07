export const isUnlocked = state => state.accountAddress !== '' && state.accountBalance !== '';

export const isConnectToMetaMaskButtonClickable = state =>
  !state.isConnectToMetaMaskButtonClicked && state.isMetaMaskLoggedIn;

export const isUnlockByPrivateKeyButtonClickable = state =>
  !state.isUnlockByPrivateKeyButtonClicked && state.privateKeyInput.trim().match(/^(?:0x)?\w{64}$/);

export const isUnlockByMnemonicPhraseButtonClickable = state =>
  !state.isUnlockByMnemonicPhraseButtonClicked && state.mnemonicPhraseInput.trim().length > 11;

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
