// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.30;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// 1. ERC20 Implementation Contract
contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        // Mint tokens to the deployer
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }
}

contract PropertyManagement{
    IERC20 public token;

    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    error NOT_THE_OWNER();
    // address owner;
    struct Property{
        uint256 propertyId;
        string name;
        string desc;
        string location;
        address propertyOwner;
        uint256 price;
    }
    mapping(uint256 => Property) public properties;

    Property[] public allProperties;

    uint256 public property_id;

    modifier onlyPropertyOwner(uint256 _propertyId){
         if ( properties[_propertyId].propertyOwner != msg.sender) {
            revert NOT_THE_OWNER();
        }
        _;
    }
   
    function createProperty(string memory _name, string memory _desc, string memory _location, uint256 _price) external{
        property_id = property_id + 1;
        Property memory property = Property({propertyId:property_id, name: _name,desc: _desc, location: _location, propertyOwner: msg.sender, price:_price});
        allProperties.push(property);
    }

    function removeProperty(uint256 _propertyId) external onlyPropertyOwner(_propertyId){
        for (uint8 i; i < allProperties.length; i++) {
            if (allProperties[i].propertyId == _propertyId) {
                allProperties[i] = allProperties[allProperties.length - 1];
                allProperties.pop();
            }
        }
    }

    function getAllProperties() external view returns(Property[] memory){
        return allProperties;
    }

    function buyProperty(uint256 _propertyId) external {
        require(properties[_propertyId].propertyId != _propertyId, "Not available");

        uint256 amount = properties[_propertyId].price;
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
    }
}


