// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

library AddName{
    function add(string memory _firstName, string memory _lastName) internal pure returns(string memory){
        return string.concat(_firstName, " ", _lastName);
    }
}

contract FullName{
    using AddName for string;
    function fullName(string memory _firstName, string memory _lastName) external pure returns(string memory){
        return _firstName.add(_lastName);
    }
}