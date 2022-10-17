# HeraAggregatorV2-Contracts
Router and side-contracts of Hera Dex Aggregator v2

#Mainnet: Metis

Aggregator Router v2: 0x0000000000924fb1969e719edeD2feD54AFB183A

- https://andromeda-explorer.metis.io/address/0x0000000000924fb1969e719edeD2feD54AFB183A

Hera Fee Sequencer v2: 0x000000fEe322aAA0a5772e7F92DE10180f9fAB15

- https://andromeda-explorer.metis.io/address/0x000000fEe322aAA0a5772e7F92DE10180f9fAB15

Executor: 0x852d1fDd3982D8e21145845af74Db7ae37D1F383

- https://andromeda-explorer.metis.io/address/0x852d1fDd3982D8e21145845af74Db7ae37D1F383

 
 

# Audit Reports

#Audited by HashEx

Report URL: 


 

# Governance & Ownerships

MultiSig (safe-core-sdk):
- https://andromeda-explorer.metis.io/address/0xE089A4EFa2dA690f21a3ea682cb36Dc4AC007995

HeraSecurity (Timelock) (HeraSecurity.sol):
- https://andromeda-explorer.metis.io/address/0x6da6317e819d6a19c28f0a59291F85FB41b02225
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



