// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    // cheatcodes: create a testing user
    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        // us -> fundMeTest -> fundMe
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();

        // cheatcodes
        vm.deal(USER, STARTING_BALANCE);
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

    function testFundFailsWithoutEnoughETH() public {
        // assert(This tx fails/reverts)
        vm.expectRevert(); // cheatcodes: hey, the next line should revert!
        fundMe.fund(); // send 0 value, less than 5 dollars
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // cheatcodes: the next tx will be send by `USER`
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
}
