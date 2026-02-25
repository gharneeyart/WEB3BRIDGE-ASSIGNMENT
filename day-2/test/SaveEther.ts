import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("SaveEther", function(){
    async function deploySaveEther(){
        const [owner] = await hre.ethers.getSigners();
        const SaveEther = await hre.ethers.getContractFactory("SaveEther");
        const saveEther = await SaveEther.deploy();

        return {saveEther, owner};
    }

    describe("Deployment", function(){
        it("should deposit ether", async function(){
            const {saveEther} = await loadFixture(deploySaveEther);
            await saveEther.deposit({value: hre.ethers.parseEther("2")});
            const balance = await saveEther.getUserSavings();
            expect(balance).to.equal(hre.ethers.parseEther("2"));
        })
        it("should withdraw ether", async function(){
            const {saveEther} = await loadFixture(deploySaveEther);
            await saveEther.deposit({value: hre.ethers.parseEther("2")});
            await saveEther.withdraw(2000000000000000000n);
            const balance = await saveEther.getUserSavings();
            expect(balance).to.equal(hre.ethers.parseEther("0"));
        })
    })
})