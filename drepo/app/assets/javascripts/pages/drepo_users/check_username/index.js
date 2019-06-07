import Vue from 'vue';
import EtherWallet from '../../../ether_wallet/components/ether_wallet.vue';
import CheckUsername from '../../../drepo_users/components/check_username.vue';
import store from '../../../ether_wallet/stores';

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('check-username-form');
  const unlockOptionsTitle = 'Unlock by your private key:';
  const defaultUnlockOption = 'metamask';
  const availableUnlockOptions = ['metamask', 'mnemonic_phrase', 'private_key'];

  return new Vue({
    el,
    store,
    components: { EtherWallet, CheckUsername },
    data() {
      return {
        unlockOptionsTitle,
        defaultUnlockOption,
        availableUnlockOptions,
      };
    },
    template:
      '<div> <EtherWallet :unlockOptionsTitle="unlockOptionsTitle" :defaultUnlockOption="defaultUnlockOption" :availableUnlockOptions="availableUnlockOptions" /> <CheckUsername /> </div>',
  });
});
