// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {IERC20} from "./IERC20.sol";
// Write a smart contract that can save both ERC20 and ether for a user.

// Users must be able to:
// check individual balances,
// deposit or save in the contract.
// withdraw their savings

contract SaveAsset{
    address token;

    mapping(address => uint256) public etherBalances;
    mapping(address => uint256) public tokenBalances;

    event DepositSuccessful(address indexed sender, uint256 indexed amount);

    event WithdrawalSuccessful(address indexed receiver, uint256 indexed amount, bytes data);

    constructor(address _token){
        token = _token;
    }

    function depositEther() external payable {
        require(msg.value > 0, "Can't deposit zero value");
        etherBalances[msg.sender] = etherBalances[msg.sender] + msg.value;
        emit DepositSuccessful(msg.sender, msg.value);
    }

    function withdrawEther(uint256 _amount) external {
        require(msg.sender != address(0), "Address zero detected");

        uint256 userSavings_ = etherBalances[msg.sender];

        require(userSavings_ > 0, "Insufficient funds");

        etherBalances[msg.sender] = userSavings_ - _amount;

        (bool result, bytes memory data) = payable(msg.sender).call{value: _amount}("");

        require(result, "transfer failed");

        emit WithdrawalSuccessful(msg.sender, _amount, data);
    }

        function getUserEherSavings() external view returns (uint256) {
        return etherBalances[msg.sender];
    }

    function depositToken(uint256 _amount) external {
        require(_amount > 0, "Can't deposit zero value");

        require(IERC20(token).balanceOf(msg.sender) >= _amount, "Insufficient funds");

        tokenBalances[msg.sender] = tokenBalances[msg.sender] + _amount;

        bool result = IERC20(token).transferFrom(msg.sender, address(this), _amount);

        require(result, "transfer failed");

        emit DepositSuccessful(msg.sender, _amount);
    }

    function withdrawToken(uint256 _amount) external {
        require(msg.sender != address(0), "Address zero detected");

        uint256 userSavings_ = tokenBalances[msg.sender];

        require(userSavings_ >= _amount, "Insufficient funds");

        tokenBalances[msg.sender] = userSavings_ - _amount;

        bool result = IERC20(token).transfer(msg.sender, _amount);

        require(result, "transfer failed");

        emit WithdrawalSuccessful(msg.sender, _amount, "");
    }

    function getTokenBalance() external view returns (uint256) {
        return tokenBalances[msg.sender];
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}