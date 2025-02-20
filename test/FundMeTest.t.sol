//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/Fund.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    //First deploy the contract
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 internal constant START_BALANCE = 10 ether;
    uint256 GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        vm.deal(USER, START_BALANCE);
    }

    function testMinUSD() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        uint256 ver = fundMe.getVersion();
        console.log(ver);
        assertEq(ver, 4);
    }

    function testFundFailsWithoutEnoughFund() public {
        vm.expectRevert();
        fundMe.fund{value: 0}();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 10e18}();
        _;
    }

    function testFindUpdatesFundedDataStructure() public funded {
        uint256 amountfunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountfunded, 10e18);
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    function testOnlyOwner() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    // ** withdraw means withdraw money from contract to account
    function test_withdraw() public funded {
        //Arrange -> Act -> Assert
        //1.check current balance
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //2.
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10; // as 160 has same number of bytes
        uint160 startIdx = 2;

        for (uint160 i = startIdx; i < numberOfFunders; i++) {
            hoax(address(i), 10e18);
            fundMe.fund{value: 10e18}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        // vm.stopPrank();

        // uint256 gasUsed = gasStart - gasleft() * tx.gasprice;
        // console.log(gasUsed);
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public {
        uint160 numberOfFunders = 10; // as 160 has same number of bytes
        uint160 startIdx = 2;

        for (uint160 i = startIdx; i < numberOfFunders; i++) {
            hoax(address(i), 10e18);
            fundMe.fund{value: 10e18}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        // vm.stopPrank();

        // uint256 gasUsed = gasStart - gasleft() * tx.gasprice;
        // console.log(gasUsed);
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
