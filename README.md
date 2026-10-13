# AgentID — Anti-Sybil aggregator for ERC-8004 on Monad

**Problem:** Open agent feedback is Sybil-cheap. A sockpuppet ring can inflate raw averages and fool any gate that trusts the mean.

**What we shipped:** Official ERC-8004 Identity + Reputation feedback on Monad testnet, plus AgentID — an EigenTrust-lite **weighted** scorer that exposes the ring. Same signals. Different trust function.

| | Raw average | AgentID weighted | Verdict |
|--|-------------|------------------|---------|
| **GoodBot** (#2204) | 4.66 | **4.69** | **GRANT** |
| **FakeBot** (#2205) | 1.50 | **1.44** | **CAUTION** |
| **SybilBot** (#2206) | 4.00 | **1.22** | **DENY** |

Punchline: SybilBot fools raw (4.00). Weighted collapses it (1.22).

## 30-second demo

1. Open **https://jimmywangjimmy.github.io/AgentID/**
2. Leave **Judge Mode** on (default) — ~60s autopilot: Problem → 8004 feedback → raw fool → weighted expose → GRANT / CAUTION / DENY.
3. Or hit **Replay**.

## Paste links

| Field | Value |
|-------|-------|
| **Repo** | https://github.com/JimmyWangJimmy/AgentID |
| **Demo** | https://jimmywangjimmy.github.io/AgentID/ |
| **Video** | https://jimmywangjimmy.github.io/AgentID/AgentID-demo-1min.mp4 |
| **AgentID scorer** | [`0x8916357EDB7598d20E257404213CF3D1C099c310`](https://testnet.monadvision.com/address/0x8916357EDB7598d20E257404213CF3D1C099c310) |
| **8004 Identity** | [`0x8004A818…BD9e`](https://testnet.monadvision.com/address/0x8004A818BFB912233c491871b3d84c89A494BD9e) |
| **8004 Reputation** | [`0x8004B663…8713`](https://testnet.monadvision.com/address/0x8004B663056A597Dffe9eCcC1965A193B7388713) |

## Honest limitation

Colluding **high-weight** attesters can still bias the score (same class of honesty as other crypto-economic trust demos). AgentID discounts *fresh* sockpuppets, not a cartel of already-trusted wallets. Validation Registry / bonds left for later.

## Docs

- [`docs/ONCHAIN.md`](./docs/ONCHAIN.md) — addresses, txs, verify commands  
- [`docs/ADAPTER.md`](./docs/ADAPTER.md) — dual-path 8004 ↔ AgentID  
- [`docs/RESEARCH.md`](./docs/RESEARCH.md) — track research  
- [`DEMO.md`](./DEMO.md) — Judge Mode how-to  

```bash
npm test && forge test -vv
```

**Jimmy Wang** · Metropolis · Trust / Identity & AI Infrastructure · MIT
