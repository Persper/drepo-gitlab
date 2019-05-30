import Vue from 'vue';
import EtherWallet from '../ether_wallet/components/ether_wallet.vue';
import DrepoSubmit from './components/drepo_submit.vue';
import contractInfo from './contract';
import store from '../ether_wallet/stores';

export default function initEtherWallet(el) {
  if (!el) return null;
  // projectPath for Cancel button to back to project page
  const projectPath = el.getAttribute('data-projectPath');

  return new Vue({
    el,
    store,
    components: { EtherWallet, DrepoSubmit },
    data() {
      return {
        projectPath,
        contractInfo,
      };
    },
    template:
      '<div> <EtherWallet /> <DrepoSubmit :projectPath="projectPath" :contractInfo="contractInfo" /> </div>',
  });
}
