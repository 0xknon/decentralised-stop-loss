// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import {AggregatorV3Interface} from "./interfaces/AggregatorV3Interface.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/external/IWETH9.sol";

contract BobVault is Ownable {
    int256 internal constant THRESHOLD = 120000000000;

    AggregatorV3Interface internal immutable aggregator;
    ISwapRouter internal immutable router;

    IWETH9 internal immutable WETH9;
    address internal immutable USDC;

    error InvalidStopLoss();

    constructor(AggregatorV3Interface _aggregator, ISwapRouter _router, IWETH9 _weth, address _usdc)
        Ownable(msg.sender)
    {
        aggregator = _aggregator;
        router = _router;
        WETH9 = _weth;
        USDC = _usdc;
    }

    function shouldStopLoss() public view returns (bool) {
        (uint80 _roundId, int256 _answer,, uint256 _updatedAt,) = aggregator.latestRoundData();

        do {
            if (_answer < THRESHOLD) {
                return true;
            }
            (_roundId, _answer,, _updatedAt,) = aggregator.getRoundData(_roundId - 1);
        } while (_updatedAt + 1800 >= block.timestamp);

        return false;
    }

    function stopLoss() public onlyOwner {
        if (!shouldStopLoss()) {
            revert InvalidStopLoss();
        }
    }

    function withdraw(address _token) public {}

    function _swap() internal {
        if (address(this).balance > 0) {
            WETH9.deposit(address(this).balance);
        }

        uint256 balance = WETH9.balanceOf(this);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: WETH9,
            tokenOut: USDC,
            fee: poolFee,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: balance,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }
}
