# AgentID — Demo guide for judges

**Primary surface:** https://jimmywangjimmy.github.io/AgentID/  
(GitHub Pages serves `docs/index.html`. `docs/demo.html` is kept in sync.)

## 60-second presentation

1. **Fullscreen** the Pages demo (1280+ wide looks best).
2. Click **SybilBot** first — or let the auto-play story reach step 3–4.
3. Point at the dual meters: **raw 4.00** (amber) vs **weighted 1.22** (red) + the **EXPOSED** ribbon.
4. Contrast with GoodBot (both high) and FakeBot (both low).
5. Show the **LIVE** / **CACHED** badge — live = `eth_call` to Monad RPC; cached = explorer-verified numbers from `docs/ONCHAIN.md`.
6. Optional: Copy contract address from the proof strip → open MonadVision.

Keyboard: `1`–`4` jump story steps · `Space` play/pause.

## Punchline

> ERC-8004 gives public feedback. AgentID is the anti-Sybil aggregator — a sockpuppet ring looks fine on **raw 4.00**, then **dies at weighted 1.22**.

| Agent | Official 8004 | Raw | Weighted |
|-------|---------------|-----|----------|
| GoodBot | #2204 | 4.66 | 4.69 |
| FakeBot | #2205 | 1.50 | 1.44 |
| SybilBot | #2206 | **4.00** | **1.22** |

Scorer: `0x8916357EDB7598d20E257404213CF3D1C099c310` (Monad testnet 10143).

## Assets

| Asset | Link |
|-------|------|
| Interactive HTML (primary) | [Pages](https://jimmywangjimmy.github.io/AgentID/) · [`docs/index.html`](./docs/index.html) |
| MP4 (optional) | [`docs/AgentID-demo-1min.mp4`](./docs/AgentID-demo-1min.mp4) — may lag the new UI; prefer HTML |
| CLI walkthrough | `npm run demo` |

Regenerate video (optional): `python3 docs/generate_demo_video.py` if Pillow/ffmpeg available.

## Design notes (v4 demo)

Inspired by (patterns reimplemented, not copied):

- **TrustGate** (calderbuild) — wallet-free live agent cards + clear verdict
- **AgentTrust** — three seeded agents, ALLOW/DENY contrast table
- **8004 explorers / Dark Web3 landings** — dark violet/cyan hero, Inter + mono numbers, proof strip with copy

No MOCK energy: product UI, live RPC with graceful cache fallback.
