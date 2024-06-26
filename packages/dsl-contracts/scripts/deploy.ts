import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers, run } from "hardhat";
import {} from "typechain";
import { BobVault } from "../typechain";
import { isAddress } from "viem";

const main = async () => {
  const [owner] = await ethers.getSigners();

  const proxy = await ethers.deployContract("MockChainlinkProxy");
  console.log("MockChainlinkProxy", proxy.target);

  const aggregator = await ethers.deployContract("MockChainlinkAggregator");
  console.log("MockChainlinkAggregator", aggregator.target);

  await proxy.setAggregator(1, aggregator.target);
  console.log("MockChainlinkAggregator is set to the Proxy");

  const weatherOracle = await ethers.deployContract("MockOptimisticOracleV2");
  console.log("MockOptimisticOracleV2", weatherOracle.target);

  const router = await ethers.deployContract("MockUniswapRouter");
  console.log("MockUniswapRouter", router.target);

  const weth = await ethers.deployContract("WETH9");
  console.log("WETH9", weth.target);

  const usdc = await ethers.deployContract("MockERC20");
  console.log("USDC", usdc.target);

  const BobVaultFC = await ethers.getContractFactory("BobVault");
  const vault = await BobVaultFC.deploy(proxy.target, router.target, owner.address, weatherOracle.target, weth.target, usdc.target);

  console.log("BobVault", vault.target);
  await vault.waitForDeployment();
};

main()
  .then(() => {
    process.exit(0);
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
