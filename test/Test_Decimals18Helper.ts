import {to18Decimal} from "../utils/decimals18Helper";
import { expect } from "chai";

describe("Decimals 18 helper", async () => {
  it("should convert a number to 18 decimals", async () => {
    expect(to18Decimal("1.234").toString()).to.equal(                        "1234000000000000000");
    expect(to18Decimal("1.23456789").toString()).to.equal(                   "1234567890000000000");
    expect(to18Decimal("1.23456789123456789").toString()).to.equal(          "1234567891234567890");
    expect(to18Decimal("1.23456789123456789123456789").toString()).to.equal( "1234567891234567891");
    expect(to18Decimal("12345.6789123456789123456789").toString()).to.equal( "12345678912345678912345");
  });
});