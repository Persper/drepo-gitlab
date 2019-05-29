import Vue from 'vue';
import contractInfo from './contract';
import EtherWallet from './components/ether_wallet.vue';
import store from './stores';

export default function initEtherWallet(el) {
  if (!el) return null;
  // projectPath for Cancel button to back to project page
  const projectPath = el.getAttribute('data-projectPath');

  return new Vue({
    el,
    store,
    components: { EtherWallet },
    data() {
      return {
        projectPath,
        contractInfo,
      };
    },
    template: '<EtherWallet :projectPath="projectPath" :contractInfo="contractInfo" />',
  });
}
