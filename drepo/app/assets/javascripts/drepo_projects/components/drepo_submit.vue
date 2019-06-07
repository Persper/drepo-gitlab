<template>
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
</template>

<script>
import { mapGetters, mapState } from 'vuex';

export default {
  name: 'DrepoSubmit',

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
      isStartDrepoSyncButtonClicked: false,
    };
  },

  computed: {
    ...mapState(['web3Client', 'accountAddress', 'unlockOptionState', 'gasLimit']),

    ...mapGetters(['isUnlocked']),

    isStartDrepoSyncButtonClickable() {
      return !this.isStartDrepoSyncButtonClicked && this.isUnlocked;
    },
  },

  methods: {
    web3Contract() {
      const contractData = this.contractInfo.interface;
      if (this.unlockOptionState === 'metamask') {
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
