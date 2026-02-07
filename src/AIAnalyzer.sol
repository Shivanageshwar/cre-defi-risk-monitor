// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

contract AIAnalyzer {
    error InsufficientPayment();
    error InvalidVaultBalance();
    error NotOwner();

    uint256 public constant ANALYSIS_FEE = 0.01 ether;
    address public owner;

    event AnalysisPerformed(address indexed caller, uint256 riskLevel);
    event FeesWithdrawn(address indexed to, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function analyzeRisk(
        uint256 withdrawalAmount,
        uint256 vaultBalance
    ) external payable returns (uint256 riskLevel) {
        if (msg.value < ANALYSIS_FEE) revert InsufficientPayment();
        if (vaultBalance == 0) revert InvalidVaultBalance();

        if ((withdrawalAmount * 100) / vaultBalance >= 30) {
            riskLevel = 80;
        } else {
            riskLevel = 30;
        }

        if (riskLevel > 100) riskLevel = 100;

        emit AnalysisPerformed(msg.sender, riskLevel);
    }

    /// @notice Withdraw accumulated AI fees
    function withdrawFees(address payable to) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = to.call{value: balance}("");
        require(success, "ETH_TRANSFER_FAILED");
        emit FeesWithdrawn(to, balance);
    }
}
