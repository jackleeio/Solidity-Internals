# Understanding Basic Storage Layout

This tutorial explores how Solidity smart contracts organize and store state variables in the EVM storage. Understanding storage layout is crucial for optimizing gas costs and writing efficient smart contracts.

## EVM Storage Basics

The Ethereum Virtual Machine (EVM) provides persistent storage for each contract account through a key-value store where both keys and values are 256 bits. This storage is:
- Persistent (remains on the blockchain until explicitly modified)
- Expensive (high gas costs for SLOAD and SSTORE operations)
- Organized in 32-byte (256-bit) slots

## Storage Layout Rules for Value Types

Let's explore the rules governing how Solidity organizes state variables in storage through examples.

### Rule 1: Sequential Slot Assignment

Variables are stored sequentially starting from slot 0:

```solidity
contract StorageExample1 {
    uint256 public tokenSupply = 1000000;
    address public owner = address(0x123);
}
```

Storage layout:
| Variable    | Type    | Slot | Offset | Bytes |
|------------|---------|------|---------|-------|
| tokenSupply| uint256 | 0    | 0       | 32    |
| owner      | address | 1    | 0       | 20    |

### Rule 2: Slot Packing

Multiple smaller variables can share a single storage slot if their combined size is ≤ 32 bytes:

```solidity
contract StorageExample2 {
    uint128 public price = 500;
    uint64 public timestamp = 1234567;
    uint32 public quantity = 100;
    uint128 public total = 50000; // This goes to next slot
}
```

Storage layout:
| Variable  | Type    | Slot | Offset | Bytes |
|-----------|---------|------|---------|-------|
| price     | uint128 | 0    | 0       | 16    |
| timestamp | uint64  | 0    | 16      | 8     |
| quantity  | uint32  | 0    | 24      | 4     |
| total     | uint128 | 1    | 0       | 16    |

### Rule 3: Right-aligned Storage

Values within a slot are stored right-aligned. For example, in StorageExample2, slot 0 would look like:

```
Slot 0: 0x0000000064000000000012D687000000000000000000000000000000000001F4
        [quantity]  [timestamp]            [price]
```

### Rule 4: New Slot for Complex Types

Structs and arrays always start at a new storage slot, and variables following them also start at a new slot:

```solidity
contract StorageExample3 {
    struct TokenInfo {
        uint64 id;
        uint32 decimals;
    }
    
    uint128 public marketCap = 1000000;
    TokenInfo public token = TokenInfo(1, 18);
    uint64 public lastUpdate = 1234567;
}
```

Storage layout:
| Name       | Type                             | Slot | Offset | Bytes | Contract                                        |
|------------|----------------------------------|------|--------|-------|-------------------------------------------------|
| marketCap  | uint128                          | 0    | 0      | 16    | src/01-basic-storage-layout.sol:StorageExample3 |
| token      | struct StorageExample3.TokenInfo | 1    | 0      | 32    | src/01-basic-storage-layout.sol:StorageExample3 |
| lastUpdate | uint64                           | 2    | 0      | 8     | src/01-basic-storage-layout.sol:StorageExample3 |

## Gas Optimization Tips

1. Group smaller variables together to utilize slot packing
2. Be aware that complex types create new slots
3. Consider using smaller uint types when possible (but remember that downcasting may cost extra gas)

## Testing Storage Layout

You can inspect a contract's storage layout using Foundry:

```bash
forge inspect src/01-basic-storage-layout.sol:StorageExample3 storage-layout --pretty
```

## Summary

Understanding Solidity's storage layout rules is essential for:
- Optimizing gas costs
- Debugging storage-related issues
- Writing more efficient smart contracts

The key rules to remember are:
1. Sequential slot assignment
2. Slot packing for small variables
3. Right-aligned storage
4. New slots for complex types

This knowledge becomes particularly important when dealing with upgradeable contracts or when trying to optimize gas costs in production contracts.