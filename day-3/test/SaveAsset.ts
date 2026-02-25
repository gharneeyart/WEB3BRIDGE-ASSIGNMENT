import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";


describe("ERC20", function(){
    async function deployERC20(){
        const [owner] = await hre.ethers.getSigners();
        //getContractFactory() is used to the instance of the contract you want to deploy for testing.
        const ERC20 = await hre.ethers.getContractFactory("ERC20");
        const erc20 = await ERC20.deploy("MyToken", "MTK", 18, 1000000);

        return {erc20, owner};
    }

    describe("Deployment", function(){
        it("should get token name", async function(){
            const {erc20} = await loadFixture(deployERC20);
            const name = await erc20.name();

            expect(name).to.equal("MyToken");
        })
        it("should get token symbol", async function(){
            const {erc20} = await loadFixture(deployERC20);
            const symbol = await erc20.symbol();

            expect(symbol).to.equal("MTK");
        })
        it("should get token decimals", async function(){
            const {erc20} = await loadFixture(deployERC20);
            const decimals = await erc20.decimals();

            expect(decimals).to.equal(18);
        })
        it("should get token total supply", async function(){
            const {erc20} = await loadFixture(deployERC20);
            const total_supply = await erc20.totalSupply();

            expect(total_supply).to.equal(1000000000000000000000000n);
        })
        it("should get token balance", async function(){
            const {erc20, owner} = await loadFixture(deployERC20);
            const balanceOf = await erc20.balanceOf(owner);

            expect(balanceOf).to.equal(1000000000000000000000000n);
        })
    })
});

describe("SaveAsset", function() {
     async function deploySaveAsset(){
        const [owner] = await hre.ethers.getSigners();

        const ERC20 = await hre.ethers.getContractFactory("ERC20");
        const erc20 = await ERC20.deploy("MyToken", "MTK", 18, 1000000);
        //getContractFactory() is used to the instance of the contract you want to deploy for testing.
        const SaveAsset = await hre.ethers.getContractFactory("SaveAsset");
        const saveAsset = await SaveAsset.deploy(erc20.target);

        return {saveAsset, owner, erc20};
    }

    describe("Deposit & Withdraw Ether", function(){
        it("should deposit ether", async function(){
            const {saveAsset} = await loadFixture(deploySaveAsset);
            await saveAsset.depositEther({value: hre.ethers.parseEther("2")});
            const balance = await saveAsset.getUserEtherSavings();
            expect(balance).to.equal(hre.ethers.parseEther("2"));
        })
        it("should withdraw ether", async function(){
            const {saveAsset} = await loadFixture(deploySaveAsset);
            await saveAsset.depositEther({value: hre.ethers.parseEther("2")});
            await saveAsset.withdrawEther(2000000000000000000n);
            const balance = await saveAsset.getUserEtherSavings();
            expect(balance).to.equal(hre.ethers.parseEther("0"));
        })
    })

    describe("Deposit & Withdraw ERC20 Token", function(){
        it("should deposit token", async function(){
            const {saveAsset, erc20} = await loadFixture(deploySaveAsset);
            await erc20.approve(saveAsset.target, 5000000000000000000000n);
            await saveAsset.depositToken(5000000000000000000000n);
            const balance = await saveAsset.getTokenBalance();
            expect(balance).to.equal(5000000000000000000000n);
        })
        it("should withdraw token", async function(){
            const {saveAsset, erc20} = await loadFixture(deploySaveAsset);
            await erc20.approve(saveAsset.target, 5000000000000000000000n);
            await saveAsset.depositToken(5000000000000000000000n);
            await saveAsset.withdrawToken(3000000000000000000000n);
            const balance = await saveAsset.getTokenBalance();
            expect(balance).to.equal(2000000000000000000000n);
        })
        it("should revert withdraw if insufficient funds", async function(){
            const {saveAsset, erc20} = await loadFixture(deploySaveAsset);
            const withdraw = saveAsset.withdrawToken(3000000000000000000000n);
            await expect(withdraw).to.be.revertedWith("Insufficient funds");
        })
    })
})

// describe("Save Asset", function () {

//   async function deploySaveAsset() {
//     const token = "0xfab5Fa47Ed17c48F1866aaEF2087b764df7EBb96"
//     const [owner, addr1] = await hre.ethers.getSigners();
//     const SaveAsset = await hre.ethers.getContractFactory("SaveAsset");
//     const saveAsset = await SaveAsset.deploy(token);
//     return { saveAsset, owner, addr1 };
//   }

//   it("Should deposit ETH", async function () {
//     const { saveAsset, addr1 } = await loadFixture(deploySaveAsset);
//     const depositAmount = hre.ethers.parseEther("1.0"); 

//     await saveAsset.connect(addr1).depositEther({ value: depositAmount });

//     expect(await saveAsset.getContractBalance()).to.equal(depositAmount);
//     expect(await saveAsset.etherBalances(addr1.address)).to.equal(depositAmount);
//   });

//   it("Should withdraw ETH", async function () {
//     const { saveAsset, addr1 } = await loadFixture(deploySaveAsset);
//     const depositAmount = hre.ethers.parseEther("1.0");
//     const withdrawAmount = hre.ethers.parseEther("0.5");

//     await saveAsset.connect(addr1).depositEther({ value: depositAmount });

//     await saveAsset.connect(addr1).withdrawEther(withdrawAmount);

//     expect(await saveAsset.getContractBalance()).to.equal(depositAmount - withdrawAmount);
//     expect(await saveAsset.etherBalances(addr1.address)).to.equal(depositAmount - withdrawAmount);
//   });

//   it("Should deposit Token", async function () {
//     const { saveAsset, addr1 } = await loadFixture(deploySaveAsset);
//     const depositAmount = hre.ethers.parseEther("1.0"); 

//     await saveAsset.connect(addr1).depositEther({ value: depositAmount });

//     expect(await saveAsset.getContractBalance()).to.equal(depositAmount);
//     expect(await saveAsset.etherBalances(addr1.address)).to.equal(depositAmount);
//   });
// });

