// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/SanctionsToken.sol";

contract SanctionsTokenTest is Test {
    SanctionsToken public sanctionsToken;
    address public constant ALICE = address(0x1);
    address public constant BOB = address(0x2);

    function setUp() public {
        // ensure admin is set to msg.sender
        vm.prank(address(0));
        sanctionsToken = new SanctionsToken();

        vm.prank(address(0));
        sanctionsToken.mint(ALICE, 1e18);
    }

    function testMintSuccess() public {
        vm.prank(address(0));
        sanctionsToken.mint(BOB, 1e18);
        assertEq(sanctionsToken.balanceOf(BOB), 1e18);
    }

    function testMintFail() public {
        vm.prank(address(0x99));
        vm.expectRevert();
        sanctionsToken.mint(BOB, 1e18);
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
        vm.prank(ALICE);
        sanctionsToken.transfer(BOB, 0.5e18);

        uint256 aliceBalance = sanctionsToken.balanceOf(ALICE);
        assertEq(aliceBalance, 1e18 - 0.5e18);
        uint256 bobBalance = sanctionsToken.balanceOf(BOB);
        assertEq(bobBalance, 0.5e18);
    }

    function testTransferToBlacklist() public {
        vm.prank(address(0));
        sanctionsToken.addToBlacklist(BOB);

        vm.expectRevert();
        vm.prank(ALICE);
        sanctionsToken.transfer(BOB, 0.5e18);
    }

    function testTransferFromBlacklist() public {
        vm.prank(address(0));
        sanctionsToken.addToBlacklist(ALICE);

        vm.expectRevert();
        vm.prank(ALICE);
        sanctionsToken.transfer(BOB, 0.5e18);
    }

    function testTransferFromToBlacklist() public {
        vm.prank(address(0));
        sanctionsToken.addToBlacklist(BOB);

        vm.expectRevert();
        vm.prank(ALICE);
        sanctionsToken.transferFrom(ALICE, BOB, 0.5e18);
    }

    function testTransferFromFromBlacklist() public {
        vm.prank(address(0));
        sanctionsToken.addToBlacklist(ALICE);

        vm.expectRevert();
        vm.prank(ALICE);
        sanctionsToken.transferFrom(ALICE, BOB, 0.5e18);
    }

    function testTransferFromSuccess() public {
        vm.prank(ALICE);
        sanctionsToken.increaseAllowance(BOB, 0.5e18);

        vm.prank(BOB);
        sanctionsToken.transferFrom(ALICE, BOB, 0.5e18);
    }
}
