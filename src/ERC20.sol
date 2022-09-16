// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EIP712.sol";

contract ERC20 is EIP712 {
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address private owner;
    bool private _pause;

    bytes32 private constant PERMIT_HASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    mapping(address => uint256) _nonces;
    
    constructor (string memory _name_, string memory _symbol_) {
        owner = msg.sender;

        _name = _name_;
        _symbol = _symbol_;
        _decimals = 18;

        _totalSupply = 100 ether;
        balances[msg.sender] = 100 ether;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        address _owner = msg.sender;
        _transfer(_owner, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        uint256 currentAllowance = allowance(_from, msg.sender);
        require(currentAllowance >= _value, "ERC20: insufficient allowance");
        unchecked {
            _approve(_from, _to, currentAllowance - _value);
        }

        _transfer(_from, _to, _value);
        return true;
    }

    function _transfer(address _from, address _to, uint256 _value) internal virtual {
        require(!_pause, "ERC20: paused");

        require(msg.sender != address(0), "ERC20: transfer from the zero address sender");
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balances[_from] >= _value, "ERC20: value exceeds balance");

        unchecked {
            balances[_from] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(_from, _to, _value);
    }

    function approve(address _to, uint256 _value) public returns (bool success) {
        address from = msg.sender;
        _approve(from, _to, _value);
        return true;
    }

    function _approve(address _from, address _to, uint256 _value) private {
        require(msg.sender != address(0), "ERC20: approve from the zero address sender");
        require(_from != address(0), "ERC20: approve from the zero address");
        require(_to != address(0), "ERC20: approve to the zero address");

        _allowances[_from][_to] = _value;
        emit Approval(_from, _to, _value);
    }


    function allowance(address _from, address _to) public view returns (uint256 remaining) {
        require(msg.sender != address(0), "ERC20: allowance from the zero address sender");
        require(_from != address(0), "ERC20: allowance from the zero address");
        require(_to != address(0), "ERC20: allowance to the zero address");

        return _allowances[_from][_to];
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    function _mint(address account, uint256 value) public {
        require(msg.sender != address(0), "ERC20: mint from the zero address sender");
        require(account != address(0), "ERC20: mint from the zero address");
        require(_totalSupply + value <= type(uint256).max, "ERC20: value exceeds uint256 max");

        unchecked {
            _totalSupply += value;
            balances[account] += value;
        }

        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) public {
        require(msg.sender != address(0), "ERC20: burn from the zero address sender");
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 amount = balances[account];
        require(amount >= value, "ERC20: value exceeds balance");
        unchecked {
            balances[account] -= value;
            _totalSupply -= value;
        }

        emit Transfer(account, address(0), value);
    }

    // pause
    function pause() public {
        require(msg.sender == owner, "ERC20: not paused");
        _pause = true;
    }


    // permit
    function permit(address _owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(block.timestamp <= deadline, "ERC20: over deadline");

        uint256 n = _nonces[_owner];
        _nonces[_owner] += 1;

        bytes32 structHash = keccak256(abi.encode(PERMIT_HASH, _owner, spender, value, n, deadline));
        bytes32 hash = _toTypedDataHash(structHash);

        address signer = ecrecover(hash, v, r, s);
        require(signer == _owner, "INVALID_SIGNER");
        _approve(_owner, spender, value);
    }
    
    function nonces(address addr) public view returns (uint256) {
        return _nonces[addr];
    }


}