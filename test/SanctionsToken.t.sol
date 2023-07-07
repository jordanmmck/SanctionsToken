// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SanctionsToken.sol";

contract SanctionsTokenTest is Test {
    SanctionsToken public sanctionsToken;
    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        // ensure admin is set to msg.sender
        vm.prank(address(0));
        sanctionsToken = new SanctionsToken();

        vm.prank(address(0));
        sanctionsToken.mint(alice, 1e18);
    }

    function testAddToBlacklist() public {
        address addr = address(0x1);
        vm.prank(address(0));
        sanctionsToken.addToBlacklist(addr);
        assertEq(sanctionsToken.blacklist(addr), true);
    }

    function testAddToBlacklistFail() public {
        address addr = address(0x1);
        vm.prank(address(123));
        vm.expectRevert();
        sanctionsToken.addToBlacklist(addr);
    }

    function testRemoveFromBlacklist() public {
        address addr = address(0x1);
        vm.prank(address(0));
        sanctionsToken.addToBlacklist(addr);
        assertEq(sanctionsToken.blacklist(addr), true);
        vm.prank(address(0));
        sanctionsToken.removeFromBlacklist(addr);
        assertEq(sanctionsToken.blacklist(addr), false);
    }

    function testRemoveFromBlacklistFail() public {
        address addr = address(0x1);
        vm.prank(address(0));
        sanctionsToken.addToBlacklist(addr);
        assertEq(sanctionsToken.blacklist(addr), true);
        vm.prank(address(0x99));
        vm.expectRevert();
        sanctionsToken.removeFromBlacklist(addr);
    }

    function testTransfer() public {
        vm.prank(alice);
        sanctionsToken.transfer(bob, 0.5e18);

        uint256 aliceBalance = sanctionsToken.balanceOf(alice);
        assertEq(aliceBalance, 1e18 - 0.5e18);
        uint256 bobBalance = sanctionsToken.balanceOf(bob);
        assertEq(bobBalance, 0.5e18);
    }

    function testTransferToBlacklist() public {
        vm.prank(address(0));
        sanctionsToken.addToBlacklist(bob);

        vm.expectRevert();
        vm.prank(alice);
        sanctionsToken.transfer(bob, 0.5e18);
    }

    function testTransferFromBlacklist() public {
        vm.prank(address(0));
        sanctionsToken.addToBlacklist(alice);

        vm.expectRevert();
        vm.prank(alice);
        sanctionsToken.transfer(bob, 0.5e18);
    }
}
