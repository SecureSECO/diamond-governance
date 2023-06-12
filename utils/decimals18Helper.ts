import { BigNumber } from "ethers";

/**
 * Convert any (decimal) number to 18 decimals
 * @remarks This function can only take numbers in the format of "123.456" (note the dot and no spaces).
 * @param value The number to convert to 18 decimals (as a string)
 * @returns The corresponding BigNumber in 18 decimals
 */
export const to18Decimal = (value: string): BigNumber => {
  const valueAsNumber = Number(value);
  if (valueAsNumber < 0)
    throw new Error("Cannot convert negative number to 18 decimals");

  const valueRounded18 = BigNumber.from(Math.floor(valueAsNumber)).mul(BigNumber.from(10).pow(18));

  if (Math.floor(valueAsNumber) === valueAsNumber) {
    return valueRounded18;
  } else {
    const afterTheComma = value.split(".")[1];
    // pad with zeros
    const afterTheCommaPadded = afterTheComma.padEnd(18, "0").substring(0, 18);

    return valueRounded18.add(BigNumber.from(afterTheCommaPadded));
  }
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

export const DECIMALS_18 = to18Decimal("1");
