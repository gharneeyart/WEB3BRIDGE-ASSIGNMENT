// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://v2.hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const SaveAssetModule = buildModule("SaveAssetModule", (m) => {

  const saveAsset = m.contract("SaveAsset", [
    "0xfab5Fa47Ed17c48F1866aaEF2087b764df7EBb96",
  ]);

  return { saveAsset};
});

export default SaveAssetModule;
