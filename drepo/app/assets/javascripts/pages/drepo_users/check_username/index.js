import Vue from 'vue';
import EtherWallet from '../../../ether_wallet/components/ether_wallet.vue';
import CheckUsername from '../../../drepo_users/components/check_username.vue';
import store from '../../../ether_wallet/stores';

document.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('check-username-form');

  return new Vue({
    el,
    store,
    components: { EtherWallet, CheckUsername },
    template: '<div> <EtherWallet /> <CheckUsername /> </div>',
  });
});
