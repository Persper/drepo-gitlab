<template>
  <div id="js-ether-wallet-access" class="merge-request-form common-note-form">
    <div class="row">
      <div class="col-lg-3">
        <label>Select a way to access your wallet:</label>
        <br />
        <label for="metamask" class="ratio">
          <input id="metamask" v-model="unlockOption" type="radio" value="metamask" />
          <span class="label-text">MetaMask</span>
        </label>
        <br />
        <label for="mnemonic-phrase" class="ratio">
          <input id="mnemonic-phrase" v-model="unlockOption" type="radio" value="mnemonic_phrase" />
          <span class="label-text">Mnemonic Phrase</span>
        </label>
        <br />
        <label for="private-key" class="ratio">
          <input id="private-key" v-model="unlockOption" type="radio" value="private_key" />
          <span class="label-text">Private Key</span>
        </label>
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
            Your brower not supports MetaMask extension.
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
            @input="updateMnemonicPhraseInput"
            class="col-lg-12 ether-input"
            placeholder="Mnemonic Phrase"
          ></textarea>
          <label class="col-lg-12"
            >Address Index(optional, the first one will be used by default) :
          </label>
          <input
            :value="addressIndexInput"
            @input="updateAddressIndexInput"
            class="col-lg-12 ether-input"
            type="text"
            placeholder="Address Index"
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
            @input="updatePrivateKeyInput"
            class="col-lg-12 ether-input"
            placeholder="Private Key"
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
    <div class="middle-block row-content-block">
      <div class="float-right">
        <input
          type="button"
          class="btn btn-cancel"
          value="Cancel"
          @click.stop.prevent="cancelDrepoSync()"
        />
      </div>
      <span class="append-right-10">
        <input
          type="submit"
          class="btn btn-success col-lg-2"
          :disabled="!isStartDrepoSyncButtonClickable"
          value="Start Drepo!"
          @click.stop.prevent="startDrepoSync()"
        />
      </span>
      <div class="inline prepend-top-10">
        Please review the commits and changes below before starting Drepo!
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters, mapState } from 'vuex';
import AccountInfo from './account_info.vue';

export default {
  name: 'EtherWallet',

  components: {
    AccountInfo,
  },

  props: {
    projectPath: {
      type: String,
      required: true,
    },
    contractInfo: {
      type: Object,
      required: true,
    },
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
      'isStartDrepoSyncButtonClicked',
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

    isStartDrepoSyncButtonClickable() {
      return !this.isStartDrepoSyncButtonClicked && this.isUnlocked;
    },
  },

  mounted() {
    this.initialDetectBrowser();
  },

  methods: {
    ...mapActions([
      'isBrowserSupportMetaMask',
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

    web3Contract() {
      const contractData = JSON.parse(this.contractInfo.interface);
      if (this.unlockOption === 'metamask') {
        const myContract = this.web3Client.eth.contract(contractData);
        const myContractInstance = myContract.at(this.contractInfo.address);
        myContractInstance.setMessage('message from web3 metamask', (err, result) => {
          // eslint-disable-next-line no-console
          if (!err) console.log(result);
        });
      } else {
        const myContract = new this.web3Client.eth.Contract(
          contractData,
          this.contractInfo.address,
          {
            from: this.accountAddress,
            gas: this.gasLimit,
          },
        );
        myContract.methods
          .setMessage('hello world! mmmmm')
          .send({ from: this.accountAddress })
          .on('confirmation', (confirmationNumber, receipt) => {
            // eslint-disable-next-line no-console
            console.log(`Confirmed: ${confirmationNumber} ${receipt}`);
          });
      }
    },

    startDrepoSync() {
      if (this.isStartDrepoSyncButtonClicked) return;
      this.isStartDrepoSyncButtonClicked = true;
      this.web3Contract();
      this.isStartDrepoSyncButtonClicked = false;
    },

    cancelDrepoSync() {
      window.location.href = this.projectPath;
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
  padding: 1.5rem 3rem;
}
</style>
