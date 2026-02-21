// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://v2.hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const SchoolMangementModule = buildModule("SchoolMangementModule", (m) => {

  const schoolMangement = m.contract("SchoolManagement", [
    "0xfab5Fa47Ed17c48F1866aaEF2087b764df7EBb96", [1000, 2000, 3000, 4000]
  ]);

  return { schoolMangement};
});

export default SchoolMangementModule;
