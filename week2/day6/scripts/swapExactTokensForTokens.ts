const helpers = require("@nomicfoundation/hardhat-network-helpers");
import { ethers } from "hardhat";

const main = async () => {
  const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
  const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
  const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
  const TokenHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

  await helpers.impersonateAccount(TokenHolder);
  const impersonatedSigner = await ethers.getSigner(TokenHolder);

  const USDC = await ethers.getContractAt(
    "IERC20",
    USDCAddress,
    impersonatedSigner
  );

   const DAI = await ethers.getContractAt(
    "IERC20",
    DAIAddress,
    impersonatedSigner,
  );

  const UniRouterContract = await ethers.getContractAt(
    "IUniswapV2Router",
    UNIRouter,
    impersonatedSigner
  );

    
  const amountIn = ethers.parseUnits("100", 6);
  const amountOutMin = ethers.parseUnits("90", 18);
  const path = [USDCAddress, DAIAddress];
  const deadline = Math.floor(Date.now() / 1000) + 60 * 10;

  await USDC.approve(UNIRouter, amountIn);

  const usdcBalBefore = await USDC.balanceOf(impersonatedSigner.address);
  const daiBalBefore = await DAI.balanceOf(impersonatedSigner.address);

  console.log("=======Before============");

  console.log("usdc balance before", Number(daiBalBefore));
  console.log("dai balance before", Number(usdcBalBefore));

  const transaction = await UniRouterContract.swapExactTokensForTokens(
    amountIn,
    amountOutMin,
    path,
    impersonatedSigner,
    deadline
  );

  await transaction.wait();

  console.log("=======After============");
  const usdcBalAfter = await USDC.balanceOf(impersonatedSigner.address);
  const daiBalAfter = await DAI.balanceOf(impersonatedSigner.address);
  console.log("usdc balance after", Number(usdcBalAfter));
  console.log("dai balance after", Number(daiBalAfter));

  console.log("=========Difference==========");
  const newUsdcValue = Number(usdcBalBefore - usdcBalAfter);
  const newDaiValue = daiBalAfter - daiBalBefore;
  console.log("USDC USED: ", ethers.formatUnits(newUsdcValue, 6));
  console.log("NEW DAI BALANCE: ", ethers.formatUnits(newDaiValue, 18));
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});