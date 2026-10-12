# Metropolis Project Brief · Agent Identity & Reputation Registry
# Metropolis 项目简报 · Agent 身份与信誉登记

**Hackathon:** Monad Metropolis (online)  
**Track / 赛道:** Trust / Identity & AI Infrastructure  
**Builder:** Jimmy Wang · Tsinghua CS + Linguistics (MSc) · Shenzhen · AI Agents  
**Team / 队名建议:** `JimmyWang` or `AgentIdentity` (solo OK)  
**Deadline / 截止:** ~2026-10-14 11:59 Asia/Shanghai  

---

## 1. Project title / 项目标题

**EN:** AgentID — On-chain Agent Identity & Reputation Registry (ERC-8004-inspired) on Monad  
**CN:** AgentID — 基于 Monad 的链上 Agent 身份与信誉登记（受 ERC-8004 启发）

---

## 2. One-sentence pitch / 一句话介绍

**EN:** A minimal on-chain registry where AI agents register an identity, accumulate attestations, and expose a portable reputation score — built for Trust/Identity & AI Infrastructure on Monad.  
**CN:** 一个最小可行的链上登记：AI Agent 注册身份、积累背书，并暴露可迁移的信誉分——面向 Monad 的 Trust/Identity & AI Infrastructure 赛道。

---

## 3. Problem / 问题

**EN:** Agents act across apps and chains, but have no shared, portable identity or reputation. Each platform keeps a siloed account; trust resets at every new integration; spam and impersonation are cheap.  
**CN:** Agent 跨应用、跨链行动，却没有共享、可迁移的身份与信誉。各平台各自建账号，信任无法带走；冒充与刷量成本极低。

---

## 4. Solution / 方案

**EN (on-chain registry + simple reputation):**
- **Identity NFT / registry entry:** `registerAgent(metadataURI)` → unique `agentId` + owner wallet.
- **Attestations:** other agents/humans call `attest(agentId, score, tag, uri)` (signed claim or tx).
- **Reputation view:** weighted sum / decay of attestations → `getReputation(agentId)`.
- **Optional:** simple off-chain indexer + static page that shows agent card (id, owner, score, recent attestations).

**CN（链上登记 + 简单信誉）：**
- **身份 NFT / 登记项：** `registerAgent(metadataURI)` → 唯一 `agentId` + 拥有者钱包。
- **背书：** 其他 Agent/人调用 `attest(agentId, score, tag, uri)`。
- **信誉视图：** 对背书加权/衰减 → `getReputation(agentId)`.
- **可选：** 轻量索引 + 静态页展示 Agent 卡片（id、拥有者、分数、近期背书）。

---

## 5. Why Monad / why this track / 为何 Monad、为何此赛道

**EN:**
- **Track fit:** Trust / Identity & AI Infrastructure is exactly “who is this agent and can I trust it?”
- **Monad fit:** high throughput + low fees → many micro-attestations and frequent agent registrations stay cheap; good home for an agent-native registry.
- **ERC-8004-inspired:** aligns with emerging agent-identity standards without waiting for full finalization — ship a working subset now.

**CN:**
- **赛道契合：** Trust / Identity & AI Infrastructure 正是「这个 Agent 是谁、能否信任」。
- **Monad 契合：** 高吞吐、低费用，适合大量微背书与频繁注册。
- **受 ERC-8004 启发：** 对齐新兴 Agent 身份标准，先交付可跑的子集。

---

## 6. Minimal demo path (48h) / 48 小时最小演示路径

**Goal tonight/tomorrow: placeholdable submission, not a polished product.**

| Priority | Deliverable | Notes |
|----------|-------------|--------|
| P0 | GitHub repo + README | Problem, solution, how to run, track, team |
| P0 | 1-min screen recording | Register → attest → show reputation (even if mock UI) |
| P1 | Solidity contract on Monad testnet | `registerAgent` + `attest` + `getReputation` |
| P1 | Contract address in README | Paste explorer link |
| P2 | Tiny frontend or Foundry/Hardhat script | CLI demo is enough |
| Fallback | Mock in-memory registry + README + video | Acceptable if testnet deploy slips |

**Suggested 48h order:**
1. Scaffold repo + README with this brief (30 min).
2. Write thin Solidity + tests; deploy Monad testnet OR ship mock (2–4 h).
3. Record 60s Loom/phone video of happy path (30 min).
4. Fill dashboard: team → track → project → links (15 min).

---

## 7. Submission checklist / 提交清单

- [ ] Create team (`JimmyWang` or `AgentIdentity`) — solo OK  
- [ ] Select track: **Trust / Identity & AI Infrastructure**  
- [ ] Create project on dashboard; paste title / tagline / description below  
- [ ] GitHub public repo with README (EN+CN OK)  
- [ ] Demo video (~1 min) linked in project  
- [ ] Contract address + explorer link (if deployed); else note “mock / testnet pending”  
- [ ] Submit before **2026-10-14 11:59 Asia/Shanghai**

---

## 8. Suggested team name / 建议队名

- **JimmyWang** — simple, matches dashboard identity  
- **AgentIdentity** — clearer product framing  

Pick one; either is fine for solo.

---

## 9. Paste-ready short form fields / 可直接粘贴的短表单字段

### Title
```
AgentID — On-chain Agent Identity & Reputation Registry on Monad
```

### Tagline
```
ERC-8004-inspired agent identity + attestation-based reputation for Trust/Identity & AI Infrastructure.
```

### Description (≤200 words)
```
AI agents operate across apps and chains without a shared identity or reputation layer. Trust resets at every integration; impersonation and spam are cheap.

AgentID is a minimal on-chain registry on Monad: an agent registers an identity (owner wallet + metadata URI), peers and humans post attestations (score, tag, evidence URI), and anyone can query a portable reputation view. The design is inspired by emerging ERC-8004-style agent identity ideas, focused on a shippable subset for the Trust / Identity & AI Infrastructure track.

48h scope: Solidity registry (registerAgent, attest, getReputation) on Monad testnet if possible, otherwise a documented mock; public GitHub README; ~1-minute demo video of register → attest → score. Built solo by Jimmy Wang (Tsinghua CS + Linguistics MSc, Shenzhen; AI agents). Goal is a clear, extensible foundation—not a full marketplace.
```

### 中文简短描述（可选备用）
```
AI Agent 跨应用、跨链缺少共享身份与信誉，信任无法迁移，冒充成本低。AgentID 是 Monad 上的最小链上登记：注册身份、提交背书、查询可迁移信誉分；受 ERC-8004 思路启发，面向 Trust/Identity & AI Infrastructure。48 小时交付：测试网合约（或 mock）+ README + 约 1 分钟演示视频。个人项目，Jimmy Wang（清华 CS+语言学硕士，深圳，AI Agent）。
```

---

*One-pager for Metropolis placeholder submission · keep shipping, polish later.*
