// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract ERC20{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public _balances;
    // spender => (owner => no of tokens allowed)
    mapping(address => mapping(address => uint256)) public _allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply){
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        _balances[msg.sender] = _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance){
        require(_owner != address(0), "!ZA");
        return _balances[_owner]
    }

    function transfer(address _to, uint256 _value) public returns (bool){
        require(_to != address(0), "!ZA");
        require((_balances[msg.sender] >= _value) &&  (_balances[msg.sender] > 0), "Not enough balance");
        _balances[msg.sender] = _balances[msg.sender] - _value;
        _balances[_to] = _balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        require(_to != address(0), "!ZA");
        require(_allowances[msg.sender][_from] >= _value, "!AL");
        require((_balances[_from] >= _value) && (_balances[_from] > 0), "Not enough balance");
        _balances[_from] = _balances[_from] - _value;
        _balances[_to] = _balances[_to] + _value;
        _allowances[msg.sender][_from] = _allowances[msg.sender][_from] - _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool){
        require(_balances[msg.sender] >= _value, "!Bal");
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256){
        return _allowances[_spender][_owner];
    }

    function mint(uint256 _amount) public {
        _balances[msg.sender] = _balances[msg.sender] + _amount;
        totalSupply = totalSupply + _amount;
        emit Transfer(address(0), msg.sender, _amount);
    }

    function burn(uint256 _amount) public {
        _balances[msg.sender] = _balances[msg.sender] - _amount;
        totalSupply = totalSupply - _amount;
        emit Transfer(msg.sender, address(0), _amount);
    }

}