# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.ts
```
  address public owner;
    uint256 public totalEther;
    uint256 public totalTokens;

    constructor(){
        owner = msg.sender;
    }

    function saveEther() external payable {
        require(msg.value > 0, "Send some ether");
        totalEther = totalEther + msg.value;
    }

    function saveToken(uint256 _amount) external {
        require(_amount > 0, "Send some tokens");
        totalTokens = totalTokens + _amount;
    }
