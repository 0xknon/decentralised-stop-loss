// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import {IChainlinkProxy} from "../interfaces/IChainlinkProxy.sol";
import "../interfaces/IWETH9.sol";
import "../interfaces/OptimisticOracleV2Interface.sol";

contract Storage {
    address public immutable charity;
    OptimisticOracleV2Interface public immutable weatherOracle;
    IChainlinkProxy public immutable proxy;
    ISwapRouter public immutable router;

    IWETH9 public immutable WETH9;
    IERC20 public immutable USDC;

    constructor(
        address _proxy,
        address _router,
        address _charity,
        address _weatherOracle,
        address _weth,
        address _usdc
    ) {
        charity = _charity;
        weatherOracle = OptimisticOracleV2Interface(_weatherOracle);
        proxy = IChainlinkProxy(_proxy);
        router = ISwapRouter(_router);
        WETH9 = IWETH9(_weth);
        USDC = IERC20(_usdc);
    }
}
