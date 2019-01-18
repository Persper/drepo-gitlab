import * as contract from './contract.json';

function getContractInfo() {
  return {
    address: contract.address,
    interface: contract.interface,
  };
}

const contractInfo = getContractInfo();

export default contractInfo;
