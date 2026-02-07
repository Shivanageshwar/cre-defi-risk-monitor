// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "../src/interfaces/IRiskOracle.sol";
import "../src/AIAnalyzer.sol";

contract RiskCoordinator {
    error InvalidRiskLevel();

    IRiskOracle public immutable oracle;
    AIAnalyzer public immutable aiAnalyzer;

    event RiskHandled(
        address indexed user,
        uint256 withdrawalAmount,
        uint256 vaultBalance,
        uint256 riskLevel
    );

    constructor(address _oracle, address _aiAnalyzer) {
        oracle = IRiskOracle(_oracle);
        aiAnalyzer = AIAnalyzer(_aiAnalyzer);
    }

    function handleRisk(
        address user,
        uint256 withdrawalAmount,
        uint256 vaultBalance
    ) external payable {
        uint256 riskLevel =
            aiAnalyzer.analyzeRisk{value: msg.value}(
                withdrawalAmount,
                vaultBalance
            );

        if (riskLevel > 100) revert InvalidRiskLevel();

        oracle.submitRiskReport(user, riskLevel);

        emit RiskHandled(
            user,
            withdrawalAmount,
            vaultBalance,
            riskLevel
        );
    }
}
