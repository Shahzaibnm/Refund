
// const { upgradeProxy } = require('@openzeppelin/truffle-upgrades');
// const Refund = artifacts.require("Refund");

// const RefundV2 = artifacts.require('RefundV2');

// module.exports = async function (deployer) {
//     const existing = await Refund.deployed();
//     const instance = await upgradeProxy(existing.address, RefundV2, { deployer });
//     console.log("Upgraded", instance.address);
//   };


const { deployProxy } = require("@openzeppelin/truffle-upgrades");
const Refund = artifacts.require("Refund");

module.exports = async function (deployer) {
  const instance = await deployProxy(
    Refund,
    [
      "0x1b59aF45440dE33A73208F9Db21575D9FFA6c64d",
      "0"
     ],
    { deployer }
  );
  console.log("Deployed", instance.address);
};