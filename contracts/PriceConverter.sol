// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // ABI import

        (, int256 price, , , ) = priceFeed.latestRoundData();
        // ETH in terms of USD
        // 3000.00000000 (decimals function) -> we want to turn it to 18 decimals
        return uint(price * 1e10); // 1**10 = 10 exp 10
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        // 3000_18 zeroes = ETH / USD price
        // 1 _ 18 zeroes ETH
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        // 3_21 zeroes <-> 3000.0000... USD
        return ethAmountInUsd;
    }
}
