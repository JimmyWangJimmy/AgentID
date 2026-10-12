# AgentID Demo

**Live:** https://jimmywangjimmy.github.io/AgentID/

## How to watch (30s)

1. Open fullscreen.
2. Leave **Auto demo** on — every ~8s it flips **Raw average ↔ Trust-weighted**.
3. Watch the punchline:
   - **Raw:** SybilBot billboard shows **4.00**; pink puppet edges glow on the ring graph.
   - **Weighted:** Sybil’s number **animates down 4.00 → 1.22**, EXPOSED badge fires, puppet edges dim, cyan seed edge dominates — the ring collapses.
4. GoodBot stays high (~4.66→4.69); FakeBot stays low (~1.50→1.44).

## What’s on the page

| Visual | Role |
|--------|------|
| Dual-mode scoreboard | Billboard scores + gauges; Raw↔Weighted toggle |
| Sybil ring (canvas force graph) | 3 puppets ★5 (w=10) + seed flag ★1 (w=500) |
| Δ chart | weighted − raw; Sybil’s −2.78 in warning red |
| LIVE RPC | `eth_call` to scorer on Monad testnet (falls back to ONCHAIN.md cache) |

## On-chain proof

- Scorer: [`0x8916357EDB7598d20E257404213CF3D1C099c310`](https://testnet.monadvision.com/address/0x8916357EDB7598d20E257404213CF3D1C099c310)
- GoodBot raw/w **466/469** · FakeBot **150/144** · SybilBot **400/122**
- ERC-8004 Identity ids: Good **#2204** · Fake **#2205** · Sybil **#2206**

Details: [`docs/ONCHAIN.md`](./docs/ONCHAIN.md) · research: [`docs/RESEARCH.md`](./docs/RESEARCH.md)

## Video

Optional clip: [`docs/AgentID-demo-1min.mp4`](./docs/AgentID-demo-1min.mp4) — prefer the live Pages demo for the animated Raw→Weighted drop.
