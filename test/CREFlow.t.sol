// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/DeFiVault.sol";
import "../src/RiskOracle.sol";
import "../src/AIAnalyzer.sol";
import "../src/RiskCoordinator.sol";

contract CREFlowTest is Test {
    DeFiVault vault;
    RiskOracle oracle;
    AIAnalyzer ai;
    RiskCoordinator coordinator;

    address user = address(0xBEEF);

    function setUp() public {
        vault = new DeFiVault();
        oracle = new RiskOracle();
        ai = new AIAnalyzer();
        coordinator = new RiskCoordinator(
            address(oracle),
            address(ai)
        );

        oracle.setReporter(address(coordinator));

        vm.deal(user, 50 ether);
    }

    function testPaidAIWorkflow() public {
        vm.startPrank(user);

        vault.deposit{value: 30 ether}();
        vault.withdraw(9 ether); // 30%

        coordinator.handleRisk{value: 0.01 ether}(
            user,
            9 ether,
            30 ether
        );

        vm.stopPrank();

        IRiskOracle.RiskReport memory report =
            oracle.getLatestReport(user);

        assertEq(report.riskLevel, 80);
    }

    function testRiskOracleInvalidRiskLevel() public {
        vm.prank(address(coordinator));
        vm.expectRevert(RiskOracle.InvalidRiskLevel.selector);
        oracle.submitRiskReport(user, 101);
    }

    function testRiskOracleGetLatestReportNoReport() public view {
        IRiskOracle.RiskReport memory report = oracle.getLatestReport(user);
        assertEq(report.reportId, 0);
        assertEq(report.timestamp, 0);
        assertEq(report.riskLevel, 0);
        assertEq(report.summary, "No report available");
    }

    function testRiskCoordinatorInvalidRiskLevel() public {
        // Mock AIAnalyzer to return riskLevel > 100 to trigger the revert in RiskCoordinator
        vm.mockCall(
            address(ai),
            abi.encodeWithSelector(AIAnalyzer.analyzeRisk.selector, 9 ether, 30 ether),
            abi.encode(101)
        );

        vm.prank(user);
        vm.expectRevert(RiskCoordinator.InvalidRiskLevel.selector);
        coordinator.handleRisk{value: 0.01 ether}(user, 9 ether, 30 ether);

        vm.clearMockedCalls();
    }
}
