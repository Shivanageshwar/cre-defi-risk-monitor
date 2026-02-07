// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title DeFi Vault Interface
/// @notice Interface for the DeFi Vault contract
interface IDeFiVault {
    /// @notice Deposit ETH into the vault
    function deposit() external payable;

    /// @notice Withdraw ETH from the vault
    /// @param amount The amount to withdraw
    function withdraw(uint256 amount) external;


}
