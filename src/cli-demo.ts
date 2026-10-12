/**
 * AgentID CLI demo — GoodBot / FakeBot / SybilRing (EigenTrust-lite)
 * Run: npm run demo
 */

import { AgentRegistry, TAGS } from "./registry.js";

const ORACLE = "0xOracle";
const GOOD_OWNER = "0xGoodOwner";
const FAKE_OWNER = "0xFakeOwner";
const SYBIL_OWNER = "0xSybilOwner";
const A1 = "0xAttesterA";
const A2 = "0xAttesterB";
const A3 = "0xAttesterC";
const P1 = "0xPuppet1";
const P2 = "0xPuppet2";
const P3 = "0xPuppet3";

function banner(title: string) {
  console.log("");
  console.log("=".repeat(64));
  console.log(`  ${title}`);
  console.log("=".repeat(64));
}

function fmtAvg(x100: number): string {
  return (x100 / 100).toFixed(2);
}

function main() {
  banner("AgentID — anti-Sybil aggregator for ERC-8004 (mock)");
  console.log("  ERC-8004 publishes feedback; AgentID decides whom to believe.");
  console.log("  Rules: no self-attest · one vote · raw avg + EigenTrust-lite weighted");

  const registry = new AgentRegistry(ORACLE);
  registry.setSeedWeight(ORACLE, A1, 500);
  registry.setSeedWeight(ORACLE, A2, 400);
  registry.setSeedWeight(ORACLE, A3, 400);

  banner("1) Register GoodBot / FakeBot / SybilBot");
  const goodId = registry.registerAgent(GOOD_OWNER, "https://…/good-bot.json");
  const fakeId = registry.registerAgent(FAKE_OWNER, "https://…/fake-bot.json");
  const sybilId = registry.registerAgent(SYBIL_OWNER, "https://…/sybil-bot.json");
  console.log(`  GoodBot #${goodId}  FakeBot #${fakeId}  SybilBot #${sybilId}`);

  banner("2) GoodBot — high scores from seeded reviewers");
  registry.attest(A1, goodId, 5, TAGS.reliable, "ipfs://g1");
  registry.attest(A2, goodId, 5, TAGS.helpful, "ipfs://g2");
  registry.attest(A3, goodId, 4, TAGS.onTime, "ipfs://g3");

  banner("3) FakeBot — honestly toxic");
  registry.attest(A1, fakeId, 1, TAGS.spam, "ipfs://f1");
  registry.attest(A2, fakeId, 2, TAGS.impersonation, "ipfs://f2");

  banner("4) SybilBot — sockpuppet ring (fresh wallets × 5★) + seed flag");
  registry.registerAgent(P1, "ipfs://puppet-1");
  registry.registerAgent(P2, "ipfs://puppet-2");
  registry.registerAgent(P3, "ipfs://puppet-3");
  registry.attest(P1, sybilId, 5, TAGS.reliable, "ipfs://s1");
  registry.attest(P2, sybilId, 5, TAGS.helpful, "ipfs://s2");
  registry.attest(P3, sybilId, 5, TAGS.onTime, "ipfs://s3");
  registry.attest(A1, sybilId, 1, TAGS.sybilRing, "ipfs://s-flag");

  banner("5) Raw vs Weighted");
  for (const [label, id] of [
    ["GoodBot", goodId],
    ["FakeBot", fakeId],
    ["SybilBot", sybilId],
  ] as const) {
    const raw = registry.getReputation(id);
    const w = registry.getWeightedReputation(id);
    console.log(
      `  ${label.padEnd(9)} raw=${fmtAvg(raw.averageScoreX100)}  weighted=${fmtAvg(w.weightedAvgX100)}  count=${raw.count}`
    );
  }
  console.log("  → SybilBot fools raw average; weighted trust collapses.");
  banner("Done");
}

main();
