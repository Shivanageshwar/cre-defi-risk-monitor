// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../src/DeFiVault.sol";
import "../src/RiskOracle.sol";
import "../src/AIAnalyzer.sol";
import "../src/RiskCoordinator.sol";

contract SimulateCRE is Script {
    function run() public {
        address user = 0x976EA74026E726554dB657fA54763abd0C3a0aa9;

        vm.deal(user, 50 ether);
        vm.startBroadcast(user);

        // Deploy CRE components
        RiskOracle oracle = new RiskOracle();
        AIAnalyzer ai = new AIAnalyzer();
        RiskCoordinator coordinator =
            new RiskCoordinator(address(oracle), address(ai));

        //  AUTHORIZE coordinator
        oracle.setReporter(address(coordinator));

        // Deploy vault
        DeFiVault vault = new DeFiVault();

        // --- User action ---
        vault.deposit{value: 30 ether}();

        uint256 withdrawalAmount = 9 ether;
        vault.withdraw(withdrawalAmount);

        // --- CRE orchestration ---
        coordinator.handleRisk{value: 0.01 ether}(
            user,
            withdrawalAmount,
            address(vault).balance + withdrawalAmount
        );

        vm.stopBroadcast();
    }
}
