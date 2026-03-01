const helpers = require("@nomicfoundation/hardhat-network-helpers");
import { ethers } from "hardhat";

const main = async () => {
  const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
  const WETHAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
  const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
  const USDCWETHPairAddress = "0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc";
  const USDCHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

  await helpers.impersonateAccount(USDCHolder);
  const impersonatedSigner = await ethers.getSigner(USDCHolder);

  const amountUSDC = ethers.parseUnits("600", 6);
  const amountETH = ethers.parseEther("0.2");
  const amountUSDCMin = ethers.parseUnits("400", 6);
  const amountETHMin = ethers.parseEther("0.05");
  const deadline = Math.floor(Date.now() / 1000) + 60 * 10;

  const USDC = await ethers.getContractAt("IERC20", USDCAddress, impersonatedSigner);
  const LPToken = await ethers.getContractAt("IERC20", USDCWETHPairAddress, impersonatedSigner);
  const ROUTER = await ethers.getContractAt("IUniswapV2Router", UNIRouter, impersonatedSigner);
  const PermitToken = await ethers.getContractAt("IERC20Permit", USDCWETHPairAddress, impersonatedSigner);

  await USDC.approve(UNIRouter, amountUSDC);

  const addTx = await ROUTER.addLiquidityETH(
    USDCAddress,
    amountUSDC,
    amountUSDCMin,
    amountETHMin,
    impersonatedSigner.address,
    deadline,
    { value: amountETH } 
  );
  await addTx.wait();
  console.log("Liquidity added. LP tokens acquired.");
  console.log("=========================================================");

  const lpBalBefore = await LPToken.balanceOf(impersonatedSigner.address);
  const liquidityToRemove = lpBalBefore / BigInt(2);

  const amountUSDCMinRemove = ethers.parseUnits("1", 6);
  const amountETHMinRemove = ethers.parseEther("0.001");

  await LPToken.approve(UNIRouter, liquidityToRemove);

  const usdcBalBefore = await USDC.balanceOf(impersonatedSigner.address);
  const ethBalBefore = await ethers.provider.getBalance(impersonatedSigner.address);

  console.log("=================Before========================================");
  console.log("USDC Balance before removing liquidity:", ethers.formatUnits(usdcBalBefore, 6));
  console.log("ETH Balance before removing liquidity:", ethers.formatEther(ethBalBefore));
  console.log("LP Token Balance before removing liquidity:", ethers.formatUnits(lpBalBefore, 18));

  const { v, r, s } = await helpers.getPermitSignature(
  impersonatedSigner,
  LPToken,
  UNIRouter,
  liquidityToRemove,
  deadline
);

  const tx = await ROUTER.removeLiquidityETHWithPermit(
    USDCAddress,          
    liquidityToRemove,    
    amountUSDCMinRemove,  
    amountETHMinRemove,   
    impersonatedSigner.address,
    deadline,
    false,
    v,
    r,
    s
  );
  await tx.wait();

  const usdcBalAfter = await USDC.balanceOf(impersonatedSigner.address);
  const ethBalAfter = await ethers.provider.getBalance(impersonatedSigner.address);
  const lpBalAfter = await LPToken.balanceOf(impersonatedSigner.address);

  console.log("=================After========================================");
  console.log("USDC Balance after removing liquidity:", ethers.formatUnits(usdcBalAfter, 6));
  console.log("ETH Balance after removing liquidity:", ethers.formatEther(ethBalAfter));
  console.log("LP Token Balance after removing liquidity:", ethers.formatUnits(lpBalAfter, 18));
  console.log("Liquidity removed successfully!");
  console.log("=========================================================");

  const usdcReceived = usdcBalAfter - usdcBalBefore;
  const ethReceived = ethBalAfter - ethBalBefore;
  const lpBurned = lpBalBefore - lpBalAfter;

  console.log("USDC RECEIVED:", ethers.formatUnits(usdcReceived, 6));
  console.log("ETH RECEIVED:", ethers.formatEther(ethReceived));
  console.log("LP BURNED:", ethers.formatUnits(lpBurned, 18));
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});