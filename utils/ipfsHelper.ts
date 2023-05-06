import { IPFS_PINATA_TOKEN } from "../secrets";
import axios from "axios";

/** Upload a file to the cluster and pin it */
export async function addToIpfs(json: string): Promise<string> {
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