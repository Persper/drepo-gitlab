<template>
  <div class="check-username-form">
    <hr />
    <div class="form-group group-name-holder col-sm-12">
      <label class="label-bold" for="drepo_users_username">GitLab Contract Address</label>
      <p class="contract-address">{{ contractInfo.gitlab.address }}</p>
    </div>
    <form
      id="check-username"
      class="group-form gl-show-field-errors"
      action="/-/drepo/username_verified"
      accept-charset="UTF-8"
      method="post"
    >
      <input name="utf8" type="hidden" value="✓" />
      <input type="hidden" name="_method" value="patch" />
      <input type="hidden" name="message" :value="originMessage" />
      <input type="hidden" name="signature" :value="signature" />
      <input type="hidden" name="bind_username" :value="bindUsername" />
      <div class="form-group group-name-holder col-sm-12">
        <label class="label-bold" for="drepo_users_username">Pick a username</label>
        <div class="row icon-row">
          <input
            id="drepo_users_username"
            v-model.trim="username"
            class="form-control input-lg"
            required="required"
            title="Please fill in an available username."
            autofocus="autofocus"
            type="text"
            name="username"
            placeholder="My Awesome Username"
            @input="updateUsernameStates"
          />
          <template v-if="iconSuccessStatus">
            <icon name="status_success_borderless" :size="32" css-classes="status-icon-success" />
          </template>
          <template v-if="iconFailureStatus">
            <icon name="status_failed_borderless" :size="32" css-classes="status-icon-failed" />
          </template>
        </div>
      </div>
      <div class="form-group group-name-holder col-sm-12">
        <input
          type="button"
          class="btn btn-success col-lg-2"
          value="Verify"
          :disabled="!isUnlocked || username.length === 0"
          @click.stop.prevent="usernameVerify()"
        />
      </div>
      <div v-if="isRegisterable">
        <hr />
        <div class="form-group group-name-holder col-sm-12">
          <label class="label-bold" for="Username Register">
            Username "{{ username }}" is available. Click to register on Ethereum:
          </label>
        </div>

        <div class="form-group group-name-holder col-sm-12">
          <input
            type="button"
            class="btn btn-success col-lg-2"
            value="Register"
            :disabled="!isUnlocked"
            @click.stop.prevent="usernameRegister()"
          />
        </div>
      </div>

      <div v-if="isBindable">
        <hr />
        <div class="form-group group-name-holder col-sm-12">
          <label class="label-bold" for="Username Register">
            <div
              v-if="
                !isUsernameRegisteredSuccess &&
                  addressHadUsername !== '' &&
                  username.toLowerCase() !== addressHadUsername.toLowerCase()
              "
            >
              You've had registered a username "{{ addressHadUsername }}" by current Ethereum
              address, you can't register another one again. <br />
              You can bind the username "{{ addressHadUsername }}" to current GitLab account by
              signing a message with current Ethereum account.
            </div>
            <div
              v-if="
                !isUsernameRegisteredSuccess &&
                  addressHadUsername !== '' &&
                  username.toLowerCase() === addressHadUsername.toLowerCase()
              "
            >
              You've had registered username "{{ username }}" by current Ethereum address. <br />
              You can bind it to your current GitLab account by signing a message with this Ethereum
              account:
            </div>
            <div v-if="isUsernameRegisteredSuccess">
              Username "{{ username }}" registration success. You need activate it by signing a
              message:
            </div>
          </label>
        </div>

        <div class="form-group group-name-holder col-sm-12">
          <input
            type="button"
            class="btn btn-success col-lg-2"
            :value="bindButtonText"
            :disabled="!isUnlocked"
            @click.stop.prevent="usernameBind()"
          />
        </div>
      </div>

      <div class="form-actions">
        <input type="submit" class="btn btn-success" value="Submit" :disabled="!isSubmittable" />
      </div>
    </form>
  </div>
</template>

<script>
import Icon from '~/vue_shared/components/icon.vue';
import { mapGetters, mapState } from 'vuex';
import axios from 'axios';
import contractInfo from '../contract';

