// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
// Create a School management system where people can:
// Register students & Staffs.
// Pay School fees on registration using ERC20.
// Pay staffs also with ERC20.
// Get the students and their details.
// Get all Staffs.
// Pricing is based on grade / levels from 100 - 400 level.
// Payment status can be updated once the payment is made which should include the timestamp.


interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address _owner) public view returns (uint256);
}