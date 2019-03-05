import initEtherWallet from '../../../../ether_wallet/index';
import DrepoPreview from '../../../../drepo_preview';

document.addEventListener('DOMContentLoaded', () => {
  const etherWalletElement = document.getElementById('ether_wallet');
  initEtherWallet(etherWalletElement);

  const mrNewSubmitNode = document.querySelector('.js-merge-request-new-submit');
  // eslint-disable-next-line no-new
  new DrepoPreview({
    action: mrNewSubmitNode.dataset.mrSubmitAction,
  });
});
