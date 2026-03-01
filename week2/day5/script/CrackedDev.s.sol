// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Script} from "forge-std/Script.sol";
import {CrackedDev} from "../src/CrackedDev.sol";

contract CrackedDevScript is Script {
    CrackedDev public crackedDev;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        crackedDev = new CrackedDev();

        vm.stopBroadcast();
    }
}