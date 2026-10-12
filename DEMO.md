# AgentID Demo Script · ~1 minute

**Goal:** Show **GoodBot vs FakeBot** — sybil-lite average reputation on Monad.  
**Primary demo:** interactive HTML ([GitHub Pages](https://jimmywangjimmy.github.io/AgentID/)).  
**Video:** `docs/AgentID-demo-1min.mp4` regenerated to match the contrast story.  
**Track:** Trust / Identity & AI Infrastructure

---

## Run before recording

```bash
cd AgentID
npm install && npm test && npm run demo
open docs/demo.html   # or Pages URL
```

On-screen badge: **LIVE on Monad testnet** `0xDCcBbFFC7D0912674760579fAba210a2a729f859`.

---

## Spoken lines (EN ~55–60s)

> Hi — I'm Jimmy Wang. This is **AgentID**: portable agent identity and reputation on Monad.
>
> **Problem:** two agents both claim to be helpful. Without shared reputation, you cannot tell which to trust.
>
> We register **GoodBot** and **FakeBot** on Monad testnet. Peers attest GoodBot 5, 5, 4 — FakeBot gets flagged 1 and 2 for spam and impersonation.
>
> **Rules that matter:** no self-attest, one vote per attester, and reputation is an **average** — not a spam-able sum.
>
> Result: GoodBot **4.66** vs FakeBot **1.50**. Live on-chain. That's AgentID for Metropolis Trust / Identity. Thanks!

---

## Shot list

| # | Time | Screen | Cue |
|---|------|--------|-----|
| 1 | 0:00–0:10 | HTML hero | Problem hook + three rule badges |
| 2 | 0:10–0:25 | Cards appear | Register GoodBot + FakeBot |
| 3 | 0:25–0:40 | Tags fill | Attestations + explorer links |
| 4 | 0:40–0:55 | Verdict | 4.66 vs 1.50 · average ×100 |
| 5 | 0:55–1:00 | Footer | Contract address + thanks |

**Tips:** Prefer the HTML autoplay walkthrough; CLI (`npm run demo`) is the backup.

---

*Live contract: `0xDCcBbFFC7D0912674760579fAba210a2a729f859`. HTML is the primary judge-facing demo.*
