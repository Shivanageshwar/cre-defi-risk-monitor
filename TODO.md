# TODO: Improve Code Coverage

## 1. Add tests for AIAnalyzer.sol
- [x] Cover both risk level branches (low and high risk)
- [x] Test withdrawFees function
- [x] Test error cases (InsufficientPayment, InvalidVaultBalance, NotOwner)

## 2. Add tests for RiskOracle.sol
- [x] Test invalid risk level submission (revert InvalidRiskLevel)
- [x] Test getLatestReport with no reports (return default report)

## 3. Add test for RiskCoordinator.sol
- [x] Trigger InvalidRiskLevel revert in handleRisk (using mock to return riskLevel > 100)

## 4. Add test for DeFiVault.sol
- [x] Test receive function

## 5. Run coverage again to verify improvements
- [x] Execute `forge coverage` and check improvements
