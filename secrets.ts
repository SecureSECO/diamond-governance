/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

export function ETHERSCAN_API_KEY() {
    const fromEnv = process.env.ETHERSCAN_API_KEY;
    if (fromEnv === undefined) { return "NO_ETHERSCAN_API_KEY_FOUND"; }
    return fromEnv;
}

export function POLYGONSCAN_API_KEY() {
    const fromEnv = process.env.POLYGONSCAN_API_KEY;
    if (fromEnv === undefined) { return "NO_POLYGONSCAN_API_KEY_FOUND"; }
    return fromEnv;
}

export function POLYGON_PRIVATE_KEY() {
    const fromEnv = process.env.POLYGON_PRIVATE_KEY;
    if (fromEnv === undefined) { return "0000000000000000000000000000000000000000000000000000000000000000"; }
    return fromEnv;
}

export function MUMBAI_PRIVATE_KEY() {
    const fromEnv = process.env.MUMBAI_PRIVATE_KEY;
    if (fromEnv === undefined) { return "0000000000000000000000000000000000000000000000000000000000000000"; }
    return fromEnv;
}