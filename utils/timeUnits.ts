/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

// Various time units per Solidity spec

export const seconds = 1;
export const minutes = 60 * seconds;
export const hours = 60 * minutes;
export const days = 24 * hours;
export const week = 7 * days;
export function now() { return Math.round(new Date().getTime() / 1000) };