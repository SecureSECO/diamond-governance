import { BigNumber } from "ethers";

/**
 * Convert any (decimal) number to 18 decimals
 * @param amount The number to convert to 18 decimals
 * @returns The corresponding BigNumber in 18 decimals
 */
export const to18Decimal = (amount: number): BigNumber => {
  const { amount: newAmount, exponent } = tenFoldUntilLimit(amount);

  return BigNumber.from(newAmount).mul(BigNumber.from(10).pow(18 - exponent));
};

/**
 * Multiply a number by 10 until it reaches the maximum safe integer
 * @param amount The number to multiply
 * @returns The multiplied number and the exponent
 */
export const tenFoldUntilLimit = (
  amount: number
): { amount: number; exponent: number } => {
  let i = 0;
  for (; i < 18; i++) {
    if (Number.MAX_SAFE_INTEGER / 10 < amount) {
      break;
    }
    amount *= 10;
  }

  return { amount: Math.round(amount), exponent: i };
};

export const DECIMALS_18 = to18Decimal(1);