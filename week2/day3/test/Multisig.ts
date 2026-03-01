import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("MultiSigWallet", function(){
      async function deployMultiSigWallet(){
        const [owner, addr1, addr2, addr3] = await hre.ethers.getSigners();
        //getContractFactory() is used to the instance of the contract you want to deploy for testing.
        const MultiSigWallet = await hre.ethers.getContractFactory("MultiSigWallet");
        const multiSigWallet = await MultiSigWallet.deploy([owner, addr1, addr2], 2);

        return {multiSigWallet, owner, addr1, addr2, addr3};
    }
    describe("Multi Sig Wallet", function(){
        it("Should deposit", async function(){
            const {multiSigWallet, addr3} = await loadFixture(deployMultiSigWallet);
            const depositAmount = hre.ethers.parseEther("1");
            await expect(addr3.sendTransaction({to: await multiSigWallet.getAddress(), value: depositAmount
            })).to.emit(multiSigWallet, "Deposit");
        })
        it("Should submit transaction", async function(){
            const {multiSigWallet, addr2} = await loadFixture(deployMultiSigWallet);
            await expect(multiSigWallet.submitTransaction(addr2.address, hre.ethers.parseEther("1"), "0x")).to.emit(multiSigWallet, "SubmitTransaction");
        })
        it("Should confirm transaction", async function(){
            const {multiSigWallet, addr2} = await loadFixture(deployMultiSigWallet);
            await expect(multiSigWallet.submitTransaction(addr2.address, hre.ethers.parseEther("1"), "0x")).to.emit(multiSigWallet, "SubmitTransaction");
            await expect(multiSigWallet.confirmTransaction(0)).to.emit(multiSigWallet, "ConfirmTransaction");
        })
        it("Should revoke transaction", async function(){
            const {multiSigWallet, addr2} = await loadFixture(deployMultiSigWallet);
            await expect(multiSigWallet.submitTransaction(addr2.address, hre.ethers.parseEther("1"), "0x")).to.emit(multiSigWallet, "SubmitTransaction");
            await expect(multiSigWallet.confirmTransaction(0)).to.emit(multiSigWallet, "ConfirmTransaction");
            await expect(multiSigWallet.revokeTransaction(0)).to.emit(multiSigWallet, "RevokeTransaction");
        })
        it("Should execute transaction", async function(){
            const {multiSigWallet,owner,addr1, addr2} = await loadFixture(deployMultiSigWallet);
            await owner.sendTransaction({to: multiSigWallet.target,value: ethers.parseEther("1")});
            await expect(multiSigWallet.submitTransaction(addr2.address, hre.ethers.parseEther("1"), "0x")).to.emit(multiSigWallet, "SubmitTransaction");
            await multiSigWallet.connect(owner).confirmTransaction(0);
            await multiSigWallet.connect(addr1).confirmTransaction(0);          
            // Should fail with 2 confirmations
            await expect(multiSigWallet.executeTransaction(4)).to.be.revertedWith("tx does not exist");
            // Should succeed with 3 confirmations
            // await multiSigWallet.connect(addr2).confirmTransaction(0);
            await expect(multiSigWallet.executeTransaction(0)).to.emit(multiSigWallet, "ExecuteTransaction");
        })

    });
    // write NFT contract token
    // use a decentralize Storage
    // deploy
})