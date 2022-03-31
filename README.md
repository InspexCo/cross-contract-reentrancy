# Cross-Contract Reentrancy Attack

This repository contains vulnerable contracts demonstrating Cross-Contract-Reentrancy Attack to provide deeper understanding for those who read the [Cross-Contract Reentrancy Attack](https://inspexco.medium.com/cross-contract-reentrancy-attack-402d27a02a15) article to follow through with a simulated lab.

## Setup
```
git clone git@github.com:InspexCo/cross-contract-reentrancy.git
cd cross-contract-reentrancy
yarn install
```

## Hacking

The goal is to hijack the execution flow and inflate the price of $VT, then use the $VT to buy $GOV cheaper.

1. Write your evil token in `contracts/EvilERC20.sol`
2. Write your exploit in `test/exploit.js`
3. Simulate the exploit by running `npx hardhat test`

## Disclaimer

All code, practices, and patterns in this repository are used for educational purposes only.

!!! DO NOT USE IN PRODUCTION !!!

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.