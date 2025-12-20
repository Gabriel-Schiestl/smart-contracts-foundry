// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {BasicNft} from "../src/BasicNft.sol";
import {DeployBasicNft} from "../script/DeployBasicNft.s.sol";

contract BasicNftTest is Test {
    BasicNft basicNft;
    DeployBasicNft deployer;

    address public USER = makeAddr("user");
    string constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    function setUp() external {
        deployer = new DeployBasicNft();
        basicNft = deployer.run();
    }

    function testNameIsCorrect() public {
        string memory name = basicNft.name();
        string memory expectedName = "Dogie";
        assertEq(name, expectedName); // Behind the scenes, assertEq compares the hashed values(string is a byte array)
        // bytes memory encodedName = abi.encodePacked(name); => transform string to bytes(dynamic bytes)
        // bytes32 hashedName = keccak256(encodedName); => hash the bytes(bytes32)
        // bytes memory encodedExpectedName = abi.encodePacked(expectedName);
        // bytes32 hashedExpectedName = keccak256(encodedExpectedName);
        // assert(hashedName == hashedExpectedName);
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        basicNft.mintNft(TOKEN_URI);

        assertEq(basicNft.balanceOf(USER), 1);
        assertEq(basicNft.tokenURI(0), TOKEN_URI);
    }
}
