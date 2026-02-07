// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/AIAnalyzer.sol";

contract AIAnalyzerTest is Test {
    AIAnalyzer ai;
    address owner;
    address user;

    receive() external payable {}

    function setUp() public {
        owner = address(this);
        user = address(0xBEEF);
        ai = new AIAnalyzer();
        vm.deal(user, 1 ether);
    }

    function testAnalyzeRiskLowRisk() public {
        vm.prank(user);
        uint256 riskLevel = ai.analyzeRisk{value: 0.01 ether}(10 ether, 100 ether); // 10% withdrawal
        assertEq(riskLevel, 30);
    }

    function testAnalyzeRiskHighRisk() public {
        vm.prank(user);
        uint256 riskLevel = ai.analyzeRisk{value: 0.01 ether}(30 ether, 100 ether); // 30% withdrawal
        assertEq(riskLevel, 80);
    }

    function testAnalyzeRiskHighRiskOver30() public {
        vm.prank(user);
        uint256 riskLevel = ai.analyzeRisk{value: 0.01 ether}(50 ether, 100 ether); // 50% withdrawal
        assertEq(riskLevel, 80);
    }

    function testAnalyzeRiskInsufficientPayment() public {
        vm.prank(user);
        vm.expectRevert(AIAnalyzer.InsufficientPayment.selector);
        ai.analyzeRisk{value: 0.005 ether}(10 ether, 100 ether);
    }

    function testAnalyzeRiskInvalidVaultBalance() public {
        vm.prank(user);
        vm.expectRevert(AIAnalyzer.InvalidVaultBalance.selector);
        ai.analyzeRisk{value: 0.01 ether}(10 ether, 0);
    }

    function testWithdrawFees() public {
        // First, perform an analysis to accumulate fees
        vm.prank(user);
        ai.analyzeRisk{value: 0.01 ether}(10 ether, 100 ether);

        address payable recipient = payable(address(this));
        uint256 initialBalance = recipient.balance;
        ai.withdrawFees(recipient);
        uint256 finalBalance = recipient.balance;

        assertEq(finalBalance - initialBalance, 0.01 ether);
    }

    function testWithdrawFeesNotOwner() public {
        vm.prank(user);
        vm.expectRevert(AIAnalyzer.NotOwner.selector);
        ai.withdrawFees(payable(user));
    }
}
