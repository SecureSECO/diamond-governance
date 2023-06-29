import { SignVerification } from "../../typechain-types";
import { DiamondGovernanceSugar, Stamp, VerificationThreshold } from "./sugar";
import { ContractTransaction, BigNumber, ethers, providers } from "ethers";
import { Signer } from "@ethersproject/abstract-signer";
import { GetTypedContractAt } from "../../utils/contractHelper";
import { asyncMap } from "./utils";

/**
 * VerificationSugar is a class that provides methods for interacting with the verification contract.
 *
 * @remarks
 * This class is accessed through the (root) DiamondGovernanceClient object
 */
export class VerificationSugar {
  /**
   * Cache for the verification contract and threshold history
   *
   * @remarks
   * This cache is used to reduce the number of calls to the blockchain, the cache is filled on the first call to a method that requires it
   */
  private cache: {
    verificationContract?: SignVerification;
    thresholdHistory?: VerificationThreshold[];
  };
  private sugar: DiamondGovernanceSugar;
  private signer: Signer;

  constructor(sugar: DiamondGovernanceSugar, signer: Signer) {
    this.sugar = sugar;
    this.signer = signer;
    this.cache = {};
  }

  /**
   * Gets the verification contract object
   * @returns The verification contract object
   */
  public async GetVerificationContract(): Promise<SignVerification> {
    if (this.cache.verificationContract == null) {
      const verificationContractAddress = await this.sugar.GetVerificationContractAddress();
      this.cache.verificationContract = await GetTypedContractAt<SignVerification>("SignVerification", verificationContractAddress, this.signer);
    }
    return this.cache.verificationContract;
  }

  /**
   * Retrieve the stamps of a given address
   * @param address The address to retrieve stamps for
   * @returns An array of Stamp objects
   */
  public async GetStamps(address: string): Promise<Stamp[]> {
    const verificationContract = await this.GetVerificationContract();
    // return verificationContract.getStamps(address);
    const provider = this.signer.provider;
    if (provider == null) {
      throw new Error("No provider found");
    }
    // Convert every block number to a timestamp

    const stamps = await verificationContract.getStamps(address);

    return asyncMap(stamps, async (stamp) => {
      stamp[2] = await asyncMap(stamp[2], async (blockNumber) => {
        return await this.blockNumberToTimestamp(provider, blockNumber);
      });
      return stamp;
    });
  }

  /**
   * Gets the threshold history
   * @returns The threshold history as an array of VerificationThreshold objects
   */
  public async GetThresholdHistory(): Promise<VerificationThreshold[]> {
    if (this.cache.thresholdHistory == null) {
      const verificationContract = await this.GetVerificationContract();
      const thresholdHistory = await verificationContract.getThresholdHistory();

      const provider = this.signer.provider;
      if (provider == null) {
        throw new Error("No provider found");
      }
      this.cache.thresholdHistory = await asyncMap(thresholdHistory, async (threshold) => {
        threshold[0] = await this.blockNumberToTimestamp(provider, threshold[1]);
        return threshold;
      });
    }
    return this.cache.thresholdHistory;
  }

  /**
   * Gets expiration info for the given stamp
   * @param stamp The stamp to get expiration info for
   * @returns An object containing expiration info
   */
  public async GetExpiration(stamp: Stamp): Promise<{
    verified: boolean;
    expired: boolean;
    blocksLeftUntilExpiration: number | null;
    threshold: BigNumber;
  }> {
    const provider = this.signer.provider;
    if (provider == null) {
      throw new Error("No provider found");
    }

    const currentBlockNumber = await provider.getBlockNumber();

    const lastVerifiedAt = stamp
      ? stamp[2][stamp[2].length - 1]
      : BigNumber.from(0);

    // Retrieve the threshold history, and the threshold for the current blockNumber
    const thresholdHistory = await this.GetThresholdHistory();
    const threshold = this.getThresholdForBlockNumber(
      lastVerifiedAt.toNumber(),
      thresholdHistory
    );

    // Checks conditions that always need to hold
    const preCondition: boolean =
      stamp != null &&
      stamp[2] != null &&
      stamp[2].length > 0 &&
      thresholdHistory != null &&
      thresholdHistory.length > 0; 

    const expirationBlock = lastVerifiedAt
      .add(threshold)
      .toNumber();

    const verified =
      preCondition && stamp != null && currentBlockNumber < expirationBlock;

    const expired =
      preCondition && stamp != null && currentBlockNumber > expirationBlock;

    let blocksLeftUntilExpiration = null;
    if (verified) {
      blocksLeftUntilExpiration = expirationBlock - currentBlockNumber;
    }

    return {
      verified,
      expired,
      blocksLeftUntilExpiration,
      threshold,
    };
  }

  /**
   * Verifies the current user
   * @param toVerify The address to verify
   * @param userHash The user hash
   * @param timestamp The timestamp in seconds
   * @param providerId The provider ID (github, proofofhumanity, etc.)
   * @param proofSignature The signature that you receive from the verification back-end
   * @return Transaction of the object
   */
  public async Verify(
    toVerify: string,
    userHash: string,
    timestamp: number,
    providerId: string,
    proofSignature: string
  ): Promise<ContractTransaction> {
    const verificationContract = await this.GetVerificationContract();
    return await verificationContract.verifyAddress(
      toVerify,
      userHash,
      timestamp,
      providerId,
      proofSignature
    );
  }

  /**
   * Unverifies the current user
   * @param providerId The provider ID (github, proofofhumanity, etc.)
   */
  public async Unverify(providerId: string): Promise<ContractTransaction> {
    const verificationContract = await this.GetVerificationContract();
    return await verificationContract.unverify(providerId);
  }

  /**
   * Gets the reverify threshold (number of blocks until a user can reverify)
   * @returns The reverify threshold in blocks
   */
  public async GetReverifyThreshold(): Promise<BigNumber> {
    const verificationContract = await this.GetVerificationContract();
    return await verificationContract.getReverifyThreshold();
  }

  /**
   * Gets the threshold for a given block number
   * @param blockNumber The block number in seconds
   * @param thresholdHistory The threshold history
   * @returns The threshold at the given block number
   */
  private getThresholdForBlockNumber(
    blockNumber: number,
    thresholdHistory: VerificationThreshold[]
  ) : BigNumber {
    let threshold = thresholdHistory.reverse().find((threshold) => {
      return blockNumber >= threshold[0].toNumber();
    });

    return threshold ? threshold[1] : BigNumber.from(0);
  }

  private async blockNumberToTimestamp(
    provider: providers.Provider,
    blockNumber: BigNumber
  ) : Promise<BigNumber> {
    return BigNumber.from((await provider.getBlock(blockNumber.toNumber())).timestamp);
  }

}
