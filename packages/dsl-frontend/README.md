# dsl-frontend

## Prerequisite

|      | Version   |
| ---- | --------- |
| Node | >= 20.0.0 |

Compile the contracts in the `dsl-contracts` packages. To do so, please check the [README of dsl-contracts](../dsl-contracts/README.md)

## Getting Started

Run the development server:

```bash
yarn install
yarn dev
```

Open [http://localhost:8080](http://localhost:8080) with your browser to see the result.

## Important Notes

1. Contracts have been deployed on Sepolia Testnet
2. You can set the current price of ETH with Mock Chainlink Price Oracle
3. For every 1 ETH that is going to swap with the Mock Uniswap Router, it gives out 1200 USDC.
4. Remember to fund the Router with the Mock USDC so that it has enough fund to swap
5. Even the transaction is successful, it has some delay to take effect. Not sure if it is because of the network or bugs yet.
6. Only manual stop loss is implemented. More detailed implementation can be added such as Transaction Notification, Stop Loss Cron Job on web, Temperature-based Donation, etc. Hopefully it is enough to show the my capability on frontend development.
