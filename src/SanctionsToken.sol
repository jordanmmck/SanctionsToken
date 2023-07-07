// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title A token with sanctions
/// @author Jordan McKinney
/// @notice ERC20 token with a blacklist of addresses that cannot send or receive tokens
/// @dev only admin can add or remove addresses from the blacklist
contract SanctionsToken is ERC20 {
    mapping(address => bool) public blacklist;
    address public admin;

    constructor() ERC20("SanctionsToken", "STX") {
        admin = msg.sender;
        this; // do i need this?
    }

    // not sure how to set balances to non-zero without this f'n...
    function mint(address to, uint256 amount) external {
        require(msg.sender == admin, "only admin");
        _mint(to, amount);
    }

    function addToBlacklist(address _addr) external {
        require(msg.sender == admin, "only admin");
        blacklist[_addr] = true;
    }

    function removeFromBlacklist(address _addr) external {
        require(msg.sender == admin, "only admin");
        blacklist[_addr] = false;
    }

    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(!blacklist[msg.sender], "sender is blacklisted");
        require(!blacklist[to], "recipient is blacklisted");
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        require(!blacklist[from], "sender is blacklisted");
        require(!blacklist[to], "recipient is blacklisted");
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
}
