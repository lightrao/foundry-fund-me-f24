// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        // us -> fundMeTest -> FundMe
        fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        console.log(address(this));
        assertEq(fundMe.getOwner(), address(this));
    }
}
