// Get funds from users, withdraw funds, set a minimium funding value in USD

// SPDX-License-Identifier: MIT

//Pragma
pragma solidity ^0.8.8;
//Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";
//Error Codes
error FundMe__notOwner(); // Include FundMe__ to know where error comes from

// error FundMe__callFailed();

//Interfaces Libraries and Contracts

/** @title A contract for crowd funding
 * @author Cristian Petre-Luca
 * @notice This contract is to demo a sample funding contract
 * @dev This implements price feeds as our libraries
 */

contract FundMe {
    // Type declarations
    using PriceConverter for uint256;

    // State variables!
    uint256 public constant MINIMUM_USD = 50 * 1e18; // consant ~ variable declaration on a single line and never changed again, 2000 gas saving

    address[] private s_funders; // add s to indicate storage, costly variables
    mapping(address => uint256) private s_addressToAmountFunded;

    address private immutable i_owner; // saves ~2000 gas, immutable for separate variable declaration to value assignement

    AggregatorV3Interface public s_priceFeed;

    // Modifiers

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner!");
        if (msg.sender != i_owner) {
            revert FundMe__notOwner();
        } // custom errors instead of require will save gas
        _; // do the rest if owenr
    }

    // Functions order:
    //// Constructor
    //// Receive
    //// Fallback
    //// External
    //// Public
    //// Internal
    //// Private

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // What happens if someone sends this contract ETH without calling fund(); ?

    // receive() external payable {
    //     fund();
    // }

    // // fallback();
    // fallback() external payable {
    //     fund();
    // }

    /**
     * @notice This function funds this contract
     * @dev This implements price feeds as our library
     */
    function fund() public payable {
        // payable is added to
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Minimum value is 50 USD"
        ); // 1e18 = 1*10^18 wei - 18 decimals because 18 zeroes for wei
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public payable onlyOwner {
        for (
            // for loop for reading and modifying storage vars, so expensive!
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        s_funders = new address[](0);
        // actually withdraw the funds

        // transfer
        // msg.sender -> address, payable(msg.sender) -> typecasts msg.sender to a payable address
        // payable(msg.sender).transfer(address(this).balance)

        // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        // if (!callSuccess){ cheaper option
        //     revert FundMe__callFailed();
        // }
        require(callSuccess, "Call failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        // mappings can't be in memory
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(
        address funder
    ) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
