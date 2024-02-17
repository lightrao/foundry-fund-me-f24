// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    function setUp() external {
        // us -> fundMeTest -> fundMe
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        // us -> fundMeTest -> deployFundMe -> fundMe
        console.log("The address of fundMe's owner:", fundMe.getOwner());
        console.log("msg.sender:", msg.sender);
        console.log("The address of fundMeTest:", address(this));
        console.log("The address of deployFundMe:", address(deployFundMe));
        console.log("The address of fundMe:", address(fundMe));

        // assertEq(fundMe.getOwner(), address(deployFundMe));

        // Becarful: fundMe's owner is msg.sender(us) who is running these tests
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}
