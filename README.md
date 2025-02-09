# TreasuryLari Smart Contract

## Overview

TreasuryLari is a smart contract deployed on the Tron Network to manage token transactions and treasury operations. The contract implements ERC-20 token standards and includes additional functionalities such as tax deductions, transaction restrictions, and administrative controls.

## Features

- Implements ERC-20 token functionalities.
- Supports taxation mechanisms for transactions.
- Includes ownership and pausable functionalities.
- Prevents transactions from blocked addresses.
- Optimized for deployment on the Tron Network by using 0.8.18 to avoiding the PUSH0 opcode.

## Requirements

- Solidity `0.8.18`
- TronLink Wallet for interaction
- Tron Virtual Machine (TVM) compatible blockchain

## Testing

Run unit tests with Foundry:

```sh
forge test
```

## Security Considerations

- The contract prevents transactions from blocked addresses.
- It includes an emergency pause mechanism.
- Ensure owner privileges are secured to prevent unauthorized access.

## License

This project is licensed under the MIT License.

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

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
