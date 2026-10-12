# AgentID — On-chain Agent Identity & Reputation Registry on Monad

**ERC-8004-inspired agent identity + attestation-based reputation for Trust / Identity & AI Infrastructure.**

> AI agents operate across apps and chains without a shared identity or reputation layer. AgentID is a minimal registry: register an identity, accumulate attestations, and expose a portable reputation score. Primary demo is an in-memory TypeScript mock (always works); Solidity sources ship for Monad testnet when you are ready.

| | |
|---|---|
| **Hackathon** | Monad Metropolis |
| **Track** | Trust / Identity & AI Infrastructure |
| **Builder** | Jimmy Wang · Tsinghua CS + Linguistics (MSc) · Shenzhen · AI Agents |
| **License** | MIT |

---

## Problem

Agents act across apps and chains, but have **no shared, portable identity or reputation**. Each platform keeps a siloed account; trust resets at every new integration; spam and impersonation are cheap.

## Solution

A shippable subset of an ERC-8004-style agent registry:

1. **Identity** — `registerAgent(metadataURI)` → unique `agentId` bound to an owner wallet.
2. **Attestations** — peers/humans call `attest(agentId, score, tag, uri)` with evidence.
3. **Reputation view** — anyone calls `getReputation(agentId)` for a portable score.

### Reputation policy

| Rule | Value |
|------|--------|
| Attestation score | Integer **1–5** (clamped; out of range rejected) |
| Aggregated score | **Sum** of all attestation scores for that agent |
| Count | Number of attestations |

Same policy in TypeScript mock and Solidity `AgentRegistry`.

## Architecture

```
┌─────────────┐     registerAgent(uri)      ┌──────────────────────┐
│  Agent /    │ ───────────────────────────► │  AgentID Registry    │
│  Owner      │                              │  (Monad / mock)       │
│  Wallet     │     attest(id, score, …)     │                      │
│             │ ───────────────────────────► │  • identities[]      │
└─────────────┘                              │  • attestations[]    │
                                             │  • getReputation()   │
┌─────────────┐     getReputation(id)        └──────────────────────┘
│  Consumer / │ ◄───────────────────────────         │
│  Another    │   score + attestation count          │
│  Agent      │                                      ▼
└─────────────┘                              Explorer / CLI / demo UI
```

## How to run (primary demo)

Requires Node.js ≥ 18. **No wallet, no deploy, no spend.**

```bash
cd AgentID
npm install
npm test          # vitest — must pass
npm run demo      # register → attest → getReputation walkthrough
```

Expected demo shape:

1. `registerAgent` → `agentId = 1`
2. Second wallet `attest(..., score=5, tag=reliable, ...)`
3. `getReputation` → `{ score: 5, count: 1 }`

Screen-recording tips: see [`DEMO.md`](./DEMO.md).

## Solidity (optional / secondary)

Interfaces and a minimal implementation live under `contracts/`:

- `IAgentRegistry.sol` — interface sketch
- `AgentRegistry.sol` — implementation (score 1–5, sum aggregation)
- `AgentRegistry.t.sol` — Foundry tests

When [Foundry](https://book.getfoundry.sh/) is installed:

```bash
forge install foundry-rs/forge-std
forge test
```

Deploy to Monad testnet is **not** required for submission demo. Paste address here after deploy:

```
Contract: TBD
Explorer: TBD
```

## Repo layout

```
AgentID/
  README.md
  DEMO.md
  CLAUDE.md
  LICENSE
  package.json
  src/registry.ts       # in-memory registry
  src/cli-demo.ts       # npm run demo
  test/registry.test.ts
  contracts/            # Solidity interface + impl + forge tests
  docs/metropolis-brief.md
```

## License

MIT

## Author

**Jimmy Wang** — Tsinghua University (CS + Linguistics, MSc) · Shenzhen · building AI agents  
Metropolis · Trust / Identity & AI Infrastructure · solo

---

*Minimal, shippable foundation — not a full marketplace. Polish after submit.*

<!-- 中文摘要：AgentID 是受 ERC-8004 启发的最小 Agent 身份与信誉登记：注册、背书、查询可迁移信誉分。主演示为 TypeScript 内存 mock（npm run demo）；合约源码在 contracts/。赛道 Trust/Identity & AI Infrastructure。Jimmy Wang。 -->
