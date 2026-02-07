// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import "../src/interfaces/IRiskOracle.sol";

/// @title Risk Oracle
/// @notice Stores latest CRE-generated risk reports per user
/// @dev Reporter is expected to be the RiskCoordinator
contract RiskOracle is IRiskOracle {
    mapping(address => RiskReport) private reports;

    address public admin;
    address public reporter;

    error Unauthorized();
    error InvalidRiskLevel();
    error InvalidReporter();

    event ReporterUpdated(address indexed oldReporter, address indexed newReporter);

    constructor() {
        admin = msg.sender;
        reporter = msg.sender; // temporary until coordinator is set
    }

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Unauthorized();
        _;
    }

    modifier onlyReporter() {
        if (msg.sender != reporter) revert Unauthorized();
        _;
    }

    function submitRiskReport(
        address user,
        uint256 riskLevel
    ) external override onlyReporter {
        if (riskLevel > 100) revert InvalidRiskLevel();

        uint256 id = block.timestamp;

        reports[user] = RiskReport({
            reportId: id,
            timestamp: id,
            riskLevel: riskLevel,
            summary: "CRE automated risk assessment"
        });

        emit RiskReportSubmitted(user, id, riskLevel);
    }

    function getLatestReport(
        address user
    ) external view override returns (RiskReport memory) {
        RiskReport memory report = reports[user];
        if (report.timestamp == 0) {
            return RiskReport({
                reportId: 0,
                timestamp: 0,
                riskLevel: 0,
                summary: "No report available"
            });
        }
        return report;
    }

    /// @notice Admin assigns reporter role (RiskCoordinator)
    function setReporter(address newReporter) external onlyAdmin {
        if (newReporter == address(0)) revert InvalidReporter();
        emit ReporterUpdated(reporter, newReporter);
        reporter = newReporter;
    }
}
