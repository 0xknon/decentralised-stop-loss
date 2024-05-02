// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../interfaces/FeedRegistryInterface.sol";

contract MockFeedRegistry is FeedRegistryInterface {
    int256 internal price;

    function decimals(address base, address quote) external view returns (uint8) {}

    function latestRoundData(address base, address quote)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {}

    function setPrice(int256 _price) external {
        price = _price;
    }
}
