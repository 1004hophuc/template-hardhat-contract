import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import { assert, expect } from "chai"
import { BigNumber, Signer } from "ethers"
import { BPOOLSREFERRAL, MockERC20 } from "../typechain"

describe("Bpools unit tests", async function () {
  let bpoolReferral: BPOOLSREFERRAL,
    signers: SignerWithAddress[],
    deployer: string,
    usdt: MockERC20,
    busd: MockERC20,
    wbnb: MockERC20

  describe("Bpool testing ", async () => {
    it("Should work pool", async () => {
        
    })
  })
})
