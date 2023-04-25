/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { ProposalMetadata } from "./data";
const sep = "#@$!"


// This should upload and download from IPFS in the future
export async function EncodeMetadata(metadata : ProposalMetadata) : Promise<Uint8Array> {
    let resources = "";
    metadata.resources.forEach(r => resources += sep + r.name + sep + r.url);

    const encoded = metadata.title + sep + metadata.description + sep + metadata.body + resources;
    return new TextEncoder().encode(encoded);
}

export async function DecodeMetadata(metadata : Uint8Array) : Promise<ProposalMetadata> {
    const decoded = new TextDecoder().decode(metadata);
    const split = decoded.split(sep);

    let resources = [];
    for (let i = 3; i < split.length; i+=2) {
        resources.push({
            name: split[i],
            url: split[i+1]
        });
    }

    return {
        title: split[0],
        description: split[1],
        body: split[2],
        resources: resources
    };
}