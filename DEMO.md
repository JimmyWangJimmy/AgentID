# AgentID Demo Script · ~1 minute

**Goal:** Screen recording of **register → attest → score** for Metropolis submission.  
**Project:** AgentID — On-chain Agent Identity & Reputation Registry on Monad  
**Track:** Trust / Identity & AI Infrastructure

---

## Run before recording

```bash
cd AgentID
npm install
npm run demo
```

Label on screen: **LIVE on Monad testnet** `0x7Be01cFC771fA2FD292113dA83881E0deC56ad13` — UI walkthrough still uses in-memory registry (same API).

---

## Spoken lines (read aloud)

### English (~55–60s)

> Hi — I'm Jimmy Wang. This is **AgentID**, an ERC-8004-inspired on-chain agent identity and reputation registry on Monad, for the Trust / Identity track.
>
> **Problem:** Agents move across apps and chains with no shared identity — trust resets everywhere.
>
> **Demo:** First I **register** an agent — owner wallet plus a metadata URI — and we get an `agentId`.
>
> Next, a second wallet **attests**: score, tag, evidence URI.
>
> Finally I **query reputation** — score goes up, attestation count is one. Portable trust in one call.
>
> That's AgentID: register, attest, score. Built solo for Metropolis on Monad. Thanks!

### 中文（约 55–60 秒）

> 大家好，我是 Jimmy Wang。这是 **AgentID**：受 ERC-8004 启发、跑在 Monad 上的链上 Agent 身份与信誉登记，面向 Trust / Identity 赛道。
>
> **问题：** Agent 跨应用、跨链没有共享身份，信任每次都要重来。
>
> **演示：** 先 **注册** 一个 Agent——绑定拥有者钱包和 metadata URI，拿到 `agentId`。
>
> 然后用第二个钱包 **背书**：分数、标签、证据 URI。
>
> 最后 **查询信誉**——分数上升，背书数为 1。一次调用就能看到可迁移的信任。
>
> 这就是 AgentID：注册、背书、打分。Metropolis 个人项目。谢谢！

---

## Shot list (~60s)

| # | Time | Screen | Action | Say (EN cue) |
|---|------|--------|--------|--------------|
| 1 | 0:00–0:08 | README / terminal title | Show project name + live contract | Intro + track |
| 2 | 0:08–0:18 | `npm run demo` section 1 | `registerAgent` → `agentId` | “Register an agent…” |
| 3 | 0:18–0:35 | section 2 | Second wallet `attest` score 5 | “Second wallet attests…” |
| 4 | 0:35–0:50 | section 3 | `getReputation` → score 5, count 1 | “Query reputation…” |
| 5 | 0:50–1:00 | README / repo | Point to GitHub | Close + thanks |

**Tips:** Large font; zoom 125–150%; one happy path only.

---

## Recording checklist

- [ ] Mic clear; close notifications
- [ ] 1080p, ~60s, mp4 or Loom
- [ ] Filename: `AgentID-demo-1min.mp4`
- [ ] Link pasted into Metropolis project + README

---

*Live contract: `0x7Be01cFC771fA2FD292113dA83881E0deC56ad13` on Monad testnet. UI demo is in-memory; do not fake a mainnet explorer.*
