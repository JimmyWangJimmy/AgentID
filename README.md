# AgentID — On-chain Agent Identity & Reputation Registry on Monad

**ERC-8004-inspired agent identity + attestation-based reputation for Trust / Identity & AI Infrastructure.**

> AI agents operate across apps and chains without a shared identity or reputation layer. AgentID is a minimal registry: register an identity, accumulate attestations, and expose a portable reputation score. TypeScript CLI demo always works offline; Solidity + Foundry target **Monad testnet** (chain id 10143).

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

## Demo (submission-ready)

Interactive ~60s walkthrough of **register → attest → getReputation** (UI mirrors the live registry; TypeScript path is in-memory):

| Asset | Link |
|-------|------|
| **Interactive HTML** | [`docs/demo.html`](./docs/demo.html) · [GitHub Pages](https://jimmywangjimmy.github.io/AgentID/) |
| **1-min MP4** (1280×720) | [`docs/AgentID-demo-1min.mp4`](./docs/AgentID-demo-1min.mp4) · [raw download](https://raw.githubusercontent.com/JimmyWangJimmy/AgentID/main/docs/AgentID-demo-1min.mp4) |
| Recording notes | [`DEMO.md`](./DEMO.md) |

```bash
# local HTML
open docs/demo.html   # or: python3 -m http.server -d docs 8080

# same flow in terminal
npm run demo
```

On-screen cues: `agentId: 1` → attest `score: 5` / `tag: reliable` → `getReputation` `score: 5` / `count: 1`. Live contract: [`0x7Be01cFC771fA2FD292113dA83881E0deC56ad13`](https://testnet.monadvision.com/address/0x7Be01cFC771fA2FD292113dA83881E0deC56ad13).

---
## On-chain (Monad testnet)

Solidity under `contracts/` + Foundry deploy script:

- `IAgentRegistry.sol` / `AgentRegistry.sol` — identity + attest + reputation (score 1–5, sum)
- `AgentRegistry.t.sol` — Foundry unit tests
- `script/Deploy.s.sol` — broadcast deploy
- Full steps: [`docs/ONCHAIN.md`](./docs/ONCHAIN.md)

```bash
forge install   # once
forge test -vv
# deploy (needs PRIVATE_KEY + faucet MON on Monad testnet 10143):
# forge script script/Deploy.s.sol:Deploy --rpc-url monad_testnet --broadcast -vvvv
```

| | |
|---|---|
| **Chain** | Monad Testnet · id `10143` |
| **RPC** | `https://testnet-rpc.monad.xyz` |
| **Faucet** | https://faucet.monad.xyz |
| **Contract** | [`0x7Be01cFC771fA2FD292113dA83881E0deC56ad13`](https://testnet.monadvision.com/address/0x7Be01cFC771fA2FD292113dA83881E0deC56ad13) |
| **Deploy tx** | [`0x01a0d4f5…`](https://testnet.monadvision.com/tx/0x01a0d4f55603dac0a7d9425f0fd75935fea732156a6604d06d59ba274f8c3cd1) |
| **Explorer** | [MonadVision](https://testnet.monadvision.com/address/0x7Be01cFC771fA2FD292113dA83881E0deC56ad13) · [Monadscan](https://testnet.monadscan.com/address/0x7Be01cFC771fA2FD292113dA83881E0deC56ad13) |
| **Deployer** | ephemeral hackathon wallet `0xE713…3F41` (do not send mainnet funds) |

## Repo layout

```
AgentID/
  README.md
  DEMO.md
  CLAUDE.md
  LICENSE
  package.json
  src/registry.ts              # in-memory registry
  src/cli-demo.ts              # npm run demo
  test/registry.test.ts
  contracts/                   # Solidity interface + impl + forge tests
  docs/
    demo.html / index.html     # interactive ~60s autoplay demo
    AgentID-demo-1min.mp4      # 1280×720 submission video
    metropolis-brief.md
    generate_demo_video.py     # rebuild MP4 from frames
```

## License

MIT

## Author

**Jimmy Wang** — Tsinghua University (CS + Linguistics, MSc) · Shenzhen · building AI agents  
Metropolis · Trust / Identity & AI Infrastructure · solo

---

*Minimal, shippable foundation — not a full marketplace. Polish after submit.*

<!-- 中文摘要：AgentID 是受 ERC-8004 启发的最小 Agent 身份与信誉登记：注册、背书、查询可迁移信誉分。主演示为 TypeScript 内存 mock（npm run demo）；合约源码在 contracts/。赛道 Trust/Identity & AI Infrastructure。Jimmy Wang。 -->
