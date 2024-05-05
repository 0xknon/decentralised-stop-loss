// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interfaces/IChainlinkProxy.sol";
import "../interfaces/IChainlinkAggregator.sol";

contract MockChainlinkProxy is IChainlinkProxy {
    uint16 public phaseId;
    mapping(uint16 => address) public phaseAggregators;

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
        public
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        (uint16 _phaseId, uint64 _aggregatorRoundId) = decodeRoundId(_roundId);
        IChainlinkAggregator aggregator = IChainlinkAggregator(phaseAggregators[_phaseId]);

        (, answer, startedAt, updatedAt,) = aggregator.getRoundData(_aggregatorRoundId);
        roundId = _roundId;
        answeredInRound = _roundId;
    }

    function latestRound() public view returns (uint256) {
        IChainlinkAggregator aggregator = IChainlinkAggregator(phaseAggregators[phaseId]); // cache storage reads
        return encodeRoundId(phaseId, uint64(aggregator.latestRound()));
    }

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        IChainlinkAggregator aggregator = IChainlinkAggregator(phaseAggregators[phaseId]);
        uint80 _roundId = encodeRoundId(phaseId, uint64(aggregator.latestRound()));

        (, answer, startedAt, updatedAt,) = aggregator.latestRoundData();
        roundId = _roundId;
        answeredInRound = _roundId;
    }

    function setAggregator(uint16 _phaseId, address _aggregator) public {
        phaseId = _phaseId;
        phaseAggregators[_phaseId] = _aggregator;
    }

    function decodeRoundId(uint80 _roundId) internal pure returns (uint16 _phaseId, uint64 _aggregatorRoundId) {
        _phaseId = uint16(_roundId >> 64);
        _aggregatorRoundId = uint64(_roundId);
    }

    function encodeRoundId(uint16 _phaseId, uint64 _aggregatorRoundId) internal pure returns (uint80 _roundId) {
        _roundId = uint80(uint256(_phaseId) << 64 | _aggregatorRoundId);
    }
}
