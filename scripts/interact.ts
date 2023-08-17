require('dotenv').config();
const { ethers } = require('hardhat');
const fs = require('fs');

async function main() {
  const contractAddress = process.env.CONTRACT_ADDRESS;
  const privateKey = process.env.PRIVATE_KEY;
  const wallet = new ethers.Wallet(privateKey, ethers.provider);

  const creatorEconomy = await ethers.getContractAt('CreatorEconomy', contractAddress, wallet);

  // Interact with the contract here

  // Create a new creator
  await creatorEconomy.createCreator("John Doe");

  // Create a new token
  const tokenId = 1;
  const tokenPrice = ethers.utils.parseEther('0.1'); // 0.1 ETH
  await creatorEconomy.createToken(tokenId, tokenPrice);

  // Purchase a token
  const buyerAddress = wallet.address; // Your wallet's address
  const purchaseTx = await creatorEconomy.purchaseToken(wallet.address, tokenId, {
    value: tokenPrice, // Send the correct amount of Ether for the purchase
  });
  await purchaseTx.wait();

  // Get creator's balance
  const creatorAddress = '0x70997970c51812dc3a010c7d01b50e0d17dc79c8'; // Replace with the creator's address
  const creatorBalance = await creatorEconomy.getCreatorBalance(creatorAddress);
  console.log(`Creator's balance: ${ethers.utils.formatEther(creatorBalance)} ETH`);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
