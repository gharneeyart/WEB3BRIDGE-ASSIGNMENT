import { expect } from "chai";
import { network } from "hardhat";
import { ethers } from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

describe("Uniswap V2: swapExactTokensForTokens", function () {
    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const WETHAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    // const USDCWETHPair = "0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc";
    // const USDCDAIPair = "0xAE461cA67B15dc8dc81CE7615e0320dA1A9aB8D5";
    const USDCHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

    async function deployUniswapV2Router(){
    await helpers.impersonateAccount(USDCHolder);
    let impersonatedSigner = await ethers.getSigner(USDCHolder);
    let deadline = Math.floor(Date.now() / 1000) + 60 * 10;

    let USDC = await ethers.getContractAt("IERC20", USDCAddress, impersonatedSigner);
    let DAI  = await ethers.getContractAt("IERC20", DAIAddress,  impersonatedSigner);
    let WETH = await ethers.getContractAt("IERC20", WETHAddress, impersonatedSigner);

    // let USDCWETHLPToken = await ethers.getContractAt("IERC20Permit", USDCWETHPair, impersonatedSigner);
    // let USDCDAILPToken  = await ethers.getContractAt("IERC20Permit", USDCDAIPair,  impersonatedSigner);

    const ROUTER = await ethers.getContractAt("IUniswapV2Router", UNIRouter, impersonatedSigner);

    await helpers.setBalance(USDCHolder, ethers.parseEther("10000"));
    
    return { impersonatedSigner, USDC, DAI, WETH, ROUTER, deadline };
        
    }

    describe("Deployed Uniswap V2", function () {
        it("should swapExactTokensForTokens", async function () {
            const { impersonatedSigner, USDC, DAI, ROUTER, deadline } = await deployUniswapV2Router();

            const amountIn = ethers.parseUnits("100", 6); 
            const amountOutMin = ethers.parseUnits("90", 18);
            const path = [USDCAddress, DAIAddress]; 

            await USDC.approve(UNIRouter, amountIn);

            const daiBalanceBefore = await DAI.balanceOf(impersonatedSigner.address);
            console.log("DAI Balance before swap:", Number(daiBalanceBefore));
            const usdcBalanceBefore = await USDC.balanceOf(impersonatedSigner.address);
            console.log("USDC Balance before swap:", Number(usdcBalanceBefore));

            const tx = await ROUTER.swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                impersonatedSigner.address,
                deadline
            );
            await tx.wait();

            const daiBalanceAfter = await DAI.balanceOf(impersonatedSigner.address);
            console.log("DAI Balance after swap:", Number(daiBalanceAfter));
            expect(daiBalanceAfter).to.be.gt(daiBalanceBefore);  
            const usdcBalanceAfter = await USDC.balanceOf(impersonatedSigner.address);
            console.log("USDC Balance after swap:", Number(usdcBalanceAfter));

            expect(usdcBalanceAfter).to.be.lt(usdcBalanceBefore);  
            expect(usdcBalanceBefore - usdcBalanceAfter).to.equal(amountIn);
        })});

        it("should swapTokensForExactTokens", async function(){
            const { impersonatedSigner, USDC, DAI, ROUTER, deadline } = await deployUniswapV2Router();

            const amountOut = ethers.parseUnits("100", 18);
            const amountInMax = ethers.parseUnits("110", 6);
            const path = [USDCAddress, DAIAddress];

            await USDC.approve(UNIRouter, amountInMax);

            const daiBalanceBefore = await DAI.balanceOf(impersonatedSigner.address);
            console.log("DAI Balance before swap:", Number(daiBalanceBefore));
            const usdcBalanceBefore = await USDC.balanceOf(impersonatedSigner.address);
            console.log("USDC Balance before swap:", Number(usdcBalanceBefore));

            const tx = await ROUTER.swapTokensForExactTokens(
                amountOut,
                amountInMax,
                path,
                impersonatedSigner.address,
                deadline
            );
            await tx.wait();

            const daiBalanceAfter = await DAI.balanceOf(impersonatedSigner.address);
            console.log("DAI Balance after swap:", Number(daiBalanceAfter));
            expect(daiBalanceAfter).to.be.gt(daiBalanceBefore);  
            const usdcBalanceAfter = await USDC.balanceOf(impersonatedSigner.address);
            console.log("USDC Balance after swap:", Number(usdcBalanceAfter));

            expect(usdcBalanceAfter).to.be.lt(usdcBalanceBefore);  
            expect(usdcBalanceBefore - usdcBalanceAfter).to.be.lte(amountInMax);
            expect(daiBalanceAfter - daiBalanceBefore).to.equal(amountOut);

        })

        it("should swapTokensForExactETH", async function(){
            const { impersonatedSigner, USDC, ROUTER, deadline } = await deployUniswapV2Router();

            const amountOut = ethers.parseEther("1");
            const amountInMax = ethers.parseUnits("3000", 6);
            const path = [USDCAddress, WETHAddress];

            await USDC.approve(UNIRouter, amountInMax);

            const usdcBalanceBefore = await USDC.balanceOf(impersonatedSigner.address);
            const wethBalanceBefore = await ethers.provider.getBalance(impersonatedSigner.address);
            console.log("WETH Balance before swap:", Number(wethBalanceBefore));
            console.log("USDC Balance before swap:", Number(usdcBalanceBefore));

             const transaction = await ROUTER.swapTokensForExactETH(
                amountOut,
                amountInMax,
                path,
                impersonatedSigner,
                deadline
            );

            await transaction.wait();

            const usdcBalanceAfter = await USDC.balanceOf(impersonatedSigner.address);
            const wethBalanceAfter = await ethers.provider.getBalance(impersonatedSigner.address);
            console.log("WETH Balance after swap:", Number(wethBalanceAfter));
            console.log("USDC Balance after swap:", Number(usdcBalanceAfter));

            expect(wethBalanceAfter).to.be.gt(wethBalanceBefore);  
            expect(usdcBalanceAfter).to.be.lt(usdcBalanceBefore);  
            expect(usdcBalanceBefore - usdcBalanceAfter).to.be.lte(amountInMax);
            expect(wethBalanceAfter - wethBalanceBefore).to.be.closeTo(amountOut, ethers.parseEther("0.01"));
        })

        it("should swapETHForExactTokens", async function(){
            const { impersonatedSigner, USDC, ROUTER, deadline } = await deployUniswapV2Router();

            const amountOut = ethers.parseUnits("100", 6);
            const path = [WETHAddress, USDCAddress];

            const usdcBalanceBefore = await USDC.balanceOf(impersonatedSigner.address);
            const wethBalanceBefore = await ethers.provider.getBalance(impersonatedSigner.address);
            console.log("WETH Balance before swap:", Number(wethBalanceBefore));
            console.log("USDC Balance before swap:", Number(usdcBalanceBefore));

            const transaction = await ROUTER.swapETHForExactTokens(
                amountOut,
                path,
                impersonatedSigner,
                deadline,
                {
                value: ethers.parseEther("1"),
                }
            );

            await transaction.wait();

            const usdcBalanceAfter = await USDC.balanceOf(impersonatedSigner.address);
            const wethBalanceAfter = await ethers.provider.getBalance(impersonatedSigner.address);
            console.log("WETH Balance after swap:", Number(wethBalanceAfter));
            console.log("USDC Balance after swap:", Number(usdcBalanceAfter));

            expect(wethBalanceAfter).to.be.lt(wethBalanceBefore);
            expect(usdcBalanceAfter).to.be.gt(usdcBalanceBefore);
            expect(usdcBalanceAfter - usdcBalanceBefore).to.equal(amountOut);
            expect(wethBalanceBefore - wethBalanceAfter).to.be.lte(ethers.parseEther("1"));
        
        })
 
});