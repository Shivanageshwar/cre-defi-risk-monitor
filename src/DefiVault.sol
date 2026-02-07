// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "../src/interfaces/IDefiVault.sol";

/// @title DeFi Vault Contract
/// @notice A simple ETH vault emitting risk signals for CRE workflows
contract DeFiVault is IDeFiVault {
    /// @notice Emitted when a deposit is made
    event Deposit(address indexed user, uint256 amount);

    /// @notice Emitted when a large withdrawal occurs
    event LargeWithdrawal(address indexed user, uint256 amount, uint256 remainingBalance);

    error ZeroAmount();
    error InsufficientFunds();
    error TransferFailed();

    mapping(address => uint256) public balances;

    /// @notice Large withdrawal threshold (percentage)
    uint256 public constant LARGE_WITHDRAWAL_THRESHOLD = 30;

    function totalDeposits() public view returns (uint256) {
        return address(this).balance;
    }

    function deposit() external payable override {
        if (msg.value == 0) revert ZeroAmount();

        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external override {
        uint256 userBalance = balances[msg.sender];
        if (amount == 0 || amount > userBalance) revert InsufficientFunds();

        uint256 vaultBalanceBefore = address(this).balance;

        // Effects
        balances[msg.sender] = userBalance - amount;

        // Interactions
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();

        // Emit risk signal
        if (
            vaultBalanceBefore > 0 &&
            (amount * 100) / vaultBalanceBefore >= LARGE_WITHDRAWAL_THRESHOLD
        ) {
            emit LargeWithdrawal(msg.sender, amount, address(this).balance);
        }
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
}
