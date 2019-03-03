<template>
  <div id="js-ether-wallet-access" class="row ether-wallet-container">
    <div class="col-lg-3">
      <label>Select a way to access your wallet:</label>
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
          v-model="mnemonicPhraseInput"
          class="col-lg-12 ether-input"
          placeholder="Mnemonic Phrase"
        ></textarea>
        <label class="col-lg-12"
          >Address Index(optional, the first one will be used by default) :
        </label>
        <input
          v-model="addressIndexInput"
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
          v-model="privateKeyInput"
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
    <div class="col-lg-4">
      <div id="account-info">
        <AccountInfo
          v-if="isUnlocked"
          :account-balance="accountBalance"
          :account-address="accountAddress"
        />
      </div>
    </div>
    <div class="col-lg-8"></div>
    <div class="col-lg-12">
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
  </div>
</template>

<script>
import * as Web3One from 'web3';
import { detect } from 'detect-browser';
import HDWalletProvider from 'truffle-hdwallet-provider';
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

  data() {
    return {
      web3Client: null,
      accountAddress: '',
      unlockOption: '',
      isMetaMaskSupportedBrowser: false,
      isMetaMaskTurnedOn: false,
      isMetaMaskLoggedIn: false,
      accountBalance: '0',
      isConnectToMetaMaskButtonClicked: false,
      isUnlockByPrivateKeyButtonClicked: false,
      isUnlockByMnemonicPhraseButtonClicked: false,
      isStartDrepoSyncButtonClicked: false,
      mnemonicPhraseInput: '',
      addressIndexInput: 1,
      privateKeyInput: '',
      gasLimit: 1000000,
      transactionObject: {
        from: this.accountAddress,
        gas: this.gasLimit,
      },
    };
  },

  computed: {
    isUnlocked() {
      return this.accountAddress !== '' && this.accountBalance !== '';
    },

    isConnectToMetaMaskButtonClickable() {
      return !this.isConnectToMetaMaskButtonClicked && this.isMetaMaskLoggedIn;
    },

    isUnlockByPrivateKeyButtonClickable() {
      return (
        !this.isUnlockByPrivateKeyButtonClicked && this.privateKeyInput.trim().match(/^\w{64}$/)
      );
    },

    isUnlockByMnemonicPhraseButtonClickable() {
      return (
        !this.isUnlockByMnemonicPhraseButtonClicked && this.mnemonicPhraseInput.trim().length > 11
      );
    },

    isStartDrepoSyncButtonClickable() {
      return !this.isStartDrepoSyncButtonClicked && this.isUnlocked;
    },
  },

  mounted() {
    const browser = detect();

    if (browser) {
      this.isMetaMaskSupportedBrowser = this.isBrowserSupportMetaMask(browser);

      if (this.isMetaMaskSupportedBrowser) {
        // to help decide the default unlock option is metamask
        this.unlockOption = 'metamask';

        if (typeof window !== 'undefined' && typeof window.web3 !== 'undefined') {
          // the MetaMask extension is on
          this.isMetaMaskTurnedOn = true;
          // if the user login the MetaMask account
          window.web3.eth.getAccounts((err, accounts) => {
            if (err != null) {
              // console.error('An error occurred: ' + err);
              this.isMetaMaskLoggedIn = false;
            } else if (accounts.length > 0) {
              // console.log('User is logged in to MetaMask');
              this.isMetaMaskLoggedIn = true;
            } else {
              // console.log('User is not logged in to MetaMask');
              this.isMetaMaskLoggedIn = false;
            }
          });

          const self = this;
          window.ethereum.on('accountsChanged', accounts => {
            if (accounts[0] && self.web3Client && self.unlockOption === 'metamask') {
              self.updateAccountInfo(accounts[0]);
            }
          });
        }
      } else {
        // the browser not support MetaMask
        this.unlockOption = 'mnemonic_phrase';
      }
    }
  },

  methods: {
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

    loginMetaMask() {
      if (!this.isMetaMaskLoggedIn) window.ethereum.enable();
    },

    connectToMetaMask() {
      if (this.isConnectToMetaMaskButtonClicked) return;
      this.isConnectToMetaMaskButtonClicked = true;
      // console.log('>>>>>>>>>>>>>>> MetaMask <<<<<<<<<<<<<<<<');
      this.web3Client = new window.Web3(window.web3.currentProvider);
      this.updateAccountInfo();
      this.isConnectToMetaMaskButtonClicked = false;
    },

    unlockByPrivateKey() {
      if (this.isUnlockByPrivateKeyButtonClicked) return;
      this.isUnlockByPrivateKeyButtonClicked = true;
      // console.log('>>>>>>>>>>>>>>> PrivateKey <<<<<<<<<<<<<<<<');
      const provider = new HDWalletProvider(
        `0x${this.privateKeyInput}`,
        'https://rinkeby.infura.io/v3/8d1ba1e9ef484906ba94d560cc1d3a87',
      );
      // console.log(provider);
      this.web3Client = new Web3One(provider);
      this.updateAccountInfo();
      this.isUnlockByPrivateKeyButtonClicked = false;
    },

    unlockByMnemonicPhrase() {
      if (this.isUnlockByMnemonicPhraseButtonClicked) return;
      this.isUnlockByMnemonicPhraseButtonClicked = true;
      // console.log('>>>>>>>>>>>>>>> Mnemonic Phrase <<<<<<<<<<<<<<<<');
      if (this.addressIndexInput < 1) return;
      const provider = new HDWalletProvider(
        this.mnemonicPhraseInput,
        'https://rinkeby.infura.io/v3/8d1ba1e9ef484906ba94d560cc1d3a87',
        this.addressIndexInput - 1,
      );
      // console.log(provider);
      this.web3Client = new Web3One(provider);
      this.updateAccountInfo();
      this.isUnlockByMnemonicPhraseButtonClicked = false;
    },

    updateAccountInfo(account) {
      if (account && this.web3Client) {
        this.web3Client.eth.defaultAccount = account;
        this.accountAddress = account;
        this.getBalance();
      } else {
        this.web3Client.eth.getAccounts((err, accounts) => {
          if (err || accounts.length < 1) return;
          const [firstAccount] = accounts;
          this.accountAddress = firstAccount;
          this.web3Client.eth.defaultAccount = firstAccount;
          if (this.accountAddress) this.getBalance();
        });
      }
    },

    getBalance() {
      this.web3Client.eth.getBalance(this.accountAddress, (err, balance) => {
        if (err) return;

        // console.log(this.accountBalance);
        if (!balance) {
          this.accountBalance = 'Query balance failed';
        } else if (this.unlockOption === 'metamask') {
          this.accountBalance = this.web3Client.fromWei(balance, 'ether').toString();
        } else {
          this.accountBalance = this.web3Client.utils.fromWei(balance, 'ether').toString();
        }
      });
    },

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
          this.transactionObject,
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
.ether-wallet-container {
  max-width: 100%;
  overflow-x: hidden;
  text-align: left;
  margin-top: 30px;
}

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
</style>
