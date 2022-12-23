import { DeployFunction } from "hardhat-deploy/types"
import { getNamedAccounts, deployments, network, ethers } from "hardhat"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { developmentChains } from "../helper-hardhat-config"
import { verify } from "../helper-functions"

const deployFunction: DeployFunction = async () => {
  const { deploy, log } = deployments
  const { deployer } = await getNamedAccounts()

  await deploy("BPoolsReferral", {
    contract: "BPoolsReferral",
    from: deployer,
    log: true,
    args: [1, 10, deployer],
  })

  const bpoolReferral = await ethers.getContract("BPoolsReferral")

  if (!developmentChains.includes(network.name) && process.env.BSCSCAN_API_KEY) {
    await verify(bpoolReferral.address, [1, 10, deployer])
  }
}

export default deployFunction
deployFunction.tags = [`all`, `swap`, `testnet`, `referral`]
