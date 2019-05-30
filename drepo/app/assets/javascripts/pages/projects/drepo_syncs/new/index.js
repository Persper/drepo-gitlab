import initEtherWallet from '../../../../drepo_projects';
import DrepoPreview from '../../../../drepo_preview';
import CommitsList from '~/commits';

document.addEventListener('DOMContentLoaded', () => {
  const etherWalletElement = document.getElementById('ether_wallet');
  initEtherWallet(etherWalletElement);

  const mrNewSubmitNode = document.querySelector('.js-merge-request-new-submit');
  // eslint-disable-next-line no-new
  new DrepoPreview({
    action: mrNewSubmitNode.dataset.mrSubmitAction,
  });

  new CommitsList(document.querySelector('.js-project-commits-show').dataset.commitsLimit); // eslint-disable-line no-new
});
