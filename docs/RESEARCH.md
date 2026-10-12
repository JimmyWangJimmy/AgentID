# AgentID Research Brief — Metropolis Trust / Identity

**Date:** 2026-10-12 (Asia/Shanghai)  
**Scope:** Specs, papers, peer repos, feasible upgrades before ~2026-10-14 11:59 CST  
**Current live:** `0xDCcBbFFC7D0912674760579fAba210a2a729f859` (Monad testnet 10143)  
**This doc is research only** — no redeploy implied by writing it.

---

## 1. Executive takeaway

1. **Metropolis Track 04 literally lists “Agent identity and reputation under ERC-8004.”** Judges will grade against that bar, not against a private `registerAgent`/`attest` API.
2. **Official ERC-8004 registries are already live on Monad testnet** (CREATE2): Identity `0x8004A818BFB912233c491871b3d84c89A494BD9e`, Reputation `0x8004B663056A597Dffe9eCcC1965A193B7388713`, Validation `0x8004Cb1BF31DAf7788923b405b754f57acEB4272`. Reinventing identity alone looks behind-the-curve.
3. **ERC-8004 deliberately leaves reputation aggregation open.** The EIP says Sybil is possible and expects third parties to build reviewer-weighted / filtered scoring. **That gap is AgentID’s real product**, not another ERC-721 mint.
4. **Direct peer on the same track:** [FlAV1E21/monad-agent-trust](https://github.com/FlAV1E21/monad-agent-trust) ships registry + escrow + **Envio HyperIndex** + live GraphQL leaderboard + two videos. Plain GoodBot/FakeBot average is no longer enough to “remember.”
5. **GoodBot vs FakeBot shows contrast, not Sybil resistance.** Sockpuppet rings can still manufacture a high *unweighted* average. Judges who know EigenTrust / MeritRank will ask this.
6. **Highest impact × effort for ~1–2 days:** (P0) ERC-8004 registration file + dual-path to official registries **or** clear adapter story; (P0) **trust-weighted score** (attester reputation / seed set) with on-chain txs proving a sybil ring fails; (P1) portable Agent Card JSON + demo that reads live RPC / explorer.
7. **Skip for this week:** full Validation Registry (spec still unstable), zkML/TEE theater, World ID deep integration unless already wired.
8. **Narrative that sticks in 30s:** “ERC-8004 gives public feedback; AgentID is the **anti-Sybil aggregator** on Monad — cheap FakeBot looks fine on raw average, dies on **weighted** trust.”
9. **Sponsor angle:** Envio bounty is real (peer already claims it). A thin event indexer beats more README prose.
10. **Do not abandon the live contract blindly** — either wrap it as a scoring lens over 8004 feedback, or migrate identity to official IdentityRegistry and keep AgentID as Reputation Engine v3.

---

## 2. Spec landscape

### ERC-8004 — Trustless Agents (Draft, Aug 2025)

- **Source:** https://eips.ethereum.org/EIPS/eip-8004 · Magicians: https://ethereum-magicians.org/t/erc-8004-trustless-agents/25098  
- **Requires:** EIP-155, EIP-712, EIP-721, EIP-1271  
- **Three registries (per-chain singletons):**
  - **Identity** — ERC-721 + URIStorage; global id `{namespace}:{chainId}:{identityRegistry}` + `agentId`; `agentURI` → registration JSON (HTTPS / IPFS / data:).
  - **Reputation** — `giveFeedback(agentId, value, valueDecimals, tag1, tag2, endpoint, feedbackURI, feedbackHash)`; no self-feedback by owner/operator; `getSummary` **requires non-empty `clientAddresses`** (Sybil note baked into API).
  - **Validation** — request/response hooks for stake / zkML / TEE validators; **still unstable** in best-practices (pending TEE/ZK community).
- **Registration file MUST** include `type` (`…#registration-v1`), `name`, `description`, `image`, `services[]` (A2A / MCP / OASF / ENS / DID / email…), `x402Support`, `active`, `registrations[]`, optional `supportedTrust` (`reputation` | `crypto-economic` | `tee-attestation`).
- **Reference impl:** https://github.com/erc-8004/erc-8004-contracts  
- **Addresses (QuickNode ERC-8004 docs):** https://erc-8004.quicknode.com/docs/contracts  
  - Monad **mainnet** Identity/Reputation/Validation share CREATE2 `0x8004A169…` / `0x8004BAa1…` / `0x8004Cc84…`  
  - Monad **testnet** Identity `0x8004A818…BD9e`, Reputation `0x8004B663…8713`, Validation `0x8004Cb1B…4272`
- **Best-practice signal:** aggregation should filter/weight by `clientAddress`; spam resistance is mostly off-chain / indexer / trusted reviewers (v1.1 removed `feedbackAuth`).

### How AgentID maps today (gaps)

| ERC-8004 concept | AgentID v2 | Gap |
|---|---|---|
| ERC-721 Identity NFT | Custom incremental `agentId`, not ERC-721 | Not browsable in NFT wallets; not CAIP-style global id |
| `agentURI` registration-v1 JSON | Opaque `metadataURI` string | No A2A/MCP/services/`supportedTrust` |
| `giveFeedback` + tags + decimals | `attest(score 1–5, tag, uri)` | Schema incompatible; no `valueDecimals`, no revoke/appendResponse |
| `getSummary(…, clientAddresses[])` | Unweighted average of all attesters | No mandatory client filter; no reviewer trust graph |
| Validation Registry | Absent | OK to skip (unstable) |
| Official Monad singleton | Own deploy `0xDCcB…` | Parallel universe vs track example |

### Related standards (short)

| Spec | Role for AgentID |
|---|---|
| **EIP-712 / ERC-1271** | Off-chain typed attestations → settle on-chain; smart-wallet attesters |
| **A2A Agent Card** | Put `services[].name=A2A` endpoint → `/.well-known/agent-card.json` in registration file |
| **EAS** | Alternate attestation bus; less aligned with Metropolis “under ERC-8004” wording |
| **Gitcoin Passport / World AgentKit** | Raise *attester* quality (PoP); great P2 hook, not P0 |
| **ERC-6551** | Agent-as-NFT with wallet; optional later ownership story |
| **CAIP-2 / CAIP-10** | Already mirrored in 8004 `eip155:chainId:…` strings — adopt verbatim |

### Metropolis official hint

- Page: https://www.monad.xyz/developers/hackathons/metropolis  
- Track **Trust, Identity & AI Infrastructure** ($30k / 3 teams): examples include **“Agent identity and reputation under ERC-8004”**, passkeys, media provenance.  
- Build window ends **13 Oct**; judging 14–27 Oct. Submission = working product + profile (demo, write-up, code).

---

## 3. Papers (depth over quantity)

### 1. EigenTrust — Kamvar, Schlosser, Garcia-Molina (WWW 2003)
Global trust via iterative aggregation of local trust, weighted by the rater’s own global trust (power iteration / PageRank-like). Classic “your vote counts more if you are trusted.”  
**PDF:** https://www-nlp.stanford.edu/pubs/eigentrust.pdf  
**AgentID takeaway:** Replace flat average with **one iteration (or few) of attester-weighted scores** seeded by a small trusted set — EigenTrust-lite, hackathon-feasible.

### 2. PeerTrust — Xiong & Liu (TKDE 2004)
Feedback is adjusted by source credibility, transaction context, and community factors — not raw star averages.  
**PDF:** https://www.comp.nus.edu.sg/~cs6203/guidelines/topic7/peer-trust.pdf  
**AgentID takeaway:** Tag/`tag1` already hints at context; expose **per-tag weighted averages** (reliable vs spam) in `getReputation`.

### 3. MeritRank — Nasrulin, Ishmaev, Pouwelse (BRAINS 2022 / arXiv:2207.09950)
Sybil-*tolerant* (not proof) reputation via feedback graph + **transitivity / connectivity / epoch decay** that bounds attacker gain.  
**PDF:** https://arxiv.org/pdf/2207.09950  
**AgentID takeaway:** Even without full MeritRank, add **recency decay** or discount brand-new attesters — cheap narrative + math story.

### 4. TrustChain / bilateral ledgers — Otte et al.; TrustChain agent extensions (2026 IETF drafts)
Portable identity + signed bilateral interaction history; pluggable MeritRank / NetFlow Sybil defenses.  
**Repo:** https://github.com/viftode4/trustchain  
**AgentID takeaway:** Steal “evidence of *interaction*, not anonymous stars” — optional `feedbackURI` linking to a task receipt / tx hash (x402 / escrow).

### 5. AgentReputation — Chishti, Oyinloye, Li (arXiv 2026, html 2605.00073)
Three-layer framework: evidence + **context-conditioned reputation cards** + policy engine; warns that scalar scores conflate domains and verification strength.  
**URL:** https://arxiv.org/html/2605.00073  
**AgentID takeaway:** GoodBot/FakeBot should become **cards by tag/domain** (“coding-help” vs “trading”), not one number.

### 6. TrustFlow — Seliuchenko (arXiv 2026, html 2603.19452)
Topic-gated **vector** reputation propagation; strong empirics against sybil / laundering / vote rings (≤4 pp impact).  
**URL:** https://arxiv.org/html/2603.19452v1  
**AgentID takeaway:** Full TrustFlow is too heavy for 48h; steal the **topic gate**: weight only same-tag feedback when answering a query.

### 7. “Robust reputations for P2P markets” — thesis line on EigenTrust failure vs sybils; Relative Rank / RAW
Shows EigenTrust alone is **not** Sybil-proof if attackers gain local trust; motivates seed sets + transformations.  
**AgentID takeaway:** Document a **seed/pre-trust set** (hackathon judges’ addresses or known faucet-limited wallets) in README — honesty > fake “Sybil-proof” claims.

### 8. AI Agents with DIDs and VCs (arXiv 2511.02841) + Agent Identity Protocol IETF draft
DID/VC + delegation chains for agent authz; orthogonal but complementary to on-chain registries.  
**AgentID takeaway:** Put a `DID` service entry in the registration JSON; don’t rebuild DID stacks this week.

### 9. Blockchain reputation surveys (e.g. arXiv:2109.07721 CPS survey; marketplace TaaS arXiv:2403.04779)
Surveys agree: on-chain **signal publication** ≠ trust; incentives, privacy, and aggregation algorithms are the hard part.  
**AgentID takeaway:** Align messaging with EIP-8004: *we publish + aggregate; we don’t claim cryptographic honesty of behavior.*

---

## 4. Peer repos / products

| Project | What it does | Stack | Steal | Avoid |
|---|---|---|---|---|
| **[erc-8004/erc-8004-contracts](https://github.com/erc-8004/erc-8004-contracts)** | Canonical Identity / Reputation / Validation | Upgradeable Solidity, ABIs | Use addresses + ABIs; match events | Re-implement all three from scratch |
| **[FlAV1E21/monad-agent-trust](https://github.com/FlAV1E21/monad-agent-trust)** | Same Metropolis track: registry + escrow + Envio leaderboard | Foundry, Envio HyperIndex, GH Pages | Indexer-as-product; escrow↔reputation loop; dual videos | Cloning their escrow 1:1 (looks derivative) |
| **[@elizaos/plugin-8004](https://www.npmjs.com/package/@elizaos/plugin-8004)** | Eliza agents register / check reputation via 8004 | TS plugin | Show AgentID scores consumable by agent runtimes | Depending on full Eliza for demo |
| **Virtuals Protocol** | Agent identity + economy / banking layer | Product + registry | Commerce narrative | Scope creep into tokens |
| **Olas / Autonolas registries** | Components/agents as ERC-721, services | Complex on-chain composition | NFT-as-agent precedent | Their full service multisig stack |
| **Fetch.ai / Agentverse Almanac** | Discovery registry (not 8004) | Cosmos/EVM adjacent | Discovery UX | Different trust model |
| **OpenRank / Karma3** | EigenTrust/HITS on verifiable compute | SDK | Cite as aggregation backend option | Integrating full OpenRank in 24h |
| **EAS (attest.org)** | Schema-based attestations | Ubiquitous EVM | Optional attester credentials | Replacing 8004 on this track |
| **World AgentKit** | Proof-of-human delegated to agents | World ID | Weight attestations from PoH wallets | Blocking demo on World app install |
| **XPR Network xpr-agents** | Identity + reputation + validation + escrow | Non-EVM | Feature checklist | Porting |
| **VibeTensor/attestix** | DID + VC attestation infra | Identity stack | Evidence URIs | Parallel identity system |
| **loomweaver-agent/agent-trust** | Reputation + escrow A2A | Solidity | Payment-linked feedback | Duplicate peer |
| **AgentID (this repo)** | Sybil-lite avg + Good/Fake seed | Foundry + TS + Pages | Keep policy clarity | Staying 8004-incompatible |

---

## 5. Feasible tech shortlist (impact × effort, ~1–2 days)

| Idea | Impact | Effort | Theater vs real? | Verdict |
|---|---|---|---|---|
| **ERC-8004 registration-v1 JSON + CAIP id in demo** | Critical (track alignment) | Low | Real | **Do** |
| **Read/write official Monad ReputationRegistry *or* adapter** | Critical | Med | Real | **Do (P0)** |
| **Trust-weighted score (EigenTrust-lite / seed set)** | High differentiator | Med | Real | **Do (P0)** |
| **Sybil-ring demo txs** (raw avg high, weighted low) | High judge memory | Low–Med | Real | **Do (P0)** |
| **Portable proof JSON** (signed export / agent card) | Med–High | Low | Real | P1 |
| **EIP-712 off-chain attest → settle** | Med | Med | Real UX | P1 |
| **Envio / simple event reader** | High if claiming bounty | Med | Real | P1 (sponsor) |
| **Stake/bond on attestation + slash** | High story | Med–High | Real if live slash tx | P1/P2 |
| **Tag-conditioned cards** | Med (paper-aligned) | Low | Real | P1 |
| **zk attester privacy** | Low this week | High | Theater | **Skip** |
| **Full Validation Registry** | Spec-risky | High | Half-theater | **Skip** |
| **World ID gating** | Nice | Med–High | Real but brittle | P2 |

---

## 6. Recommended P0 / P1 / P2 upgrades

### What would make a judge remember AgentID in 30 seconds?

Not “we have a registry.” Everyone does.  
**Remember this:** *AgentID is the Sybil-aware reputation lens for ERC-8004 on Monad — we show a sockpuppet ring that fools raw averages and fails weighted trust, with explorer links.*

Challenge to current story: GoodBot 4.66 vs FakeBot 1.50 is **label theater** unless you also show an attacker who *tries* to look good and fails under the policy judges care about (reviewer trust / stake / decay).

### Single coherent narrative

> **ERC-8004 publishes feedback. AgentID decides whom to believe.**  
> On Monad testnet we register agents under the 8004 identity model, ingest feedback, and expose a **trust-weighted reputation** that discounts Sybil rings. Demo: three sockpuppets pump FakeBot’s raw average → weighted score stays toxic; GoodBot with diverse, higher-trust attesters stays high. Every step is a MonadVision tx.

### P0 (ship before deadline — on-chain proof preferred)

1. **8004 alignment surface**
   - Host `docs/agents/good-bot.json` / `fake-bot.json` matching **registration-v1** (services, registrations with `eip155:10143:…`, `supportedTrust: ["reputation"]`).
   - Demo + README show global id form and link official testnet Identity/Reputation addresses even if v3 still uses AgentID scoring contract.
   - Ideal: register Good/Fake on **official IdentityRegistry** and submit feedback via **ReputationRegistry**, with AgentID contract (or off-chain script) computing weighted summary filtered by client set.

2. **Trust-weighted reputation (EigenTrust-lite)**
   - On-chain or deterministic off-chain with on-chain inputs:  
     `score(A) = Σ weight(attester) * feedback / Σ weight`, where `weight` = f(attester’s own reputation) or membership in a **seed/pre-trust set**.
   - Keep existing no-self / one-vote / avg as baseline; add `getWeightedReputation`.
   - Seed a **sybil ring** (3 fresh wallets attest 5★ to FakeBot) and show explorer table: raw vs weighted.

3. **Demo + dashboard refresh**
   - Update Pages demo with side-by-side Raw vs Weighted + explorer links.
   - Dashboard contract field: either new scorer address **or** official 8004 + AgentID scorer — label clearly.

### P1 (if hours remain)

- **Agent Card / A2A** stub in registration `services`.
- **EIP-712** typed `Attestation` for gasless collect → batch settle (show one settle tx).
- **Envio** (or eth_getLogs script) indexing `NewFeedback` / `Attested` → GraphQL or static JSON for leaderboard (**sponsor bounty path**).
- Per-tag cards (`reliable` vs `spam`) in UI.

### P2 (post-deadline / stretch)

- Bond MON on attest + slash path (crypto-economic trust tier).
- World AgentKit / Passport as attester boost.
- ValidationRegistry only after spec stabilizes.
- OpenRank remote EigenTrust for marketing depth.

### Explicit non-goals this week

- Competing with peer’s full escrow product feature-for-feature.  
- Claiming “Sybil-proof.” Say **Sybil-tolerant / Sybil-lite** and show the bound.  
- zk theater without a live verify tx.

---

## 7. Sources

### Specs & track
- https://eips.ethereum.org/EIPS/eip-8004  
- https://github.com/erc-8004/erc-8004-contracts  
- https://erc-8004.quicknode.com/docs/contracts  
- https://erc-8004.quicknode.com/networks/monad-testnet  
- https://github.com/erc-8004/best-practices  
- https://www.monad.xyz/developers/hackathons/metropolis  
- https://a2aproject.github.io / A2A Agent Card (`/.well-known/agent-card.json`)  
- https://attest.org/ (EAS)  
- https://world.org/blog/announcements/now-available-agentkit-proof-of-human-for-the-agentic-web  

### Papers
- EigenTrust (2003): https://www-nlp.stanford.edu/pubs/eigentrust.pdf  
- PeerTrust (2004): https://www.comp.nus.edu.sg/~cs6203/guidelines/topic7/peer-trust.pdf  
- MeritRank (2022): https://arxiv.org/pdf/2207.09950  
- AgentReputation (2026): https://arxiv.org/html/2605.00073  
- TrustFlow (2026): https://arxiv.org/html/2603.19452v1  
- Blockchain trust/reputation CPS survey: https://arxiv.org/pdf/2109.07721  
- Marketplace TaaS: https://arxiv.org/html/2403.04779  
- Agents + DID/VC: https://arxiv.org/html/2511.02841v2  
- Agent Identity Protocol (IETF): https://www.ietf.org/archive/id/draft-singla-agent-identity-protocol-03.html  

### Peers
- https://github.com/FlAV1E21/monad-agent-trust  
- https://www.npmjs.com/package/@elizaos/plugin-8004  
- https://github.com/valory-xyz/autonolas-registries  
- https://whitepaper.virtuals.io/about-virtuals/ai-agent-identity-and-banking-layer  
- https://github.com/Karma3Labs/openrank-sdk  
- https://docs.openrank.com/reputation-algorithms/eigentrust  
- https://github.com/viftode4/trustchain  
- https://github.com/VibeTensor/attestix  

### AgentID live
- Repo: https://github.com/JimmyWangJimmy/AgentID  
- Contract: https://testnet.monadvision.com/address/0xDCcBbFFC7D0912674760579fAba210a2a729f859  
- Demo: https://jimmywangjimmy.github.io/AgentID/  

---

*Prepared for Jimmy Wang · Metropolis Trust / Identity · actionable upgrades only.*
