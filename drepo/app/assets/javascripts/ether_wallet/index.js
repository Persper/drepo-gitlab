import Vue from 'vue';
import EtherWallet from './components/ether_wallet.vue';

export default function initEtherWallet(el) {
  if (!el) return null;
  // projectPath for Cancel button to back to project page
  const projectPath = el.getAttribute('data-projectPath');

  return new Vue({
    el,
    components: { EtherWallet },
    data() {
      return {
        projectPath,
      };
    },
    template: '<EtherWallet :projectPath="projectPath" />',
  });
}
