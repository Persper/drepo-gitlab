import Vue from 'vue';
import EtherWallet from '../../../ether_wallet/components/ether_wallet.vue';
import CheckUsername from '../../../drepo_users/components/check_username.vue';
import store from '../../../ether_wallet/stores';

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('check-username-form');
  const defaultUnlockOption = 'metamask';
  const availableUnlockOptions = ['metamask', 'private_key'];

  return new Vue({
    el,
    store,
    components: { EtherWallet, CheckUsername },
    data() {
      return {
        defaultUnlockOption,
        availableUnlockOptions,
      };
    },
    template:
      '<div> <EtherWallet :defaultUnlockOption="defaultUnlockOption" :availableUnlockOptions="availableUnlockOptions" /> <CheckUsername /> </div>',
  });
});
