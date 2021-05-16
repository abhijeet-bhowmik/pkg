const PKG = artifacts.require("PKG");

module.exports = function (deployer) {
  deployer.deploy(PKG);
};