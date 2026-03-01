// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract ERC20{
    string public token_name;
    string public token_symbol;
    uint8 public token_decimals;
    uint256 public token_totalSupply;

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) public _allowances;


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply){
        token_name = _name;
        token_symbol = _symbol;
        token_decimals = _decimals;
        token_totalSupply = _totalSupply;
        _balances[msg.sender] = _totalSupply;
    }

    function name() external view returns(string memory){
        return token_name;
    }

    function symbol() external view returns(string memory){
        return token_symbol;
    }

    function decimals() external view returns(uint8){
        return token_decimals;
    }

    function totalSupply() external view returns(uint256){
        return token_totalSupply;
    }

    function balanceOf(address _owner) external view returns (uint256 balance){
        require(_owner != address(0), "!ZA");
        return _balances[_owner];
    }

    function transfer(address _to, uint256 _value) external returns (bool){
        require(_to != address(0), "!ZA");

        require((_balances[msg.sender] >= _value) &&  (_balances[msg.sender] > 0), "Not enough balance");

        _balances[msg.sender] = _balances[msg.sender] - _value;

        _balances[_to] = _balances[_to] + _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool){
        require(_to != address(0), "!ZA");

        require(_allowances[_from][msg.sender] >= _value, "!AL");

        require((_balances[_from] >= _value) && (_balances[_from] > 0), "Not enough balance");

        _balances[_from] = _balances[_from] - _value;

        _balances[_to] = _balances[_to] + _value;

        _allowances[_from][msg.sender] = _allowances[_from][msg.sender] - _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool){
        require(_spender != address(0), "Can't transfer to address zero");

        require(_value > 0, "Can't send zero value");

        require(_balances[msg.sender] >= _value, "!Bal");

        _allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint256){
        return _allowances[_owner][_spender];
    }

    function mint(address _owner, uint256 _amount) external {
        token_totalSupply = token_totalSupply + _amount;
        _balances[_owner] = _balances[_owner] + _amount;
        emit Transfer(address(0), msg.sender, _amount);
    }

}
