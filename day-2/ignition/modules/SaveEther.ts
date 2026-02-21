// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://v2.hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const SaveEtherModule = buildModule("SaveEtherModule", (m) => {

  const saveEther = m.contract("SaveEther");

  return { saveEther};
});

export default SaveEtherModule;
