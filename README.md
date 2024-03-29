# HeraAggregatorV2-Contracts
Router and side-contracts of Hera Dex Aggregator v2

HeraAggregatorV2: Router

- Metis: https://andromeda-explorer.metis.io/address/0x0000000000924fb1969e719edeD2feD54AFB183A
- Arbitrum: https://arbiscan.io/address/0x0000000000924fb1969e719edeD2feD54AFB183A

Hera Executor

- Metis: https://andromeda-explorer.metis.io/address/0x765fa67B25fc801F7802604F7326c215c3a973A0
- Arbitrum: https://arbiscan.io/address/0x1bd717c5cDd133E1985628e1e194B0ED9C9047E7

Metis - HeraFeeSequencer

- Metis: https://andromeda-explorer.metis.io/address/0x000000fEe322aAA0a5772e7F92DE10180f9fAB15

Arbitrum - HeraFeeSequencer

- Arbitrum: https://arbiscan.io/address/0x699127412aC7304F3897F410974677F747f2e9DF




# Audit Reports

#Audited by HashEx

Report URL: https://docs.hera.finance/audits


 

# Governance & Ownerships

MultiSig (safe-core-sdk):
- Metis: https://andromeda-explorer.metis.io/address/0xE089A4EFa2dA690f21a3ea682cb36Dc4AC007995
- Arbitrum: https://arbiscan.io/address/0xCA0dfC4e1935fFa0019AA760DB0564b8CDD96e6E

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



