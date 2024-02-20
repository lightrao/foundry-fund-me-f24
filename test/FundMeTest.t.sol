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

    uint256 constant SEND_VALUE = 0.1 ether; // 1e17 Wei
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 2;

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

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        // every time before run test function system will run setUp function first,
        // so the USER with index 0 commit fund.
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw(); // USER is not the owner
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act

        // tells you how much gas is left in your transaction call
        // when you send a transaction you send a little bit more gas than you'er expected to use
        // you can see how much gas left base on how much gas you send by calling gasleft()
        uint256 gasStart = gasleft(); // gas we send to the transaction
        console.log("gasStart", gasStart);

        vm.txGasPrice(GAS_PRICE); // cheatcodes: sets gasprice for the rest of the transaction
        console.log("tx.gasprice", tx.gasprice);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); // should have spent gas, for anvil gas price defaults to zero

        uint256 gasEnd = gasleft();
        console.log("gasEnd", gasEnd);

        uint256 gasUsed = (gasStart - gasEnd); // gas usage by withdraw() Txn
        console.log("gasUsed", gasUsed);
        uint256 transactionFee = gasUsed * tx.gasprice; // transaction fee from withdraw()
        console.log("transactionFee", transactionFee);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // don't use 0 to generate address
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank & vm.deal new address
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1; // don't use 0 to generate address
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank & vm.deal new address
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
