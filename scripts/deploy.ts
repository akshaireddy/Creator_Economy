import { ethers } from "hardhat";
const { upgrades } = require('hardhat');

async function main() {
  const CreatorEconomy = await ethers.getContractFactory('CreatorEconomy');
  const creatorEconomy = await upgrades.deployProxy(CreatorEconomy, []);

  await creatorEconomy.deployed();

  console.log('CreatorEconomy deployed to:', creatorEconomy.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
