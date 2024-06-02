const hre = require("hardhat");

async function main() {
  const tokenStaking = await hre.ethers.deployContract("TokenStaking");
  await tokenStaking.waitForDeployment();

  //const myToken = await hre.ethers.deployContract("MyToken");
  //await myToken.waitForDeployment();

  console.log(` STACKING: ${tokenStaking.target}`);
  //console.log(` TOKEN: ${myToken.target} `);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
