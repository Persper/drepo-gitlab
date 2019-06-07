import * as Web3One from 'web3';
import HDWalletProvider from 'truffle-hdwallet-provider';
import * as types from './mutation_types';

export default {
  [types.INITIAL_DETECT_BROWSER](state, isMetaMaskSupported) {
    Object.assign(state, {
      isMetaMaskSupportedBrowser: isMetaMaskSupported,
    });

    if (typeof window !== 'undefined' && typeof window.web3 !== 'undefined') {
      Object.assign(state, {
        isMetaMaskTurnedOn: true,
      });
      // if the user login the MetaMask account
      window.web3.eth.getAccounts((err, accounts) => {
        if (err != null) {
          Object.assign(state, {
            isMetaMaskLoggedIn: false,
          });
        } else if (accounts.length > 0) {
          Object.assign(state, {
            isMetaMaskLoggedIn: true,
          });
        } else {
          Object.assign(state, {
            isMetaMaskLoggedIn: false,
          });
        }
      });

      window.ethereum.on('accountsChanged', accounts => {
        if (accounts[0] && state.web3Client && state.unlockOptionState === 'metamask') {
          this.commit(types.UPDATE_ACCOUNT_INFO, accounts[0]);
        }
      });
    }
  },

  [types.UPDATE_ACCOUNT_INFO](state, account) {
    if (account && state.web3Client) {
      Object.assign(state, {
        accountAddress: account,
      });
      this.commit(types.UPDATE_BALANCE);
    } else {
      state.web3Client.eth.getAccounts((err, accounts) => {
        if (err || accounts.length < 1) return;
        const [firstAccount] = accounts;
        Object.assign(state, {
          accountAddress: firstAccount,
        });
        // Object.assign(state.web3Client.eth.defaultAccount, firstAccount);
        this.commit(types.UPDATE_BALANCE);
      });
    }
  },

  [types.UPDATE_BALANCE](state) {
    state.web3Client.eth.getBalance(state.accountAddress, (err, balance) => {
      if (err) return;

      if (!balance) {
        Object.assign(state, {
          accountBalance: 'Query balance failed',
        });
      } else if (state.unlockOptionState === 'metamask') {
        Object.assign(state, {
          accountBalance: state.web3Client.fromWei(balance, 'ether').toString(),
        });
      } else {
        Object.assign(state, {
          accountBalance: state.web3Client.utils.fromWei(balance, 'ether').toString(),
        });
      }
    });
  },

  [types.UPDATE_UNLOCK_BUTTON_CLICKED](state, button, value) {
    if (button === 'metamask') {
      Object.assign(state, {
        isConnectToMetaMaskButtonClicked: value,
      });
    } else if (button === 'private_key') {
      Object.assign(state, {
        isUnlockByPrivateKeyButtonClicked: value,
      });
    } else if (button === 'mnemonic_phrase') {
      Object.assign(state, {
        isUnlockByMnemonicPhraseButtonClicked: value,
      });
    }
  },

  [types.CONNECT_TO_METAMASK](state) {
    Object.assign(state, {
      isConnectToMetaMaskButtonClicked: true,
    });

    Object.assign(state, {
      web3Client: new window.Web3(window.web3.currentProvider),
    });
  },

  [types.UNLOCK_BY_PRIVATE_KEY](state) {
    Object.assign(state, {
      isUnlockByPrivateKeyButtonClicked: true,
    });
    if (!state.privateKeyInput.match(/^(?:0x)?\w{64}$/)) return;
    if (state.privateKeyInput.length === 64 && !state.privateKeyInput.match(/^0x/)) {
      const privateKey = `0x${state.privateKeyInput}`;
      Object.assign(state, {
        privateKeyInput: privateKey,
      });
    }
    const provider = new HDWalletProvider(
      state.privateKeyInput,
      'https://rinkeby.infura.io/v3/8d1ba1e9ef484906ba94d560cc1d3a87',
    );
    Object.assign(state, {
      web3Client: new Web3One(provider),
    });
  },

  [types.UNLOCK_BY_MNEMONIC_PHRASE](state) {
    Object.assign(state, {
      isUnlockByMnemonicPhraseButtonClicked: true,
    });
    if (state.addressIndexInput < 1) return;
    const provider = new HDWalletProvider(
      state.mnemonicPhraseInput,
      'https://rinkeby.infura.io/v3/8d1ba1e9ef484906ba94d560cc1d3a87',
      state.addressIndexInput - 1,
    );
    Object.assign(state, {
      web3Client: new Web3One(provider),
    });
  },

  [types.UPDATE_UNLOCK_OPTION](state, option) {
    Object.assign(state, {
      unlockOptionState: option,
    });
  },

  [types.UPDATE_MNEMONIC_PHRASE_INPUT](state, input) {
    Object.assign(state, {
      mnemonicPhraseInput: input,
    });
  },

  [types.UPDATE_ADDRESS_INDEX_INPUT](state, input) {
    Object.assign(state, {
      addressIndexInput: input,
    });
  },

  [types.UPDATE_PRIVATE_KEY_INPUT](state, input) {
    Object.assign(state, {
      privateKeyInput: input,
    });
  },
};
