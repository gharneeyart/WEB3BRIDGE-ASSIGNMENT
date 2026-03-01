// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MultiSigWallet {
    // Owners of the wallet
    address[] public owners;
    // Required confirmations for a transaction
    uint public requiredConfirmations;
    // Mapping of owners to their confirmation status
    mapping(address => bool) public isOwner;
    // List of transactions
    Transaction[] public transactions;
    // 2D mapping to store confirmation status
    mapping(uint => mapping(address => bool)) public confirmations;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        // uint confirmationsCount;
    }

    // Events
    event Deposit(address indexed sender, uint value);
    event SubmitTransaction(address indexed owner, uint indexed txIndex);
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeTransaction(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    modifier onlyOwner(){
        require(isOwner[msg.sender], "not an owner");
        _;
    }

    modifier txExists(uint _txId){
        require(_txId < transactions.length, "tx does not exist");
        _;
    }

    modifier notApproved(uint _txId){
        require(!confirmations[_txId][msg.sender], "Transaction already confirmed by owner");
        _;
    }

    modifier notExecuted(uint _txId){
        require(!transactions[_txId].executed, "Transaction already executed");
        _;
    }

    // Constructor
    constructor(address[] memory _owners, uint8 _requiredConfirmations) {
        require(_owners.length > 0, "At least one owner required");
        require(_requiredConfirmations > 0, "At least one confirmation required");
        require( _requiredConfirmations <= _owners.length, "More owners than required confirmations");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner address");
            require(!isOwner[owner], "Owner is not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
        // owners = _owners;
        requiredConfirmations = _requiredConfirmations;
    }

    // Deposit ETH into the wallet
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // Submit a new transaction
    function submitTransaction(address _to, uint _value, bytes calldata _data) external onlyOwner {
        // require(isOwner[msg.sender], "Only owners can submit transactions");
        transactions.push(Transaction(_to, _value, _data, false));
        uint txIndex = transactions.length - 1;
        
        emit SubmitTransaction(msg.sender, txIndex);
        // confirmTransaction(txIndex);
    }

    // Confirm a transaction
    function confirmTransaction(uint _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId){
        // require(isOwner[msg.sender], "Only owners can confirm transactions");
        // require(!transactions[_txIndex].executed, "Transaction already executed");
        // require(!confirmations[_txIndex][msg.sender], "Transaction already confirmed by owner");
        confirmations[_txId][msg.sender] = true;
        // transactions[_txIndex].confirmationsCount++;
        emit ConfirmTransaction(msg.sender, _txId);
        // if (transactions[_txIndex].confirmationsCount >= requiredConfirmations) {
        //     executeTransaction(_txIndex);
        // }
    }

    function _getConfirmationCount(uint _txId) private view returns(uint count){
        for(uint i; i < owners.length; i++){
            if(confirmations[_txId][owners[i]]){
                count += 1;
            }
        }
    }

    // Execute a confirmed transaction
    function executeTransaction(uint _txId) external txExists(_txId) notExecuted(_txId) {
        require(_getConfirmationCount(_txId) >= requiredConfirmations, "confirmations < required");
        Transaction storage transaction = transactions[_txId];

        transaction.executed = true;
        // require(!tx.executed, "Transaction already executed");
        (bool success, ) = payable(transaction.to).call{value: transaction.value}(transaction.data);
        require(success, "Transaction execution failed");
        
        emit ExecuteTransaction(msg.sender, _txId);
    }

    function revokeTransaction(uint _txId) external onlyOwner() txExists(_txId) notExecuted(_txId){
        require(confirmations[_txId][msg.sender], "Transaction not confirmed");
        confirmations[_txId][msg.sender] = false;
        emit RevokeTransaction(msg.sender, _txId);
    }
}