<template>
  <div class="row">
    <div class="col-lg-3">
      <div v-if="optionAvailable('metamask')">
        <label>{{ unlockOptionsTitle }}</label>
        <br />
        <label for="metamask" class="ratio">
          <input id="metamask" v-model="unlockOption" type="radio" value="metamask" />
          <span class="label-text">MetaMask</span>
        </label>
        <br />
      </div>
      <div v-if="optionAvailable('mnemonic_phrase')">
        <label for="mnemonic-phrase" class="ratio">
          <input id="mnemonic-phrase" v-model="unlockOption" type="radio" value="mnemonic_phrase" />
          <span class="label-text">Mnemonic Phrase</span>
        </label>
        <br />
      </div>
      <div v-if="optionAvailable('private_key')">
        <label for="private-key" class="ratio">
          <input id="private-key" v-model="unlockOption" type="radio" value="private_key" />
          <span class="label-text">Private Key</span>
        </label>
      </div>
    </div>
    <div class="ether-form col-lg-5">
      <div v-if="unlockOption === 'metamask'">
        <h4 class="col-lg-12">MetaMask</h4>
        <p class="col-lg-12">
          MetaMask is a browser extension that allows you to access your wallet quickly, safely &
          easily.
        </p>
        <p v-if="isMetaMaskSupportedBrowser && !isMetaMaskTurnedOn" class="col-lg-12">
          Your brower supports MetaMask, you can install the extension or turn it on if you've
          installed.
        </p>
        <p v-if="isMetaMaskTurnedOn && !isMetaMaskLoggedIn" class="col-lg-12">
          Please login your MetaMask first.
          <a href="#" @click.stop.prevent="loginMetaMask()">login now</a>
        </p>
        <p v-if="!isMetaMaskSupportedBrowser" class="col-lg-12">
          Your brower does <b>not</b> supports MetaMask extension.
        </p>
        <input
          type="button"
          class="btn btn-success btn-ether"
          :disabled="!isConnectToMetaMaskButtonClickable"
          value="Connect to MetaMask"
          @click.stop.prevent="connectToMetaMask()"
        />
      </div>
      <div v-else-if="unlockOption === 'mnemonic_phrase'">
        <h4 class="col-lg-12">Paste Your Mnemonic Phrase</h4>
        <textarea
          :value="mnemonicPhraseInput"
          class="col-lg-12 ether-input"
          placeholder="Mnemonic Phrase"
          @input="updateMnemonicPhraseInput"
        ></textarea>
        <label class="col-lg-12"
          >Address Index(optional, the first one will be used by default) :
        </label>
        <input
          :value="addressIndexInput"
          class="col-lg-12 ether-input"
          type="text"
          placeholder="Address Index"
          @input="updateAddressIndexInput"
        />
        <input
          type="button"
          class="btn btn-success btn-ether col-lg-4"
          :disabled="!isUnlockByMnemonicPhraseButtonClickable"
          value="Unlock"
          @click.stop.prevent="unlockByMnemonicPhrase()"
        />
      </div>
      <div v-else-if="unlockOption === 'private_key'">
        <h4 class="col-lg-12">Paste Your Private Key</h4>
        <textarea
          :value="privateKeyInput"
          class="col-lg-12 ether-input"
          placeholder="Private Key"
          @input="updatePrivateKeyInput"
        ></textarea>
        <input
          type="button"
          class="btn btn-success btn-ether col-lg-4"
          :disabled="!isUnlockByPrivateKeyButtonClickable"
          value="Unlock"
          @click.stop.prevent="unlockByPrivateKey()"
        />
      </div>
    </div>
    <div class="col-lg-4 account-info">
      <div id="account-info">
        <AccountInfo
          v-if="isUnlocked"
          :account-balance="accountBalance"
          :account-address="accountAddress"
        />
      </div>
    </div>
  </div>
</template>

<script>
import { detect } from 'detect-browser';
import { mapActions, mapGetters, mapState } from 'vuex';
import AccountInfo from './account_info.vue';

export default {
  name: 'EtherWallet',

  components: {
    AccountInfo,
  },

  props: {
    unlockOptionsTitle: {
      type: String,
      required: false,
      default: 'Select a way to access your wallet:',
    },
    defaultUnlockOption: {
      type: String,
      required: false,
      default: 'metamask',
    },
    /* eslint-disable */
    availableUnlockOptions: {
      type: [String, Array],
      required: false,
      default: function() {
        return ['metamask', 'mnemonic_phrase', 'private_key'];
      },
    },
    /* eslint-enable */
  },

  computed: {
    ...mapState([
      'web3Client',
      'accountAddress',
      'unlockOptionState',
      'isMetaMaskSupportedBrowser',
      'isMetaMaskTurnedOn',
      'isMetaMaskLoggedIn',
      'accountBalance',
      'isConnectToMetaMaskButtonClicked',
      'isUnlockByPrivateKeyButtonClicked',
      'isUnlockByMnemonicPhraseButtonClicked',
      'mnemonicPhraseInput',
      'addressIndexInput',
      'privateKeyInput',
      'gasLimit',
    ]),

    ...mapGetters([
      'isUnlocked',
      'isConnectToMetaMaskButtonClickable',
      'isUnlockByPrivateKeyButtonClickable',
      'isUnlockByMnemonicPhraseButtonClickable',
    ]),

    unlockOption: {
      get() {
        return this.unlockOptionState;
      },
      set(value) {
        this.updateUnlockOption(value);
      },
    },
  },

  mounted() {
    if (this.availableUnlockOptions.includes(this.defaultUnlockOption)) {
      this.updateUnlockOption(this.defaultUnlockOption);
    }

    if (!this.availableUnlockOptions.includes('metamask')) return;

    const browser = detect();
    if (!browser) return;

    const isMetaMaskSupported = this.isBrowserSupportMetaMask(browser);
    if (!isMetaMaskSupported && this.defaultUnlockOption === 'metamask') {
      if (this.availableUnlockOptions.length > 1) {
        this.updateUnlockOption(this.defaultUnlockOption.filter(opt => opt !== 'metamask')[0]);
      }
      return;
    }
    this.initialDetectBrowser(true);
  },

  methods: {
    ...mapActions([
      'initialDetectBrowser',
      'loginMetaMask',
      'connectToMetaMask',
      'unlockByPrivateKey',
      'unlockByMnemonicPhrase',
      'updateAccountInfo',
      'updateUnlockOption',
      'updateMnemonicPhraseInput',
      'updateAddressIndexInput',
      'updatePrivateKeyInput',
    ]),

    isBrowserSupportMetaMask(browser) {
      switch (browser && browser.name) {
        case 'chrome':
        case 'firefox':
        case 'opera':
          return true;
        default:
          return false;
      }
    },

    optionAvailable(option) {
      return this.availableUnlockOptions.includes(option);
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.ether-form {
  height: 200px;
}

.label-text {
  padding-left: 5px;
}

.btn-ether {
  text-align: center;
  margin-top: 20px;
  margin-left: 15px;
}

.ether-input {
  margin-left: 15px;
}

.ratio {
  position: relative;
  margin: 15px 0;
  font-weight: 500;
  padding: 0 1.5rem;
  margin: 0.5rem 0;
}

.account-info {
  padding: 1.5rem 2rem;
  margin-right: 0;
}
</style>
