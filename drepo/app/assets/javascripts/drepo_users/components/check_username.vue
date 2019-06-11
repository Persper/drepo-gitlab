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
      <div class="form-group group-name-holder col-sm-12">
        <label class="label-bold" for="drepo_users_username">Pick a username</label>
        <input
          id="drepo_users_username"
          v-model="username"
          class="form-control input-lg"
          required="required"
          title="Please fill in an available username."
          autofocus="autofocus"
          type="text"
          name="username"
          placeholder="My Awesome Username"
        />
      </div>
      <div class="form-group group-name-holder col-sm-12">
        <input
          type="button"
          class="btn btn-success col-lg-2"
          value="Verify"
          :disabled="!isUnlocked"
          @click.stop.prevent="usernameVerify()"
        />
      </div>
      <hr />
      <div class="form-group group-name-holder col-sm-12">
        <input
          type="button"
          class="btn btn-success col-lg-2"
          value="Register"
          :disabled="!isUnlocked"
          @click.stop.prevent="usernameRegister()"
        />
      </div>

      <!-- <div class="form&#45;group group&#45;name&#45;holder col&#45;sm&#45;12"> -->
      <!--   <label class="label&#45;bold" for="">3) You need active your username</label> -->
      <!--   <input type="button" class="btn btn&#45;success col&#45;lg&#45;2" value="Activate" :disabled="!isSubmittable" /> -->
      <!-- </div> -->

      <div class="form-actions">
        <input type="submit" class="btn btn-success" value="Submit" :disabled="!isSubmittable" />
      </div>
    </form>
  </div>
</template>

<script>
import { mapGetters, mapState } from 'vuex';
import contractInfo from '../contract';

export default {
  name: 'CheckUsername',

  data() {
    return {
      contractInfo,
      isUsernameAvailable: false,
      isUsernameVerified: false,
      isUsernameActivated: false,
      username: '',
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

    isSubmittable() {
      return (
        this.isUnlocked &&
        this.isUsernameAvailable &&
        this.isUsernameVerified &&
        this.isUsernameActivated
      );
    },
  },

  methods: {
    createContract() {
      const contractData = this.contractInfo.central.interface;
      let myContract;

      if (this.unlockOptionState === 'metamask') {
        const contract = this.web3Client.eth.contract(contractData);
        myContract = contract.at(this.contractInfo.central.address);
      } else {
        myContract = new this.web3Client.eth.Contract(
          contractData,
          contractInfo.central.address,
          {
            from: this.accountAddress,
            gas: this.gasLimit,
          },
        );
      }
      return myContract;
    },

    usernameVerify() {
      this.isUsernameAvailable = false;
      const myContract = this.createContract();

      if (this.unlockOptionState === 'metamask') {
        myContract.getEntity([window.web3.sha3(this.username)], (err, result) => {
          // eslint-disable-next-line no-console
          if (!err) console.log(result);
        });
      } else {
        myContract.methods
          .getEntity([this.web3Client.utils.soliditySha3(this.username)])
          .call({ from: this.accountAddress })
          .then(result => {
            // eslint-disable-next-line no-console
            console.log(result);
            if (result === null) {
              this.isUsernameAvailable = true;
            }
            this.isUsernameVerified = true;
          });
      }
    },

    metamaskSign() {
      this.web3Client.personal.sign(
        this.web3Client.toHex('hello'),
        this.accountAddress,
        console.log,
      );
    },

    // ethSign() {
    //   this.web3Client.eth.sign('hello', this.accountAddress, console.log);
    // },
    //

    privateKeySign() {
      const r = this.web3Client.eth.accounts.sign('hello', this.privateKeyInput);
      console.log(r);
    },

    usernameRegister() {
      const myContract = this.createContract();
      const gitlabClientName = 'drepo-gitlab';
      myContract.methods
        .register(this.username, gitlabClientName, this.contractInfo.gitlab.address)
        .send({ from: this.accountAddress })
        .then(result => {
          console.log(`result: ${result}`);
        });
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
</style>
