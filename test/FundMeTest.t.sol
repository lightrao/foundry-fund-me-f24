// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

contract FundMeTest is Test {
    uint256 number = 1;

    function setUp() external {
        console.log("In setUp function.");
        number = 2;
    }

    function test() public {
        console.log(number);
        console.log("Hello world!");
        assertEq(number, 2);
    }
}
