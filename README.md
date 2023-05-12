# HeraAggregatorV2-Contracts
Router and side-contracts of Hera Dex Aggregator v2

Aggregator Router v2: 0x0000000000924fb1969e719edeD2feD54AFB183A

- Metis: https://andromeda-explorer.metis.io/address/0x0000000000924fb1969e719edeD2feD54AFB183A
- Arbitrum: https://arbiscan.io/address/0x0000000000924fb1969e719edeD2feD54AFB183A

Hera Fee Sequencer v2: 0x000000fEe322aAA0a5772e7F92DE10180f9fAB15

- Metis: https://andromeda-explorer.metis.io/address/0x000000fEe322aAA0a5772e7F92DE10180f9fAB15
- Arbitrum: https://arbiscan.io/address/




# Audit Reports

#Audited by HashEx

Report URL: 


 

# Governance & Ownerships

MultiSig (safe-core-sdk):
- Metis: https://andromeda-explorer.metis.io/address/0xE089A4EFa2dA690f21a3ea682cb36Dc4AC007995
- Arbitrum: https://arbiscan.io/address/0xca0dfc4e1935ffa0019aa760db0564b8cdd96e6e

HeraSecurity (Timelock) (HeraSecurity.sol):
- Metis: https://andromeda-explorer.metis.io/address/0x6da6317e819d6a19c28f0a59291F85FB41b02225
- Arbitrum: https://arbiscan.io/address/0xCE3759244610Fc69F95db143338c9ED0Dc356fd0
  - proposers, executors = MultiSig


Router: Will be deployed then audit progress is completed.
- Owner: Multisig

HeraExecutor: Will be deployed then audit progress is completed.
- Owner: Timelock

HeraFeeSequencer: Will be deployed then audit progress is completed.
- Manager: Multisig
- DefaultAdmin: Timelock

HeraFeeSequencer constructors => [ownerAddr, managerAddr, powerAddr]
- ownerAddr: Timelock
- managerAddr: Multisig



