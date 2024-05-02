// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {BaseSetup} from "./setup/BaseSetup.t.sol";
import "../contracts/BobVault.sol";
import "../contracts/mock/MockPriceOracle.sol";

contract BobVaultTest is BaseSetup {
    BobVault internal vault;

    function setUp() public override {
        BaseSetup.setUp();
        vault = new BobVault(address(oracle), address(router), address(weth), address(usdc));
    }

    function test_NotStopLoss() public {
        oracle.setRoundData(MockPriceOracle.RoundData(3000, 0, 0));
    }
}
