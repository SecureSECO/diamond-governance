/**
  * This program has been developed by students from the bachelor Computer Science at Utrecht University within the Software Project course.
  * © Copyright Utrecht University (Department of Information and Computing Sciences)
  *
  * This source code is licensed under the MIT license found in the
  * LICENSE file in the root directory of this source tree.
  */

import { IPFS_PINATA_TOKEN } from "../secrets";
import axios from "axios";

/** Upload a file to the cluster and pin it */
export async function addToIpfs(json: string): Promise<string> {
    // const config = {
    //   method: "POST",
    //   url: "https://ipfs-0.aragon.network/api/v0/add",
    //   headers: {
    //     "Content-Type": "text/plain", // Incorrect
    //     "X-API-KEY": "b477RhECf8s8sdM7XrkLBs2wHc4kCMwpbcFC55Kt" // Publicly known Aragon IPFS node API key
    //   },
    //   params: {
    //     "path": json
    //   },
    // };
    
    // const res = await axios(config);
    // console.log(res.data);
    
    const config = {
      method: "POST",
      url: "https://api.pinata.cloud/pinning/pinJSONToIPFS",
      headers: { 
        "Content-Type": "application/json", 
        "Authorization": "Bearer " + IPFS_PINATA_TOKEN()
      },
      data: json
    };
    
    const res = await axios(config);
    return res.data.IpfsHash;
}

export async function getFromIpfs(hash: string): Promise<string> {
  const config = {
    method: "GET",
    url: "https://ipfs.io/ipfs/" + hash,
  };
  
  const res = await axios(config);
  return res.data;
}