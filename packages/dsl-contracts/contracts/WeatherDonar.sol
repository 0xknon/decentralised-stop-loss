// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/OptimisticOracleV2Interface.sol";
import "./core/DateTimeFormatter.sol";
import "./core/Storage.sol";

contract WeatherDonar is DateTimeFormatter, Ownable, Storage {
    bytes32 public constant identifier = bytes32("YES_OR_NO_QUERY");

    mapping(bytes => uint256) public dataRequestTime;

    constructor(address _proxy, address _router, address _charity, address _weatherOracle, address _weth, address _usdc)
        Storage(_proxy, _router, _charity, _weatherOracle, _weth, _usdc)
        Ownable(msg.sender)
    {}

    receive() external payable {}

    function requestData() public {
        bytes memory ancillaryData = getTodayAncillaryData();
        require(dataRequestTime[ancillaryData] == 0, "WeatherDonar: Requested");

        IERC20 bondCurrency = IERC20(WETH9); // Use WETH as the bond currency.
        weatherOracle.requestPrice(identifier, block.timestamp, ancillaryData, bondCurrency, 0);

        // Set 10 hours for liveness
        weatherOracle.setCustomLiveness(identifier, block.timestamp, ancillaryData, 36000);

        dataRequestTime[ancillaryData] = block.timestamp;
    }

    // Settle the request once it's gone through the liveness period of 30 seconds. This acts the finalize the voted on price.
    // In a real world use of the Optimistic Oracle this should be longer to give time to disputers to catch bat price proposals.
    function settleRequest() public {
        bytes memory ancillaryData = getTodayAncillaryData();
        uint256 requestTime = dataRequestTime[ancillaryData];
        require(dataRequestTime[ancillaryData] != 0, "WeatherDonar: Request not sent");
        weatherOracle.settle(address(this), identifier, requestTime, ancillaryData);
    }

    // Fetch the resolved price from the Optimistic Oracle that was settled.
    function getSettledData() public view returns (int256) {
        bytes memory ancillaryData = getTodayAncillaryData();
        uint256 requestTime = dataRequestTime[ancillaryData];
        return weatherOracle.getRequest(address(this), identifier, requestTime, ancillaryData).resolvedPrice;
    }

    function getDate() public view returns (string memory) {
        uint256 _timestamp = block.timestamp;
        uint256 _day = getDay(_timestamp);
        uint256 _month = getMonth(_timestamp);
        uint256 _year = getYear(_timestamp);
        return string.concat(Strings.toString(_day), "/", Strings.toString(_month), "/", Strings.toString(_year));
    }

    function getTodayAncillaryData() public view returns (bytes memory) {
        return bytes(
            string.concat("Q:Did the temperature on the ", getDate(), " in Hong Kong above 30c? A:1 for yes. 0 for no.")
        );
    }

    // Only ETH is used to donate =]
    function donate() public onlyOwner {
        require(getSettledData() == 1, "WeatherDonar: temperature not met");
        uint256 _amount = address(this).balance / 100;
        (bool success,) = charity.call{value: _amount}("");
        require(success, "transaction failed");
    }
}
