// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, network, run } from "hardhat";
import * as constants from "../constants";

async function main() {
  if (network.name === "mainnet" || network.name === "goerli") {
    await deployRootContract();
  } else if (network.name === "matic" || network.name === "mumbai") {
    await deployChildContract();
  }
}

async function deployRootContract() {
  const networkName = network.name as "mainnet" | "goerli";
  const RocketHeadzMain = await ethers.getContractFactory("RocketHeadzMain");

  const mainContract = await RocketHeadzMain.deploy(
    constants.PROVENANCE_HASH,
    constants.MERKLE_ROOT,
    constants.FX_PORTAL[networkName].checkpointManager,
    constants.FX_PORTAL[networkName].fxRoot
  );

  await mainContract.deployed();
  console.log(
    `RocketHeadzMain deployed to the ${networkName} network at ${mainContract.address}`
  );
  console.log("Waiting for verification...");

  await sleep(75 * 1000);

  await run("verify:verify", {
    address: mainContract.address,
    constructorArguments: [
      constants.PROVENANCE_HASH,
      constants.MERKLE_ROOT,
      constants.FX_PORTAL[networkName].checkpointManager,
      constants.FX_PORTAL[networkName].fxRoot,
    ],
  });

  console.log("Contract verified on Etherscan");
}

async function deployChildContract() {
  const networkName = network.name as "matic" | "mumbai";
  const RocketHeadzPolygon = await ethers.getContractFactory(
    "RocketHeadzPolygon"
  );
  const childContract = await RocketHeadzPolygon.deploy(
    constants.FX_PORTAL[networkName].fxChild
  );

  await childContract.deployed();

  console.log(
    `RocketHeadzPolygon deployed to the ${networkName} network at ${childContract.address}`
  );
  console.log("Waiting for verification...");

  await sleep(20 * 1000);

  await run("verify:verify", {
    address: childContract.address,
    constructorArguments: [constants.FX_PORTAL[networkName].fxChild],
  });

  console.log("Contract verified on Etherscan");
}

async function sleep(ms: number): Promise<void> {
  return new Promise<void>((resolve) => {
    setTimeout(() => resolve(), ms);
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
