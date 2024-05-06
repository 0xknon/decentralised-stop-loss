import { ethers } from "hardhat";
import {} from "typechain";
import { isAddress } from "viem";

const vaultAddress = process.env.VAULT_ADDRESS;

const main = async () => {
  if (!vaultAddress || !isAddress(vaultAddress)) {
    throw new Error("Missing VAULT_ADDRESS");
  }

  const [bob] = await ethers.getSigners();

  const vault = await ethers.getContractAt("BobVault", vaultAddress as string);
  // Handling Stop Loss
  if (await vault.shouldStopLoss()) {
    await vault.connect(bob).stopLoss();
    console.log("Stop Loss is executed.");
  } else {
    console.log("ETH price is healthy.");
  }

  // Handling Weather Donation
  const todayData = await vault.getTodayAncillaryData();
  const requestTs = await vault.dataRequestTime(todayData);

  if (requestTs === BigInt(0)) {
    console.log("Requesting Weather data....");
    await vault.requestData();
    console.log("Requested");
  } else if (Number(requestTs) + 36000 < new Date().getTime() / 1000) {
    console.log("Settling request...");
    const tx = await vault.settleRequest();
    await tx.wait();

    const resolved = await vault.getSettledData();
    if (Number(resolved) === 1) {
      console.log("Temperature is above 30c.");
      await vault.donate();
      console.log("ETH donated");
    } else {
      console.log("Temperature is below 30c. Not donating =]");
    }
  } else {
    console.log("Weather data not yet settled.");
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
