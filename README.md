# AgentID — On-chain Agent Identity & Reputation Registry on Monad

**ERC-8004-inspired agent identity + sybil-lite attestation reputation for Trust / Identity & AI Infrastructure.**

## Why AgentID

1. **Sybil-lite attestations** — no self-attest; one vote per attester (overwrite, not spam-sum).
2. **Portable average reputation** — `getReputation` returns average ×100 + count + unique attesters, so agents can carry trust across apps.
3. **Live on Monad testnet** with a **GoodBot vs FakeBot** seeded story and explorer proof — judges can verify the contrast on-chain.

| | |
|---|---|
| **Hackathon** | Monad Metropolis |
| **Track** | Trust / Identity & AI Infrastructure |
| **Builder** | Jimmy Wang · Tsinghua CS + Linguistics (MSc) · Shenzhen · AI Agents |
| **License** | MIT |

---

## The highlight: GoodBot vs FakeBot

Two agents both claim to be helpful. Without portable reputation you cannot tell which to trust.

| | **GoodBot** (#1) | **FakeBot** (#2) |
|---|---|---|
| Metadata | `ipfs://agentid/good-bot` | `ipfs://agentid/fake-bot` |
| Attestations | 5 / 5 / 4 · reliable / helpful / on-time | 1 / 2 · spam / impersonation |
| **Average ×100** | **466** (4.66) | **150** (1.50) |
| Unique attesters | 3 | 2 |

Same API for both. Headline metric is **average**, not a sum attackers can inflate.

### Policy (Solidity + TypeScript, same semantics)

| Rule | Behavior |
|------|----------|
| Score range | Integer **1–5** |
| No self-attest | Agent owner cannot attest their own agent |
| One vote / attester | Second attest from same address **overwrites** |
| Reputation | `(averageScoreX100, count, uniqueAttesters)` — e.g. 4.5 → `450` |

---

## Live on Monad testnet

| | |
|---|---|
| **Chain** | Monad Testnet · id `10143` |
| **RPC** | `https://testnet-rpc.monad.xyz` |
| **Contract** | [`0xDCcBbFFC7D0912674760579fAba210a2a729f859`](https://testnet.monadvision.com/address/0xDCcBbFFC7D0912674760579fAba210a2a729f859) |
| **Deploy tx** | [`0xbf6e15f6…`](https://testnet.monadvision.com/tx/0xbf6e15f64d19b8ac558a2c5a93d9f2fb12de2f9c8facdd90966ef694f412a3ab) |
| **GoodBot register** | [`0x830a1a87…`](https://testnet.monadvision.com/tx/0x830a1a87b1cbeacbf321d9284db4b876de9198e77b1a7ca29d7b8e2ca4995f0c) |
| **FakeBot register** | [`0x4c583cef…`](https://testnet.monadvision.com/tx/0x4c583cef5f4a1db9348c39906acc821b1872e769f1a96b54531faf175c917ede) |
| **Explorer** | [MonadVision](https://testnet.monadvision.com/address/0xDCcBbFFC7D0912674760579fAba210a2a729f859) |
| **Superseded** | Old demo `0x7Be01cFC…ad13` (pre sybil-lite / average) |

Full deploy + seed notes: [`docs/ONCHAIN.md`](./docs/ONCHAIN.md).

---

## Demo (submission-ready)

| Asset | Link |
|-------|------|
| **Interactive HTML** (primary) | [`docs/demo.html`](./docs/demo.html) · [GitHub Pages](https://jimmywangjimmy.github.io/AgentID/) |
| **1-min MP4** | [`docs/AgentID-demo-1min.mp4`](./docs/AgentID-demo-1min.mp4) · [raw](https://raw.githubusercontent.com/JimmyWangJimmy/AgentID/main/docs/AgentID-demo-1min.mp4) |
| Recording notes | [`DEMO.md`](./DEMO.md) |

```bash
cd AgentID
npm install
npm test          # vitest — sybil-lite + average + good-vs-fake
npm run demo      # GoodBot vs FakeBot CLI walkthrough
open docs/demo.html
```

---

## Architecture

```
┌─────────────┐     registerAgent(uri)      ┌──────────────────────┐
│  Agent /    │ ───────────────────────────► │  AgentID Registry    │
│  Owner      │                              │  (Monad / mock)       │
│  Wallet     │     attest(id, score, …)     │                      │
│             │ ───────────────────────────► │  • no self-attest    │
└─────────────┘                              │  • 1 vote / attester │
                                             │  • average ×100      │
┌─────────────┐     getReputation(id)        └──────────────────────┘
│  Consumer / │ ◄───────────────────────────         │
│  Another    │   avg×100 + count + unique           ▼
│  Agent      │                              Explorer / HTML / CLI
└─────────────┘
```

## On-chain path (Foundry)

```bash
forge test -vv
# deploy + seed: see docs/ONCHAIN.md
```

- `contracts/IAgentRegistry.sol` / `AgentRegistry.sol`
- `script/Deploy.s.sol` · `script/Seed.s.sol` (GoodBot vs FakeBot)

## Repo layout

```
AgentID/
  README.md · DEMO.md
  src/registry.ts · src/cli-demo.ts
  test/registry.test.ts
  contracts/                   # Solidity + forge tests
  script/Deploy.s.sol · Seed.s.sol
  docs/demo.html · index.html · ONCHAIN.md · AgentID-demo-1min.mp4
```

## License

MIT

## Author

**Jimmy Wang** — Tsinghua University (CS + Linguistics, MSc) · Shenzhen · building AI agents  
Metropolis · Trust / Identity & AI Infrastructure · solo

---

*Shippable foundation with a clear differentiator: sybil-lite average reputation + live good-vs-fake proof.*

<!-- 中文摘要：AgentID 在 Monad 上提供 sybil-lite 的 Agent 身份与平均信誉：禁止自证、一票一地址、平均分×100。链上已播种 GoodBot vs FakeBot。赛道 Trust/Identity。Jimmy Wang。 -->
