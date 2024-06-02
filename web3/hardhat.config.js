require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
const PRIVATE_KEY = "3ee754937b4529684ee5b0c7bed8e71deda4ae5d3bbe72e789114a628a3107d1";
const RPC_URL = "https://rpc-amoy.polygon.technology/";
module.exports = {
  defaultNetwork: "polygonAmoy",
  networks: {
    hardhat: {
      chainId: 80002,
    },
    polygonAmoy: {
      url: "https://rpc-amoy.polygon.technology/",
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
