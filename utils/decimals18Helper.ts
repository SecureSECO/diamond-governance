import { BigNumber } from "ethers";

export const to18Decimal = (amount: number): BigNumber => {
  const { amount: newAmount, exponent } = tenFoldUntilLimit(amount);

  return BigNumber.from(newAmount).mul(BigNumber.from(10).pow(18 - exponent));
};

export const tenFoldUntilLimit = (
  amount: number
): { amount: number; exponent: number } => {
  let i = 0;
  for (; i <= 18; i++) {
    if (Number.MAX_SAFE_INTEGER / 10 < amount) {
      break;
    }
    amount *= 10;
  }

  return { amount: Math.round(amount), exponent: i };
};

export const DECIMALS_18 = to18Decimal(1);