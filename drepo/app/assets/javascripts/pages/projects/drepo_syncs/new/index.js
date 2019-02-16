import initEtherWallet from '../../../../ether_wallet/index';
import MergeRequest from '~/merge_request';

document.addEventListener('DOMContentLoaded', () => {
  const etherWalletElement = document.getElementById('ether_wallet');
  initEtherWallet(etherWalletElement);

  const mrNewSubmitNode = document.querySelector('.js-merge-request-new-submit');
  // eslint-disable-next-line no-new
  new MergeRequest({
    action: mrNewSubmitNode.dataset.mrSubmitAction,
  });
});
