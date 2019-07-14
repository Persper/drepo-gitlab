import * as centralContract from './central.json';
import * as gitlabContract from './gitlab.json';

function getContractInfo() {
  return {
    central: {
      address: centralContract.address,
      interface: centralContract.interface,
    },
    gitlab: {
      address: gitlabContract.address,
      interface: gitlabContract.interface,
    },
  };
}

const contractInfo = getContractInfo();

export default contractInfo;
