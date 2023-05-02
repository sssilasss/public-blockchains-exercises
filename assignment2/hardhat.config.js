require("@nomicfoundation/hardhat-toolbox");

const path = require('path')
const res = require('dotenv')
  .config({ path: path.resolve(__dirname, '..', '.env') });



// Beware: NEVER put real Ether into testing accounts.
const MM_PRIVATE_KEY = process.env.METAMASK_1_PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  defaultNetwork: "localhost",
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY
  },
  networks: {
    unima1: {
      url: process.env.NOT_UNIMA_URL_2,
      accounts: [ MM_PRIVATE_KEY ],
    },
    unima2: {
      url: process.env.NOT_UNIMA_URL_2,
      accounts: [ MM_PRIVATE_KEY ],
    },
  },
};
