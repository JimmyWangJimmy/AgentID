# AgentID — Claude Code brief

**Hackathon:** Monad Metropolis · Trust / Identity & AI Infrastructure  
**Deadline:** ~2026-10-14 11:59 Asia/Shanghai  
**Author:** Jimmy Wang · MIT

## Product
Minimal ERC-8004-inspired registry: `registerAgent` → `attest` → `getReputation`.

## Reputation policy
- Attestation score: integer **1–5**
- Aggregated score: **sum** of attestation scores
- Documented in README and `src/registry.ts`

## Primary demo (always works)
```bash
npm install
npm test
npm run demo
```
TypeScript in-memory registry + CLI. No deploy, no spend.

## Solidity (secondary)
- `contracts/IAgentRegistry.sol` — interface
- `contracts/AgentRegistry.sol` — implementation (same score policy)
- `contracts/AgentRegistry.t.sol` — Foundry tests
- When forge available: `forge install foundry-rs/forge-std` then `forge test`

## Do not
Full ERC-8004, marketplace, paid mainnet deploy, heavy frontend.

## Done when
`npm test` passes and `npm run demo` prints register → attest → score clearly.
