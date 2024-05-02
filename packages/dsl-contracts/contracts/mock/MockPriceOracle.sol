// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/AggregatorV3Interface.sol";

contract MockPriceOracle is AggregatorV3Interface {
    struct RoundData {
        int256 answer;
        uint256 startedAt;
        uint256 updatedAt;
    }

    uint80 public currentRoundId;
    mapping(uint80 => RoundData) public rounds;

    function decimals() external pure returns (uint8) {
        return 8;
    }

    function description() external pure returns (string memory) {
        return "ETH/USD";
    }

    function version() external pure returns (uint256) {
        return 4;
    }

    function getRoundData(uint80 _roundId)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        RoundData memory data = rounds[_roundId];
        roundId = _roundId;
        answer = data.answer;
        startedAt = data.startedAt;
        updatedAt = data.updatedAt;
        answeredInRound = _roundId;
    }

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        RoundData memory data = rounds[currentRoundId];
        roundId = currentRoundId;
        answer = data.answer;
        startedAt = data.startedAt;
        updatedAt = data.updatedAt;
        answeredInRound = currentRoundId;
    }

    function setRoundData(RoundData calldata _data) external {
        currentRoundId += 1;
        rounds[currentRoundId] = _data;
    }
}
