// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://v2.hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const TodoModule = buildModule("TodoModule", (m) => {

  const todo = m.contract("Todo");

  return { todo};
});

export default TodoModule;
