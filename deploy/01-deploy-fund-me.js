//import
// no main and main call for hardhat deploy

// async function deployFunc(hre) { alternative notation
//     console.log("hi")
//     hre.getNamedAccounts()
//     hre.deployments
// }

// module.exports.default = deployFunc // EXPORTS func as the main function of the script

// module.exports = async (hre) => {
//     const { getNamedAccounts, deployments } = hre // pulls these variables from hre, like hre.getNamedAccounts, hre.deployments
// }

// same function as above, syntactic sugar but pulls directly from hre

const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { network } = require("hardhat")
const { verify } = require("../utils/verify")
require("dotenv").config
// or const helperConfig or networkConfig = helperConfig.require...

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    // if chainId is X use address Y, if U then V

    let ethUsdPriceFeedAddress // variable
    if (chainId == 31337) {
        // if local network
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        // if testnet or mainnet
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    // mock contract: if the contract doesnt exist we deploy a minimal version of it for our local testing

    // what happens when we switch chains?

    //when going for localhost or hardhat network we want to use a mock
    const args = [ethUsdPriceFeedAddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args:
            /*address*/
            args,
        // put price feed here
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    if (chainId != 31337 && process.env.ETHERSCAN_API_KEY) {
        await verify(fundMe.address, args)
    }
    log("-----------------------------------------------")
}
module.exports.tags = ["all", "fundme"]
