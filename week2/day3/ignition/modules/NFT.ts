// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://v2.hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const NFTModule = buildModule("NFTModule", (m) => {
  const initialOwner = m.getParameter(
    "initialOwner",
    "0xa57686f076BEC43a7F0031aE58325C9ce8187a85"
  );

  const myToken = m.contract("GaniToken", [initialOwner]);

  return { myToken };
});

export default NFTModule;
