// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import {BaseSetup} from "./setup/BaseSetup.t.sol";
import "../contracts/BobVault.sol";
import "../contracts/mock/MockChainlinkProxy.sol";
import "../contracts/mock/MockChainlinkAggregator.sol";

contract BobVaultTest is BaseSetup {
    BobVault internal vault;

    function setUp() public override {
        BaseSetup.setUp();

        vm.prank(bob);
        vault = new BobVault(address(proxy), address(router), address(0), address(0), address(weth), address(usdc));
    }

    function testFuzz_BobStopLoss(int64 price, uint256 thresholdIndex, uint256 aggrCount1, uint256 aggrCount2) public {
        // Fuzz setup
        vm.assume(price > 120000000000);
        aggrCount1 = bound(aggrCount1, 1, 18);
        aggrCount2 = bound(aggrCount2, 0, 18);
        // Fuzz testing for setting each relevant aggregator round ID to have price below 1200 USD
        uint256 minThresholdIndex = aggrCount1 + aggrCount2 < 18 ? 1 : aggrCount1 + aggrCount2 - 17;
        thresholdIndex = bound(thresholdIndex, minThresholdIndex, aggrCount1 + aggrCount2);

        // Fund the vault with 1000 ETH & 1000 WETH
        _fundVault(address(vault));

        // To simplify the test case, the Mock router is assuming each 1 ETH swaping for 1200 USD
        uint256 usdAmountToReceive = 2000 ether * 1200 * 10 ** usdc.decimals() / 10 ** weth.decimals();

        // Fund the router with the exact USD amount
        _fundRouter(usdAmountToReceive);

        // Setting Price Oracle data
        MockChainlinkAggregator _aggregator = new MockChainlinkAggregator();
        proxy.setAggregator(1, address(_aggregator));

        for (uint80 i = 1; i <= aggrCount1; i++) {
            uint256 updatedAt = i * 100;
            uint80(thresholdIndex) == i;
            int256 _price = uint80(thresholdIndex) == i ? int256(110000000000) : price + int256(updatedAt);
            _aggregator.setRoundData(i, MockChainlinkAggregator.RoundData(_price, updatedAt, updatedAt));
        }

        if (aggrCount2 != 0) {
            MockChainlinkAggregator _aggregator2 = new MockChainlinkAggregator();
            proxy.setAggregator(2, address(_aggregator2));

            for (uint80 i = 1; i <= aggrCount2; i++) {
                uint256 updatedAt = (aggrCount1 + i) * 100;
                int256 _price =
                    uint80(thresholdIndex) == i + aggrCount1 ? int256(110000000000) : price + int256(updatedAt);
                _aggregator2.setRoundData(i, MockChainlinkAggregator.RoundData(_price, updatedAt, updatedAt));
            }
        }

        // Bob wants to check Stop Loss
        vm.startPrank(bob);
        assertEq(vault.shouldStopLoss(), true);
        vault.stopLoss();
        vm.stopPrank();

        // The vault should have 2400 USDC
        assertEq(usdc.balanceOf(address(vault)), usdAmountToReceive);
    }

    function testFuzz_BobWithdrawal(uint256 amount) public {
        vm.assume(amount < type(uint256).max - 3);

        address _vaultAddress = address(vault);
        vm.startPrank(bob);
        vm.deal(bob, amount);
        weth.deposit{value: amount}();
        weth.transfer(_vaultAddress, amount);
        usdc.mint(_vaultAddress, amount);
        vm.deal(_vaultAddress, amount);

        // Vault's balances after withdraw
        assertEq(weth.balanceOf(_vaultAddress), amount);
        assertEq(usdc.balanceOf(_vaultAddress), amount);
        assertEq(_vaultAddress.balance, amount);

        vault.withdraw(address(usdc), amount);
        vault.withdraw(address(weth), amount);
        vault.withdrawETH(amount);

        // Bob's balances after withdraw
        assertEq(weth.balanceOf(bob), amount);
        assertEq(usdc.balanceOf(bob), amount);
        assertEq(bob.balance, amount);

        vm.stopPrank();
    }

    function testFuzz_RevertStopLossWhenThresholdNotReached(int64 price, uint256 aggrCount1, uint256 aggrCount2)
        public
    {
        vm.assume(price > 120000000000);
        aggrCount1 = bound(aggrCount1, 1, 18);
        aggrCount2 = bound(aggrCount2, 0, 18);

        vm.startPrank(bob);
        MockChainlinkAggregator _aggregator = new MockChainlinkAggregator();
        proxy.setAggregator(1, address(_aggregator));

        for (uint80 i = 1; i <= aggrCount1; i++) {
            uint256 updatedAt = i * 100;
            int256 priceAdjust = int256(updatedAt);
            _aggregator.setRoundData(i, MockChainlinkAggregator.RoundData(price + priceAdjust, updatedAt, updatedAt));
        }

        if (aggrCount2 != 0) {
            MockChainlinkAggregator _aggregator2 = new MockChainlinkAggregator();
            proxy.setAggregator(2, address(_aggregator2));

            for (uint80 i = 1; i <= aggrCount2; i++) {
                uint256 updatedAt = (aggrCount1 + i) * 100;
                int256 priceAdjust = int256(updatedAt);
                _aggregator2.setRoundData(
                    i, MockChainlinkAggregator.RoundData(price + priceAdjust, updatedAt, updatedAt)
                );
            }
        }
        assertEq(vault.shouldStopLoss(), false);
        vm.expectRevert(BobVault.InvalidStopLoss.selector);
        vault.stopLoss();
        vm.stopPrank();
    }

    function testFuzz_RevertStopLossWhenNotStoppedByOwner(int256 price, uint256 updatedAt) public {
        vm.startPrank(dev);
        MockChainlinkAggregator _aggregator = new MockChainlinkAggregator();
        proxy.setAggregator(1, address(_aggregator));

        _aggregator.setRoundData(1, MockChainlinkAggregator.RoundData(price, updatedAt, updatedAt));
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, dev));
        vault.stopLoss();
        vm.stopPrank();
    }

    function test_RevertNonOwnerWithdrawal() public {
        // vm.expectRevert(bytes("error message"));
        vm.startPrank(dev);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, dev));
        vault.withdraw(address(usdc), 1 ether);

        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, dev));
        vault.withdrawETH(1 ether);
        vm.stopPrank();
    }
}
