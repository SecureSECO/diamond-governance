/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import axios from "axios";
import FormData from "form-data";

let ipfsAdd : ((json : string) => Promise<string>) | undefined = undefined;
let ipfsGet : ((hash : string) => Promise<any>) | undefined = undefined;

export function customIpfsAdd(customAdd: (json : string) => Promise<string>) {
  ipfsAdd = customAdd;
}

export function customIpfsGet(customGet: (hash : string) => Promise<any>) {
  ipfsGet = customGet;
}

/** Upload a file to the cluster and pin it */
export async function addToIpfs(json: string): Promise<string> {
    if (ipfsAdd != undefined) {
      return ipfsAdd(json);
    }

    let data = new FormData();
    data.append("path", json);

    const config = {
      method: "POST",
      url: "https://ipfs-0.aragon.network/api/v0/add",
      headers: {
        "X-API-KEY": "b477RhECf8s8sdM7XrkLBs2wHc4kCMwpbcFC55Kt" // Publicly known Aragon IPFS node API key
      },
      data: data
    };
    
    const res = await axios(config);
    return res.data.Hash;
}

export async function getFromIpfs(hash: string): Promise<any> {
  if (ipfsGet != undefined) {
    return ipfsGet(hash);
  }
  
  const config = {
    method: "POST",
    url: "https://ipfs-0.aragon.network/api/v0/cat?arg=" + hash,
    headers: {
      "X-API-KEY": "b477RhECf8s8sdM7XrkLBs2wHc4kCMwpbcFC55Kt" // Publicly known Aragon IPFS node API key
    },
  };
  
  const res = await axios(config);
  return res.data;
}