export default {
  name: 'CheckUsername',

  components: {
    Icon,
  },

  data() {
    return {
      contractInfo,
      isUsernameAvailable: false,
      isUsernameVerified: false,
      isUsernameActivated: false,
      isUsernameRegisteredSuccess: false,
      username: '',
      bindButtonText: 'Bind now',
      addressHadUsername: '',
      originMessage: '',
      signature: '',
      isMessageSigned: false,
      bindUsername: '',
    };
  },

  computed: {
    ...mapState([
      'web3Client',
      'accountAddress',
      'unlockOptionState',
      'gasLimit',
      'privateKeyInput',
    ]),

    ...mapGetters(['isUnlocked']),

    iconSuccessStatus() {
      return this.isUsernameAvailable && this.isUsernameVerified;
    },

    iconFailureStatus() {
      return !this.isUsernameAvailable && this.isUsernameVerified;
    },

    usernameNotAvailableAndCanNotBeBound() {
      return (
        this.username.trim() !== '' &&
        !this.isUsernameAvailable &&
        this.isUsernameVerified &&
        this.addressHadUsername === ''
      );
    },

    usernameAvailableAndCanBeRegistered() {
      return (
        this.username.trim() !== '' &&
        this.isUsernameAvailable &&
        this.isUsernameVerified &&
        this.addressHadUsername === ''
      );
    },

    usernameAvailableAndCanNotBeRegistered() {
      return (
        this.username.trim() !== '' &&
        this.isUsernameAvailable &&
        this.isUsernameVerified &&
        this.addressHadUsername !== ''
      );
    },

    isBindable() {
      return (
        (this.username.trim() !== '' &&
          this.isUsernameVerified &&
          this.addressHadUsername !== '') ||
        (this.isUsernameRegisteredSuccess && !this.isUsernameActivated)
      );
    },

    isSubmittable() {
      return (
        this.isUnlocked &&
        this.isUsernameVerified &&
        this.isMessageSigned &&
        (this.isBindable || this.isUsernameActivated)
      );
    },

    isRegisterable() {
      return (
        this.isUsernameAvailable &&
        this.addressHadUsername === '' &&
        this.isUsernameVerified &&
        !this.isUsernameRegisteredSuccess
      );
    },
  },

  watch: {
    accountAddress() {
      if (this.addressHadUsername !== '') {
        this.addressHadUsername = '';
      }
      this.isUsernameAvailable = false;
      this.isUsernameVerified = false;
      this.username = '';
      this.bindUsername = '';
    },
  },

  methods: {
    updateUsernameStates() {
      this.isUsernameAvailable = false;
      this.isUsernameVerified = false;
      this.isUsernameRegisteredSuccess = false;
      this.bindButtonText = 'Bind now';
    },

    createContract() {
      const contractData = this.contractInfo.central.interface;
      const contractAddress = this.contractInfo.central.address;
      let myContract;

      if (this.unlockOptionState === 'metamask') {
        const contract = this.web3Client.eth.contract(contractData);
        myContract = contract.at(contractAddress);
      } else {
        myContract = new this.web3Client.eth.Contract(contractData, contractAddress, {
          from: this.accountAddress,
          gas: this.gasLimit,
        });
      }
      return myContract;
    },

    checkUserByAddress(contract) {
      if (this.unlockOptionState === 'metamask') {
        contract.getUser(this.accountAddress, (err, result) => {
          if (!err) {
            // eslint-disable-next-line no-console
            console.log(result);
            this.checkGetUserResult(result);
          } else {
            // eslint-disable-next-line no-console
            console.log(err);
          }
        });
      } else {
        contract.methods
          .getUser(this.accountAddress)
          .call({ from: this.accountAddress })
          .then(result => {
            // eslint-disable-next-line no-console
            console.log(result);
            this.checkGetUserResult(result);
          })
          .catch(err => {
            // eslint-disable-next-line no-console
            console.log(err);
          });
      }
    },

    checkGetUserResult(user) {
      if (user !== null && typeof user === 'object' && user[0].match(/^[a-zA-Z0-9]+$/)) {
        // eslint-disable-next-line prefer-destructuring
        this.addressHadUsername = user[0];
      }
    },

    usernameVerify() {
      this.isUsernameAvailable = false;
      this.isUsernameVerified = false;
      this.isUsernameRegisteredSuccess = false;

      if (this.username.length > 255 || !this.username.match(/^[a-zA-Z0-9]+$/)) {
        // eslint-disable-next-line no-alert
        alert(
          'Please create a username with only alphanumeric characters and length between 1 and 255.',
        );
        return;
      }

      const myContract = this.createContract();
      // check current account if had registered
      this.checkUserByAddress(myContract);

      if (this.unlockOptionState === 'metamask') {
        myContract.getEntity([window.web3.sha3(this.username)], (err, result) => {
          if (!err) {
            // eslint-disable-next-line no-console
            console.log(result);
            this.checkVerifyResult(result);
          } else {
            // eslint-disable-next-line no-console
            console.log(err);
            // it seems that web3 0.20 can not decode `null` result properly
            if (result === null) this.isUsernameAvailable = true;
            this.isUsernameVerified = true;
          }
        });
      } else {
        myContract.methods
          .getEntity([this.web3Client.utils.soliditySha3(this.username)])
          .call({ from: this.accountAddress })
          .then(result => {
            // eslint-disable-next-line no-console
            console.log(result);
            this.checkVerifyResult(result);
          })
          .catch(err => {
            // eslint-disable-next-line no-console
            console.log(err);
          });
      }
    },

    checkVerifyResult(r) {
      if (r !== null && typeof r === 'object' && r[0] === this.username) {
        this.isUsernameAvailable = false;
      } else {
        this.isUsernameAvailable = true;
      }
      this.isUsernameVerified = true;
      // eslint-disable-next-line no-console
      console.log(this.isUsernameAvailable);
    },

    signMessage() {
      if (this.unlockOptionState === 'metamask') {
        this.metamaskSign();
      } else {
        this.privateKeySign();
      }
    },

    metamaskSign() {
      this.web3Client.personal.sign(
        this.web3Client.toHex(this.originMessage),
        this.accountAddress,
        (err, result) => {
          if (err) return;
          if (result && result !== '') {
            console.log(result);
            this.signature = result;
          }
          this.isMessageSigned = true;
        },
      );
    },

    privateKeySign() {
      this.web3Client.eth.accounts.sign(this.originMessage, this.privateKeyInput, (err, result) => {
        if (err) return;
        if (result && result !== '') {
          console.log(result);
          this.signature = result;
        }
        this.isMessageSigned = true;
      });
    },

    usernameRegister() {
      const myContract = this.createContract();
      const gitlabClientName = 'drepo-gitlab';
      const gitlabAddress = this.contractInfo.gitlab.address;

      if (this.unlockOptionState === 'metamask') {
        myContract.register(this.username, gitlabClientName, gitlabAddress, (err, result) => {
          if (!err) {
            // eslint-disable-next-line no-console
            console.log(result);
            this.isUsernameRegisteredSuccess = true;
            this.bindButtonText = 'Activate now';
          } else {
            // eslint-disable-next-line no-console
            console.log(err);
          }
        });
      } else {
        myContract.methods
          .register(this.username, gitlabClientName, gitlabAddress)
          .send({ from: this.accountAddress })
          .then(result => {
            // eslint-disable-next-line no-console
            console.log(result);
            this.isUsernameRegisteredSuccess = true;
            this.bindButtonText = 'Activate now';
          })
          .catch(err => {
            // eslint-disable-next-line no-console
            console.log(err);
          });
      }
    },

    usernameBind() {
      let bindUsername = this.username;
      if (this.addressHadUsername !== '') {
        bindUsername = this.addressHadUsername;
      }
      this.bindUsername = bindUsername;
      axios
        .get('/-/drepo/sign_message', {
          params: {
            username: bindUsername,
            address: this.accountAddress,
          },
        })
        .then(resp => {
          console.log(resp.data);
          if (
            resp.data &&
            resp.data.status === 'success' &&
            this.accountAddress === resp.data.data.address
          ) {
            this.originMessage = resp.data.data.message;
            this.signMessage();
          } else {
            console.log('request sign message error');
          }
        })
        .catch();
    },
  },
};
</script>

<style scoped>
.check-username-form {
  margin-top: 60px;
}
.contract-address {
  color: #aaa;
}
.icon-row {
  padding-left: 15px;
}
.status-icon-success {
  color: #1aaa55;
}
.status-icon-failed {
  color: #db3b21;
}
</style>
