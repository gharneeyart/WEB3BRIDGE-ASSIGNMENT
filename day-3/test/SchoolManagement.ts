import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("SchoolManagement", function() {
     async function deploySchoolManagement(){
        const [owner, otherAccount] = await hre.ethers.getSigners();

        const ERC20 = await hre.ethers.getContractFactory("ERC20");
        const erc20 = await ERC20.deploy("MyToken", "MTK", 18, 1000000);
        //getContractFactory() is used to the instance of the contract you want to deploy for testing.
        const SchoolManagement = await hre.ethers.getContractFactory("SchoolManagement");
        const schoolManagement = await SchoolManagement.deploy(erc20.target);

        return {schoolManagement, owner, erc20};
    }

    describe("School Mangement", function(){
        it("Should register staff", async function(){
            const {schoolManagement, owner} = await loadFixture(deploySchoolManagement);
            const name: string = "Gani";
            const wallet: string = "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB";
            const salary: number = 1000;

            await schoolManagement.registerStaff(name, wallet, salary);
        })
    })
});