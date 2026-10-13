# AgentID ↔ ERC-8004 adapter

AgentID is an **aggregator lens**, not a parallel identity universe.

## Dual path

| Layer | Contract | Role |
|-------|----------|------|
| **Identity** | Official `0x8004A818…BD9e` | ERC-721 agent NFTs (Good #2204 · Fake #2205 · Sybil #2206) |
| **Reputation feedback** | Official `0x8004B663…8713` | Immutable `giveFeedback` signals (star scale 1–5, `valueDecimals=0`) |
| **Anti-Sybil scoring** | AgentID `0x8916357E…c310` | `getReputation` (raw) + `getWeightedReputation` (EigenTrust-lite) |

## Mapping

| Story agent | AgentID scorer id | Official Identity agentId |
|-------------|-------------------|---------------------------|
| GoodBot | 1 | 2204 |
| FakeBot | 2 | 2205 |
| SybilBot | 3 | 2206 |

Seed attestations on AgentID and `giveFeedback` rows on the official ReputationRegistry use the **same client wallets and scores** so a judge can verify both explorers.

## Why not only `getSummary`?

ERC-8004 deliberately leaves aggregation open. `getSummary` is an unweighted mean over a caller-supplied client list — a sockpuppet ring still looks fine (Sybil summary ≈ 4). AgentID’s contribution is **who to believe**: seed / one-hop weights collapse puppets.

## Ingest path (this hackathon)

1. Clients call official `giveFeedback` (see `script/Feedback8004.s.sol`).
2. Parallel AgentID `attest` rows power `getWeightedReputation`.
3. Demo + ONCHAIN.md link **both** registries.

A future mirror would index `NewFeedback` logs into AgentID weights; out of scope for the deadline, documented as limitation.

## Interface

See [`contracts/interfaces/IERC8004Reputation.sol`](../contracts/interfaces/IERC8004Reputation.sol).
