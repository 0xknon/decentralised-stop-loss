// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "../../contracts/mock/MockERC20.sol";
import "../../contracts/mock/WETH9.sol";
import "../interfaces/IWETH9.sol";

contract MockUniswapRouter {
    // To simplify the Router, assuming each 1 ETH swaping for 1200 USD
    function exactInputSingle(ISwapRouter.ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut)
    {
        IERC20Metadata tokenIn = IERC20Metadata(params.tokenIn);
        IERC20Metadata tokenOut = IERC20Metadata(params.tokenOut);

        tokenIn.transferFrom(msg.sender, address(this), params.amountIn);
        amountOut = params.amountIn * 1200 * 10 ** tokenOut.decimals() / 10 ** tokenIn.decimals();
        tokenOut.transfer(msg.sender, amountOut);
    }
}
