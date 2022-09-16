//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EIP712 {

    bytes32 private DOMAIN_SEPARATOR;
    
    constructor() {
        DOMAIN_SEPARATOR = "LTAENGGGGGG";
    }

    function _domainSeparator() public view returns (bytes32) {
        return DOMAIN_SEPARATOR;
    }
    
    function _toTypedDataHash(bytes32 structHash) public view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparator(), structHash));
    }

}