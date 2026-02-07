// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/DefiVault.sol";

contract DeFiVaultTest is Test {
    DeFiVault vault;

    function setUp() public {
        vault = new DeFiVault();
    }

    receive() external payable {}

    function testDeposit() public {
        vm.deal(address(this), 1 ether);
        vault.deposit{value: 1 ether}();
        assertEq(vault.balances(address(this)), 1 ether);
        assertEq(vault.totalDeposits(), 1 ether);
    }

    function testWithdraw() public {
        vm.deal(address(this), 1 ether);
        vault.deposit{value: 1 ether}();
        vault.withdraw(0.5 ether);
        assertEq(vault.balances(address(this)), 0.5 ether);
        assertEq(vault.totalDeposits(), 0.5 ether);
    }

    function testWithdrawInsufficientFunds() public {
        vm.expectRevert(DeFiVault.InsufficientFunds.selector);
        vault.withdraw(1 ether);
    }

    function testDepositZero() public {
        vm.expectRevert(DeFiVault.ZeroAmount.selector);
        vault.deposit{value: 0}();
    }

    function testLargeWithdrawalEvent() public {
        vm.deal(address(this), 1 ether);
        vault.deposit{value: 1 ether}();
        // Withdraw 50% which is > 30%, should emit LargeWithdrawal
        vm.expectEmit(true, true, false, true);
        emit DeFiVault.LargeWithdrawal(address(this), 0.5 ether, 0.5 ether);
        vault.withdraw(0.5 ether);
    }

    function testReceiveFunction() public {
        uint256 initialBalance = vault.balances(address(this));
        uint256 initialTotal = vault.totalDeposits();

        (bool success,) = address(vault).call{value: 1 ether}("");
        require(success, "Receive failed");

        assertEq(vault.balances(address(this)), initialBalance + 1 ether);
        assertEq(vault.totalDeposits(), initialTotal + 1 ether);
    }
}
