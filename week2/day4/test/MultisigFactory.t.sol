// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {MultisigFactory} from "../src/MultisigFactory.sol";
import {MultiSigWallet} from "../src/Multisig.sol";

contract MultisigTest is Test {
    MultisigFactory public factory;
    MultiSigWallet public multisig;

    address internal halimah;
    address internal afeez;
    address internal ganiyat;
    address internal mcdavid;

    function setUp() public {
        halimah = makeAddr("Halimah");
        afeez = makeAddr("Afeez");
        ganiyat = makeAddr("Ganiyat");
        mcdavid = makeAddr("McDavid");
        // isaac = makeAddr("Isaac");
        

        address[] memory signers = new address[](4);
        signers[0] = halimah;
        signers[1] = afeez;
        signers[2] = ganiyat;
        signers[3] = mcdavid;
        // signers[4] = isaac;

        uint8 requiredConfirmations = 3;

        factory = new MultisigFactory();
        address multisigChild = factory.createMultisig(signers, requiredConfirmations);
        multisig = MultiSigWallet(payable(multisigChild));
        vm.deal(address(multisig), 3 ether);

        factory.getAllFactoryInstance();
    }

    function test_submitTransaction() public {
        address _to = makeAddr("to");
        uint256 _value = 1 ether;

        vm.prank((halimah));
        multisig.submitTransaction(_to, _value);
        (uint id,address to, uint value, bool executed,uint8 confirmationsCount) = multisig.transactions(0);
        assertEq(id, 1);
        assertEq(to, _to);
        assertEq(value, _value);
        assertEq(executed, false);
        assertEq(confirmationsCount, 0);
    }

     function test_confirmTransaction() public {
        address _to = makeAddr("to");
        uint256 _value = 1 ether;

        vm.prank((halimah));
        multisig.submitTransaction(_to, _value);
        
        vm.prank((afeez));
        multisig.confirmTransaction(0);
        vm.prank((ganiyat));
        multisig.confirmTransaction(0);
        vm.prank((mcdavid));
        multisig.confirmTransaction(0);
      
        (uint id,address to, uint value, bool executed,uint8 confirmationsCount) = multisig.transactions(0);
        assertEq(id, 1);
        assertEq(to, _to);
        assertEq(value, _value);
        assertEq(executed, false);
        assertEq(confirmationsCount, 3);
        multisig.requiredConfirmations();
    }

    function test_execution() public {
        address _to = makeAddr("to");
        uint256 _value = 1 ether;

        vm.prank(halimah);
        multisig.submitTransaction(_to, _value);
        // (address to, uint value, bool executed) = multisig.transactions(0);
        vm.prank(afeez);
        multisig.confirmTransaction(0);
        vm.prank(ganiyat);
        multisig.confirmTransaction(0);
        vm.prank(mcdavid);
        multisig.confirmTransaction(0);
        
        multisig.executeTransaction(0);

        (uint id,address to, uint value, bool executed,uint8 confirmationsCount) = multisig.transactions(0);
        assertEq(id, 1);
        assertEq(to, _to);
        assertEq(value, _value);
        assertEq(executed, true);
        assertEq(confirmationsCount, 3);
    }
    function test_revoke() public {
        address _to = makeAddr("to");
        uint256 _value = 1 ether;

        vm.prank(halimah);
        multisig.submitTransaction(_to, _value);
        // (address to, uint value, bool executed) = multisig.transactions(0);
        vm.prank(afeez);
        multisig.confirmTransaction(0);
        vm.prank(ganiyat);
        multisig.confirmTransaction(0);
        vm.prank(mcdavid);
        multisig.confirmTransaction(0);

        vm.prank(afeez);
        multisig.revokeTransaction(0);
        vm.prank(ganiyat);
        multisig.revokeTransaction(0);

        (uint id,address to, uint value, bool executed,uint8 confirmationsCount) = multisig.transactions(0);
        assertEq(id, 1);
        assertEq(to, _to);
        assertEq(value, _value);
        assertEq(executed, false);
        assertEq(confirmationsCount, 1);
    }

}