const {
    network,
    ethers: {utils},
    ethers
} = require("hardhat");


module.exports = {
    setTokenBalance: async (token, addr, amount) => {
        const index = 1;
        const preKey = utils.concat([
            utils.hexZeroPad(addr, 32),
            utils.hexZeroPad(ethers.BigNumber.from(index).toHexString(), 32),
        ]);
        const key = utils.keccak256(preKey);
        const before = await ethers.provider.getStorageAt(token, key);
        await network.provider.send("hardhat_setStorageAt", [
            token,
            key,
            utils.hexZeroPad(ethers.BigNumber.from(amount).toHexString(), 32),
        ]);
    }
}