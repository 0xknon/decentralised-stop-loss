// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "../../contracts/mock/MockERC20.sol";
import "../../contracts/mock/WETH9.sol";
import "../interfaces/IWETH9.sol";

contract MockUniswapRouter {
    IWETH9 public weth;
    MockERC20 public usdc;

    constructor(address _weth, address _usdc) {
        usdc = MockERC20(_usdc);
        weth = IWETH9(_weth);
    }

    function exactInputSingle(ISwapRouter.ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut)
    {}
}
