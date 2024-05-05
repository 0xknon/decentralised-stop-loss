// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IChainlinkProxy} from "./interfaces/IChainlinkProxy.sol";
import {IChainlinkAggregator} from "./interfaces/IChainlinkAggregator.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "./interfaces/IWETH9.sol";
import "./WeatherDonar.sol";

contract BobVault is WeatherDonar {
    int256 internal constant THRESHOLD = 120000000000;

    error InvalidStopLoss();

    constructor(address _proxy, address _router, address _charity, address _weatherOracle, address _weth, address _usdc)
        WeatherDonar(_proxy, _router, _charity, _weatherOracle, _weth, _usdc)
    {}

    function shouldStopLoss() public view returns (bool) {
        (uint80 _roundId, int256 _answer,, uint256 _updatedAt,) = proxy.latestRoundData();
        (uint16 _phaseId, uint64 _aggregatorRoundId) = decodeRoundId(_roundId);
        do {
            if (_answer <= THRESHOLD) {
                return true;
            }

            if (_aggregatorRoundId == 1) {
                // Reached the earliest round our current Aggregator.
                // Move to the previous Aggregator to check whether it should stop loss.
                _phaseId -= 1;
                IChainlinkAggregator _prevAggregator = IChainlinkAggregator(proxy.phaseAggregators(_phaseId));
                if (address(_prevAggregator) == address(0)) {
                    return false;
                }

                _aggregatorRoundId = uint64(_prevAggregator.latestRound());
                (_roundId, _answer,, _updatedAt,) = proxy.getRoundData(encodeRoundId(_phaseId, _aggregatorRoundId));
            } else {
                // Looping over aggregator round id
                (_roundId, _answer,, _updatedAt,) = proxy.getRoundData(_roundId - 1);
                _aggregatorRoundId -= 1;
            }
        } while (_updatedAt + 1800 >= block.timestamp); // Stop the loop if updatedAt is no longer within 30 minutes

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

        // Approve router to transfer
        TransferHelper.safeApprove(address(WETH9), address(router), _balance);

        // The call to `exactInputSingle` executes the swap.
        router.exactInputSingle(params);
    }

    function decodeRoundId(uint80 _roundId) public pure returns (uint16 _phaseId, uint64 _aggregatorRoundId) {
        _phaseId = uint16(_roundId >> 64);
        _aggregatorRoundId = uint64(_roundId);
    }

    function encodeRoundId(uint16 _phaseId, uint64 _aggregatorRoundId) public pure returns (uint80 _roundId) {
        _roundId = uint80(uint256(_phaseId) << 64 | _aggregatorRoundId);
    }
}
