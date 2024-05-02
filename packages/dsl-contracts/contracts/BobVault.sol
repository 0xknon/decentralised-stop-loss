// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "./interfaces/AggregatorV3Interface.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "./interfaces/IWETH9.sol";
import "./WeatherDonar.sol";

contract BobVault is Ownable, WeatherDonar {
    int256 internal constant THRESHOLD = 120000000000;

    AggregatorV3Interface internal immutable aggregator;
    ISwapRouter internal immutable router;

    IWETH9 internal immutable WETH9;
    IERC20 internal immutable USDC;

    error InvalidStopLoss();

    constructor(AggregatorV3Interface _aggregator, ISwapRouter _router, IWETH9 _weth, IERC20 _usdc)
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

    function stopLoss() external onlyOwner {
        if (!shouldStopLoss()) {
            revert InvalidStopLoss();
        }
        _swap();
    }

    function withdrawETH(uint256 _amount) external onlyOwner {
        (bool success,) = msg.sender.call{value: _amount}("");
        require(success, "BobVault: Failed to send Ether");
    }

    function withdraw(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function _swap() internal {
        // Wrap ETH if any
        uint256 _balance = address(this).balance;
        if (_balance > 0) {
            WETH9.deposit{value: _balance}();
        }

        // Reuse the _balance variables for WETH balance
        _balance = WETH9.balanceOf(address(this));
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: address(WETH9),
            tokenOut: address(USDC),
            fee: 3000,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: _balance,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        // The call to `exactInputSingle` executes the swap.
        router.exactInputSingle(params);
    }
}
