// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
// Write a smart contract that can save both ERC20 and ether for a user.

// Users must be able to:
// check individual balances,
// deposit or save in the contract.
// withdraw their savings

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}

contract SaveEtherandToken{
    mapping(address => uint256) public etherBalances;
    mapping(address => mapping(address => uint256)) public tokenBalances;

    event DepositEther(address indexed user, uint256 amount);
    event WithdrawEther(address indexed user, uint256 amount, bytes data);
    event DepositToken(address indexed token, address indexed user, uint256 amount);
    event WithdrawToken(address indexed token, address indexed user, uint256 amount);

    function depositEther() external payable {
        require(msg.value > 0, "Can't deposit zero value");
        etherBalances[msg.sender] = etherBalances[msg.sender] + msg.value;
        emit DepositEther(msg.sender, msg.value);
    }
    function withdrawEther(uint256 _amount) external {
        require(msg.sender != address(0), "Address zero detected");
        uint256 userSavings_ = etherBalances[msg.sender];
        require(userSavings_ > 0, "Insufficient funds");
        etherBalances[msg.sender] = userSavings_ - _amount;
        (bool result, bytes memory data) = payable(msg.sender).call{value: _amount}("");
        require(result, "transfer failed");
        emit WithdrawEther(msg.sender, _amount, data);
    }

    function depositToken(address _token, uint256 _amount) external {
        require(_amount > 0, "Can't deposit zero value");
        tokenBalances[msg.sender] = tokenBalances[msg.sender] + _amount;
        emit DepositToken(_token, msg.sender, _amount);
    }

    function withdrawToken(address _token, uint256 _amount) external {
        require(msg.sender != address(0), "Address zero detected");
        uint256 userSavings_ = tokenBalances[msg.sender];
        require(userSavings_ > 0, "Insufficient funds");
        tokenBalances[msg.sender] = userSavings_ - _amount;
        bool result = IERC20(_token).transfer(msg.sender, _amount);
        require(result, "transfer failed");
        emit WithdrawToken(_token, msg.sender, _amount);
    }
}