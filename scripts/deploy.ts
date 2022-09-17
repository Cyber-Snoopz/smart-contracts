import { ethers, run } from "hardhat";

const tokenURI = "";

async function main() {
  const Medals = await ethers.getContractFactory("Medals");
  const nftCollection = await Medals.deploy(tokenURI);

  await nftCollection.deployTransaction.wait(2);

  await run("verify:verify", {
    address: nftCollection.address,
    constructorArguments: [tokenURI],
  });

  const RewardHandler = await ethers.getContractFactory("RewardHandler");
  const rewardHandler = await RewardHandler.deploy(nftCollection.address);

  await rewardHandler.deployTransaction.wait(2);

  await run("verify:verify", {
    address: rewardHandler.address,
    constructorArguments: [nftCollection.address],
  });

  console.log(
    `NFT Collection is deployed to ${nftCollection.address} and the Reward Handler is deployed to ${rewardHandler.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
