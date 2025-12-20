// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract MintBasicNft is Script {
    string constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment(
            "BasicNft",
            block.chainid
        );
        BasicNft basicNft = BasicNft(mostRecentDeployed);
        minNftOnContract(mostRecentDeployed);
    }

    function minNftOnContract(address basicNftAddress) public {
        vm.startBroadcast();
        BasicNft basicNft = BasicNft(basicNftAddress);
        basicNft.mintNft(TOKEN_URI);
        vm.stopBroadcast();
    }
}
