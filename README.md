# AgentID — Anti-Sybil Aggregator for ERC-8004 on Monad

**ERC-8004 publishes feedback. AgentID decides whom to believe.**

Metropolis Track *Trust / Identity & AI Infrastructure* · EigenTrust-lite weighted reputation · live Sybil-ring proof on Monad testnet.

> A sockpuppet ring looks fine on **raw** average — it **dies** on **trust-weighted** score.

Deep dive: [`docs/RESEARCH.md`](./docs/RESEARCH.md)

---

## Why AgentID (30s)

1. **ERC-8004-aligned** — registration-v1 JSON, CAIP-2 ids, dual-path to official IdentityRegistry on Monad testnet.
2. **EigenTrust-lite** — `getWeightedReputation` weights each attestation by the attester’s seed / one-hop unweighted reputation (not recursive).
3. **On-chain Sybil proof** — GoodBot / FakeBot / SybilBot with explorer links: Sybil raw **4.00** → weighted **1.22**.

| Rule | Behavior |
|------|----------|
| Score | Integer **1–5** |
| No self-attest | Owner cannot attest own agent |
| One vote / attester | Overwrite, not spam-sum |
| Raw | `getReputation` → avg ×100 |
| Weighted | `getWeightedReputation` → seed / earned-weight avg ×100 |

---

## Live proof (v3)

| | |
|---|---|
| **Chain** | Monad Testnet · `10143` |
| **AgentID scorer** | [`0x8916357EDB7598d20E257404213CF3D1C099c310`](https://testnet.monadvision.com/address/0x8916357EDB7598d20E257404213CF3D1C099c310) |
| **Official Identity** | [`0x8004A818…BD9e`](https://testnet.monadvision.com/address/0x8004A818BFB912233c491871b3d84c89A494BD9e) (CREATE2) |
| **Deploy tx** | [`0x24f5ef3e…`](https://testnet.monadvision.com/tx/0x24f5ef3e290ee44b2d3c4c75c60b0041f3a296f17db7237c6cd50ab90fe98031) |

| Agent | Scorer id | Official 8004 id | Raw ×100 | Weighted ×100 |
|-------|-----------|------------------|----------|---------------|
| **GoodBot** | 1 | 2204 | **466** | **469** |
| **FakeBot** | 2 | 2205 | **150** | **144** |
| **SybilBot** | 3 | 2206 | **400** | **122** ← dies |

Full tx map + dual-path docs: [`docs/ONCHAIN.md`](./docs/ONCHAIN.md).

Registration files (HTTPS / Pages):

- [`docs/agents/good-bot.json`](./docs/agents/good-bot.json)
- [`docs/agents/fake-bot.json`](./docs/agents/fake-bot.json)
- [`docs/agents/sybil-bot.json`](./docs/agents/sybil-bot.json)
- [`docs/registration-v1.json`](./docs/registration-v1.json)

---

## Metropolis paste-ready

| Field | Value |
|-------|-------|
| **Repo** | `https://github.com/JimmyWangJimmy/AgentID` |
| **Demo** | `https://jimmywangjimmy.github.io/AgentID/` |
| **Video** | `https://jimmywangjimmy.github.io/AgentID/AgentID-demo-1min.mp4` (HTML demo is primary) |
| **Contract** | `0x8916357EDB7598d20E257404213CF3D1C099c310` |

---

## Demo

| Asset | Link |
|-------|------|
| **Interactive HTML** (primary) | [GitHub Pages](https://jimmywangjimmy.github.io/AgentID/) · [`docs/index.html`](./docs/index.html) |
| MP4 | [`docs/AgentID-demo-1min.mp4`](./docs/AgentID-demo-1min.mp4) — regenerate optional; HTML tells the raw-vs-weighted story |

```bash
cd AgentID
npm install
npm test          # vitest — raw + weighted + sybil ring
npm run demo      # CLI walkthrough
forge test -vv    # Solidity mirror
open docs/index.html
```

---

## Architecture

```
 ERC-8004 Identity (official)          AgentID scorer (this repo)
 ┌─────────────────────────┐           ┌──────────────────────────────┐
 │ register(agentURI) NFT  │  dual-    │ registerAgent / attest       │
 │ agentId 2204/2205/2206  │  path     │ getReputation (raw avg)      │
 │ registration-v1 JSON    │◄─────────►│ getWeightedReputation        │
 └─────────────────────────┘           │   EigenTrust-lite one-hop    │
                                       └──────────────────────────────┘
```

Weight policy: seed/oracle weight (cap 500) → else max(BASE=10, unweighted avg×100 of attester’s owned agent) → else BASE. **Not** recursive weighted (classic EigenTrust-lite).

---

## Repo layout

```
AgentID/
  README.md · DEMO.md
  src/registry.ts · src/cli-demo.ts
  test/registry.test.ts
  contracts/AgentRegistry.sol · IAgentRegistry.sol · *.t.sol
  script/Deploy.s.sol · Seed.s.sol · Register8004.s.sol
  docs/demo.html · ONCHAIN.md · RESEARCH.md · agents/*.json
```

---

## Author

**Jimmy Wang** — Tsinghua University (CS + Linguistics, MSc) · Shenzhen · AI agents  
Metropolis · Trust / Identity & AI Infrastructure · solo · MIT

---

<!-- 中文：AgentID 是 Monad 上面向 ERC-8004 的反女巫信誉聚合器：原始均分 vs EigenTrust-lite 加权；链上 SybilRing 原始 4.00、加权 1.22。 -->
