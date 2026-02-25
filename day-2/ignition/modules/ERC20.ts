// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://v2.hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const Erc20Module = buildModule("Erc20Module", (m) => {

  const erc20 = m.contract("ERC20", [
    "GaniToken",      // name
    "GTK",          // symbol
    18,             // decimals
    1_000_000_000_000       // total supply
  ]);

  return { erc20};
});

export default Erc20Module;
