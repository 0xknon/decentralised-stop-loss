# dsl-contracts

This is a solidity smart contract repository built with both hardhat and foundry framework.
Foundry for testing and Hardhat for cron job implemntation

## Prerequisite

|      | Version   |
| ---- | --------- |
| node | >= 20.0.0 |
| solc | >= 0.8.24 |

## Getting Started

```bash
yarn install
yarn compile
```

To run the test cases:

```bash
forge test
```

## Walk Through

Bob will be mainly depositing fund to the [BobVault](./contracts/BobVault.sol) contract.

In order to have a cleaner implementations, it is seperated into two seperated contracts:

- [BobVault](./contracts/BobVault.sol)
- [WeatherDonar](./contracts/WeatherDonar.sol)

Remark: `BobVault` is inheriting `WeatherDonar`

Assuming there will be a cron job executing a script every minute and the script is located at [./scripts/cron.ts](./scripts/cron.ts).

## Decisions

### 1. No deposit function in BobVault

Bob can just transfer ETH or WETH to that contract. It is not necessary to have a deposit function in the contract itself. It helps slightly reduce the contract size and operation cost.

### 2. WETH and ETH are both considered

Since Uniswap is using WETH for ETH swapping, the `_swap()` function will wrap the ETH before swapping for stop loss.

### 3. Uniswap Router, Chainlink Price Oracle and UMAProtocol are all mocked for testing and demo purpose

For Uniswap Router, the real one has a more complex architecture. It swaps via the pools which also needs to pre-fill with some liquidity in order to make it work. In fact, the `BobVault` only needs to call the `exactInputSingle(...)` function in Uniswap Router and the assets will be swapped. To simplify the mocking process, I decided to just pre-mint some USDC to the router and swap out 1200 USDC for each 1 ETH that is trying to swap the `exactInputSingle(...)` function call.

For Chainlink Price Oracle, it has a complex architecture as well. If I integrate it with the real oracle, it may not have the price dropped to 1200 easily. I will also need to go though the consensus mechanism of the Price Oracle to mock up the price. So, I decided to reference its interfaces and just mock up the Proxy-Aggregator structure so that I can mock up the price easily.

For UMAProtocol, I may need to go through the voting process, or the price proposing process that the real Optimistic Oracle implemented. So, by mocking it up, it is a lot easier to mock up the answer for testing.

The above mocking preserve the required interfaces that make the Vault working with the real ones.

### 4. StopLoss is not Ownable

As it is protected by `shouldStopLoss` validation, the stop loss won't be triggered accidentally. Also, it is easier to demo on the frontend, e.g. user doesn't need Bob's private key to help Bob stop loss =].
