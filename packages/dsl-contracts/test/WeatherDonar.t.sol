// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import {BaseSetup} from "./setup/BaseSetup.t.sol";
import "../contracts/BobVault.sol";
import {MockOptimisticOracleV2} from "../contracts/mock/MockOptimisticOracleV2.sol";

contract WeatherDonarTest is BaseSetup {
    BobVault internal vault;
    MockOptimisticOracleV2 internal oo;

    function setUp() public override {
        BaseSetup.setUp();

        oo = new MockOptimisticOracleV2();

        vm.prank(bob);
        vault = new BobVault(address(proxy), address(router), charity, address(oo), address(weth), address(usdc));

        vm.deal(address(vault), 100 ether);
    }

    function test_BobDonate() public {
        vault.requestData();
        bytes memory ancillaryData = vault.getTodayAncillaryData();
        uint256 timestamp = vault.dataRequestTime(ancillaryData);

        oo.proposePrice(address(vault), vault.identifier(), timestamp, ancillaryData, 1);
        vm.warp(36001);

        vault.settleRequest();
        assertEq(vault.getSettledData(), 1);

        // Check balance before donate
        assertEq(charity.balance, 0);
        vm.prank(bob);
        vault.donate();

        // Charity gets donated
        assertEq(charity.balance, 1 ether);
    }

    function test_RevertWeatherNotRequestedDonate() public {
        vm.startPrank(bob);
        vm.expectRevert("WeatherDonar: temperature not met");
        vault.donate();
        vm.stopPrank();
    }

    function test_RevertBobWeatherNotMetDonate() public {
        vault.requestData();
        bytes memory ancillaryData = vault.getTodayAncillaryData();
        uint256 timestamp = vault.dataRequestTime(ancillaryData);

        oo.proposePrice(address(vault), vault.identifier(), timestamp, ancillaryData, 0);
        vm.warp(36001);

        vault.settleRequest();
        assertEq(vault.getSettledData(), 0);

        // Check balance before donate
        assertEq(charity.balance, 0);
        vm.startPrank(bob);
        vm.expectRevert("WeatherDonar: temperature not met");
        vault.donate();
        vm.stopPrank();
    }

    function test_RevertNonBobDonate() public {
        vm.startPrank(dev);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, dev));
        vault.donate();
        vm.stopPrank();
    }

    function test_BobRequestWeatherData() public {
        bytes memory data = vault.getTodayAncillaryData();
        assertEq(vault.dataRequestTime(data), 0);

        vault.requestData();
        assertEq(vault.dataRequestTime(data), block.timestamp);
    }

    function test_RevertBobRequestWeatherData() public {
        vault.requestData();
        vm.expectRevert("WeatherDonar: Requested");
        vault.requestData();
    }

    function test_RevertSettleRequest() public {
        vm.expectRevert("WeatherDonar: Request not sent");
        vault.settleRequest();
    }

    function test_GetDate() public {
        assertEq(vault.getDate(), "1/1/1970");
        vm.warp(3600 * 24);
        assertEq(vault.getDate(), "2/1/1970");
    }
}
