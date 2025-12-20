// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";
import {DeployMyToken} from "../script/DeployMyToken.s.sol";

contract MyTokenTest is Test {
    MyToken myToken;
    DeployMyToken deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() external {
        deployer = new DeployMyToken();
        myToken = deployer.run();

        vm.prank(msg.sender);
        myToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;
        vm.prank(bob);
        myToken.approve(alice, initialAllowance); // Bob approves Alice to spend 1000 tokens on his behalf

        uint256 transferAmount = 500;

        vm.prank(alice);
        myToken.transferFrom(bob, alice, transferAmount); // Alice transfers 1000 tokens from Bob to herself

        assertEq(myToken.balanceOf(alice), transferAmount);
        assertEq(
            myToken.allowance(bob, alice),
            STARTING_BALANCE - transferAmount
        );
    }

    /* Additional tests following the same style as above */

    function testTokenMetadataAndSupply() public {
        assertEq(myToken.name(), "MyToken");
        assertEq(myToken.symbol(), "MTK");
        assertEq(myToken.decimals(), 18);

        // totalSupply should equal sum of all balances we can observe
        uint256 total = myToken.totalSupply();
        assertEq(
            total,
            myToken.balanceOf(bob) + myToken.balanceOf(address(this))
        );
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    function testTransferEmitsEvent() public {
        uint256 amt = 1 ether;
        vm.prank(bob);
        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, amt);
        myToken.transfer(alice, amt);
    }

    function testIncreaseAndDecreaseAllowance() public {
        vm.prank(bob);
        myToken.approve(alice, 10);

        // OpenZeppelin version in this repo doesn't expose increase/decrease helpers;
        // emulate increaseAllowance by reading current allowance and approving the new amount.
        vm.prank(bob);
        myToken.approve(alice, 15); // increase from 10 to 15
        assertEq(myToken.allowance(bob, alice), 15);

        vm.prank(bob);
        myToken.approve(alice, 11); // decrease from 15 to 11
        assertEq(myToken.allowance(bob, alice), 11);
    }

    function testTransferFromExceedingAllowanceReverts() public {
        vm.prank(bob);
        myToken.approve(alice, 5);

        vm.prank(alice);
        vm.expectRevert(bytes("ERC20: insufficient allowance"));
        myToken.transferFrom(bob, alice, 6);
    }

    function testTransferToZeroAddressReverts() public {
        vm.prank(bob);
        vm.expectRevert(bytes("ERC20: transfer to the zero address"));
        myToken.transfer(address(0), 1);
    }
}
