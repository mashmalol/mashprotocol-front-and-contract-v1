const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const initialSupply = ethers.utils.parseUnits("1000000", 18);
  const minDelay = 3600; // 1 hour delay
  const proposers = [deployer.address];
  const executors = [deployer.address];

  const Timelock = await ethers.getContractFactory("Timelock");
  const timelock = await Timelock.deploy(minDelay, proposers, executors);
  await timelock.deployed();
  console.log("Timelock deployed at:", timelock.address);

  const MashProtocol = await ethers.getContractFactory("MashProtocol");
  const mashProtocol = await MashProtocol.deploy(initialSupply, timelock.address);
  await mashProtocol.deployed();
  console.log("MashProtocol deployed at:", mashProtocol.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
