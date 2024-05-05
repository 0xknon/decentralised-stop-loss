// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {OptimisticOracleV2Interface} from "../interfaces/OptimisticOracleV2Interface.sol";

contract MockOptimisticOracleV2 is OptimisticOracleV2Interface {
    mapping(bytes32 => Request) public requests;

    function requestPrice(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        IERC20 currency,
        uint256 reward
    ) external returns (uint256 totalBond) {
        bytes32 requestId = _getId(msg.sender, identifier, timestamp, ancillaryData);
        Request memory _request = requests[requestId];
        require(address(_request.currency) == address(0), "Request already initialized");

        requests[_getId(msg.sender, identifier, timestamp, ancillaryData)] = Request({
            proposer: address(0),
            disputer: address(0),
            currency: currency,
            settled: false,
            requestSettings: RequestSettings({
                eventBased: false,
                refundOnDispute: false,
                callbackOnPriceProposed: false,
                callbackOnPriceDisputed: false,
                callbackOnPriceSettled: false,
                bond: 0,
                customLiveness: 0
            }),
            proposedPrice: 0,
            resolvedPrice: 0,
            expirationTime: 0,
            reward: reward,
            finalFee: 0
        });
    }

    function setCustomLiveness(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        uint256 customLiveness
    ) external {
        Request storage _request = requests[_getId(msg.sender, identifier, timestamp, ancillaryData)];
        _request.requestSettings.customLiveness = customLiveness;
    }

    function settle(address requester, bytes32 identifier, uint256 timestamp, bytes memory ancillaryData)
        external
        returns (uint256 payout)
    {
        Request storage _request = requests[_getId(requester, identifier, timestamp, ancillaryData)];
        _request.settled = true;
        _request.resolvedPrice = _request.proposedPrice;
    }

    function proposePriceFor(
        address proposer,
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        int256 proposedPrice
    ) public returns (uint256 totalBond) {
        Request storage request = requests[_getId(requester, identifier, timestamp, ancillaryData)];
        request.proposer = proposer;
        request.proposedPrice = proposedPrice;
    }

    function proposePrice(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        int256 proposedPrice
    ) external returns (uint256 totalBond) {
        return proposePriceFor(msg.sender, requester, identifier, timestamp, ancillaryData, proposedPrice);
    }

    function getRequest(address requester, bytes32 identifier, uint256 timestamp, bytes memory ancillaryData)
        public
        view
        returns (Request memory)
    {
        return requests[_getId(requester, identifier, timestamp, ancillaryData)];
    }

    function _getId(address requester, bytes32 identifier, uint256 timestamp, bytes memory ancillaryData)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(requester, identifier, timestamp, ancillaryData));
    }
}
