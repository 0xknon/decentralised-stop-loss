import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { ethers } from "hardhat";
import {} from "typechain";
import { BobVault } from "../typechain";
import { isAddress } from "viem";

const vaultAddress = process.env.VAULT_ADDRESS;

const main = async () => {
  if (!vaultAddress || !isAddress(vaultAddress)) {
    throw new Error("Missing VAULT_ADDRESS");
  }

  const [bob] = await ethers.getSigners();

  const vault = await ethers.getContractAt("BobVault", vaultAddress as string);
  if (await vault.shouldStopLoss()) {
    await vault.connect(bob).stopLoss();
  }
  const todayData = await vault.getTodayAncillaryData();
  const requestTs = await vault.dataRequestTime(todayData);

  if (requestTs === BigInt(0)) {
    await vault.requestData();
  } else if (Number(requestTs) + 36000 < new Date().getTime() / 1000) {
    const resolved = await vault.getSettledData();
    if (Number(resolved) === 1) {
      await vault.donate();
    }
  }
};

main()
  .then(() => {
    process.exit(0);
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
