// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../contracts/mock/MockERC20.sol";
import "../../contracts/mock/WETH9.sol";
import "../../contracts/mock/MockChainlinkProxy.sol";
import "../../contracts/mock/MockUniswapRouter.sol";

contract BaseSetup is Test {
    MockERC20 public usdc;
    WETH9 public weth;

    address public dev;
    address public bob;
    address public charity;

    MockChainlinkProxy public proxy;
    MockUniswapRouter public router;

    function setUp() public virtual {
        weth = new WETH9();
        usdc = new MockERC20();
        proxy = new MockChainlinkProxy();
        router = new MockUniswapRouter();

        dev = vm.addr(1);
        bob = vm.addr(2);
        charity = vm.addr(3);
    }

    function _fundRouter(uint256 _amount) internal {
        usdc.mint(address(router), _amount);
    }

    // Fund the vault with 1000 ETH & 1000 WETH
    function _fundVault(address _vault) internal {
        vm.startPrank(bob);
        vm.deal(bob, 1000 ether);
        weth.deposit{value: 1000 ether}();
        weth.transfer(_vault, 1000 ether);

        vm.deal(_vault, 1000 ether);
        vm.stopPrank();
    }
}
