// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {MultiSigWallet} from "./Multisig.sol";

contract MultisigFactory{
    address[] allFactoryChildren;
    
    function createMultisig(address[] memory _owners, uint8 _requiredConfirmations) external returns(address multisigChild){
        MultiSigWallet multisig = new MultiSigWallet(_owners,_requiredConfirmations);
        multisigChild = address(multisig);
        allFactoryChildren.push(multisigChild);
    }

    function getAllFactoryInstance() public view returns(address[] memory){
        return allFactoryChildren;
    }
}