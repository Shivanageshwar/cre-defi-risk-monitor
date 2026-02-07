// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/DeFiVault.sol";

contract DeFiVaultFuzzTest is Test {
    DeFiVault vault;
    address user = address(0xA11CE);

    function setUp() public {
        vault = new DeFiVault();
        vm.deal(user, 100 ether);
    }

    function testFuzz_DepositWithdraw(uint256 depositAmount, uint256 withdrawAmount) public {
        depositAmount = bound(depositAmount, 1 wei, 50 ether);
        withdrawAmount = bound(withdrawAmount, 1, depositAmount);

        vm.startPrank(user);

        vault.deposit{value: depositAmount}();
        vault.withdraw(withdrawAmount);

        vm.stopPrank();

        assertEq(
            vault.balances(user),
            depositAmount - withdrawAmount
        );

        assertEq(
            vault.totalDeposits(),
            depositAmount - withdrawAmount
        );
    }
    function testFuzz_WithdrawMoreThanBalance(uint256 amount) public {
    amount = bound(amount, 1 wei, 100 ether);

    vm.prank(user);
    vm.expectRevert(DeFiVault.InsufficientFunds.selector);
    vault.withdraw(amount);
}
function testFuzz_ZeroDeposit(uint256 value) public {
    value = 0;

    vm.prank(user);
    vm.expectRevert(DeFiVault.ZeroAmount.selector);
    vault.deposit{value: value}();
}

function testFuzz_LargeWithdrawalEvent(uint256 withdrawAmount) public {
    vm.startPrank(user);
    vault.deposit{value: 10 ether}();

    withdrawAmount = bound(withdrawAmount, 3 ether, 10 ether);

    vm.expectEmit(true, true, true, true);
    emit DeFiVault.LargeWithdrawal(
        user,
        withdrawAmount,
        10 ether - withdrawAmount
    );

    vault.withdraw(withdrawAmount);
    vm.stopPrank();
}
}
