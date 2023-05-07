/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { ProposalMetadata } from "./data";
import { addToIpfs, getFromIpfs } from "../../../utils/ipfsHelper";

export async function EncodeMetadata(metadata : ProposalMetadata) : Promise<Uint8Array> {
    const cid = await addToIpfs(JSON.stringify(metadata));
    return new TextEncoder().encode("ipfs://" + cid);
}

export async function DecodeMetadata(metadata : Uint8Array) : Promise<ProposalMetadata> {
    const decoded = new TextDecoder().decode(metadata);
    const cid = decoded.replace("ipfs://", "");
    return JSON.parse(await getFromIpfs(cid));
}