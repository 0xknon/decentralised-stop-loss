// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/mock/MockERC20.sol";
import "../../contracts/mock/WETH9.sol";
import "../../contracts/mock/MockPriceOracle.sol";
import "../../contracts/mock/MockUniswapRouter.sol";

contract BaseSetup is Test {
    MockERC20 public usdc;
    WETH9 public weth;

    address public owner;
    address public bob;

    MockPriceOracle public oracle;
    MockUniswapRouter public router;

    function setUp() public virtual {
        weth = new WETH9();
        usdc = new MockERC20();
        oracle = new MockPriceOracle();
        router = new MockUniswapRouter(address(weth), address(usdc));

        owner = vm.addr(1);
        bob = vm.addr(2);

        _fundRouter();
        _fundBob();
    }

    function _fundRouter() private {
        vm.deal(owner, 1000 ether);

        vm.startPrank(owner);
        weth.deposit{value: 1000 ether}();
        weth.transfer(address(router), 1000 ether);
        vm.stopPrank();

        usdc.mint(address(router), 1000 ether);
    }

    function _fundBob() private {
        vm.deal(bob, 2000 ether);
        vm.prank(bob);
        weth.deposit{value: 1000 ether}();
    }
}
