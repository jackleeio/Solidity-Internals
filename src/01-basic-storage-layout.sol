// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract StorageExample3 {
    struct TokenInfo {
        uint64 id;
        uint32 decimals;
    }
    
    uint128 public marketCap = 1000000;
    TokenInfo public token = TokenInfo(1, 18);
    uint64 public lastUpdate = 1234567;
}