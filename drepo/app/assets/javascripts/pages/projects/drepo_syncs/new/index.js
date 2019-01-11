import initEtherWallet from '../../../../ether_wallet/index';

document.addEventListener('DOMContentLoaded', () => {
  const etherWalletElement = document.getElementById('ether_wallet');
  initEtherWallet(etherWalletElement);
});
