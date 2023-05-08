import { ethers } from "ethers";
import { GithubVerification } from "../../typechain-types";
import { DiamondGovernanceSugar, Stamp, VerificationThreshold } from "./sugar";
import { BigNumber } from "ethers";
import { Signer } from "@ethersproject/abstract-signer";
import { verificationContractAbi } from "./abi/verificationContractAbi";

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
    verificationContract?: GithubVerification;
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
  public async GetVerificationContract(): Promise<GithubVerification> {
    if (this.cache.verificationContract == null) {
      const verificationContractAddress =
        await this.sugar.GetVerificationContractAddress();
      this.cache.verificationContract = new ethers.Contract(
        verificationContractAddress,
        verificationContractAbi,
        this.signer
      ) as GithubVerification;
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
    return verificationContract.getStamps(address);
  }

  /**
   * Gets the threshold history
   * @returns The threshold history as an array of VerificationThreshold objects
   */
  public async GetThresholdHistory(): Promise<VerificationThreshold[]> {
    if (this.cache.thresholdHistory == null) {
      const verificationContract = await this.GetVerificationContract();
      this.cache.thresholdHistory =
        await verificationContract.getThresholdHistory();
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
    timeLeftUntilExpiration: number | null;
    threshold: BigNumber;
  }> {
    const currentTimestamp = Math.round(Date.now() / 1000);

    const lastVerifiedAt = stamp
      ? stamp[2][stamp[2].length - 1]
      : BigNumber.from(0);

    // Retrieve the threshold history, and the threshold for the current timestamp
    const thresholdHistory = await this.GetThresholdHistory();
    const threshold = this.getThresholdForTimestamp(
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

    const expirationDate = lastVerifiedAt
      .add(threshold.mul(24 * 60 * 60))
      .toNumber();

    const verified =
      preCondition && stamp != null && currentTimestamp < expirationDate;

    const expired =
      preCondition && stamp != null && currentTimestamp > expirationDate;

    let timeLeftUntilExpiration = null;
    if (verified) {
      timeLeftUntilExpiration = expirationDate - currentTimestamp;
    }

    return {
      verified,
      expired,
      timeLeftUntilExpiration,
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
   */
  public async Verify(
    toVerify: string,
    userHash: string,
    timestamp: number,
    providerId: string,
    proofSignature: string
  ): Promise<void> {
    const verificationContract = await this.GetVerificationContract();
    await verificationContract.verifyAddress(
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
  public async Unverify(providerId: string): Promise<void> {
    const verificationContract = await this.GetVerificationContract();
    await verificationContract.unverify(providerId);
  }

  /**
   * Gets the threshold for a given timestamp
   * @param timestamp The timestamp in seconds
   * @param thresholdHistory The threshold history
   * @returns The threshold at the given timestamp
   */
  private getThresholdForTimestamp(
    timestamp: number,
    thresholdHistory: VerificationThreshold[]
  ) {
    let threshold = thresholdHistory.reverse().find((threshold) => {
      return timestamp >= threshold[0].toNumber();
    });

    return threshold ? threshold[1] : BigNumber.from(0);
  }
}
