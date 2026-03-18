## Foundry School project

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

Description:
Develop a contract that functions as a points system for members, with the ability to redeem points for rewards. Anyone should be able to join as a member. Members should be able to earn points through a function in the contract and view their own point balance. Points should also be transferable between members, and an administrator should be able to assign points when needed. The contract should also include a function for redeeming points for rewards (for example, a T-shirt or VIP status), which resets or reduces the member’s point balance.

Basic requirements (Pass):
The contract must include the following elements:

At least one struct or enum

At least one mapping or array

A constructor

At least one custom modifier

At least one event to log important actions

In addition to the requirements above, you must also write tests for the contract that cover the basic functionality. Ensure that all important functions work as expected, and that you achieve a test coverage of at least 40%.

To achieve a higher grade (VG), you must fulfill all the requirements for the Pass level, and also:

The contract must include at least one custom error, as well as at least one require, one assert, and one revert

The contract must include a fallback and/or receive function

Deploy your smart contract to Sepolia and verify the contract on Etherscan. Include a link to the verified contract page in your submission.

Ensure that your contract has a test coverage of at least 90%

Identify and implement at least three gas optimizations and/or security measures in your contract (using the latest version of Solidity or the optimizer does not count). Explain which measures you have taken, why they are important, and how they improve gas usage and/or the security of the contract.





Gas Optimizations:

I chose to use address immutable admin instead of a regular state variable stored in storage. An immutable variable is stored directly in the bytecode, which makes it cheaper in gas.

I chose to pack a uint248 and a bool into the same slot so that together they fit into one uint256, which is cheaper in gas.

I stored member data, members, in a mapping instead of an array. This is gas-efficient when, for example, searching for members, and it reduces gas costs each time a function is executed.

Security Measures:

I used a modifier called onlyAdmin to control what only the admin can and cannot do. The admin is the account that deploys the contract and cannot be changed afterward. The admin cannot become a member or receive points, for example.

I added a modifier and function for pausing/freezing a member’s use of points, meaning earning, sending, and redeeming points. This can only be done by the admin.

Fallback and receive functions to protect against ETH deposits.

Validation is performed before the state is updated, to protect against reentrancy.

I use elapsed = block.timestamp together with an if statement and a revert to prevent users from using the earn-points function within 24 hours.

I am not sure whether this counts, but I use assert with totalBefore/totalAfter to check the points sent and received in a transaction, in order to ensure that the value remains the same.

Coverage:
<img width="930" height="289" alt="Skärmbild 2026-01-22 061648" src="https://github.com/user-attachments/assets/6d62f835-bc7a-4ca1-be51-c0278cd4c3c7" />



https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
