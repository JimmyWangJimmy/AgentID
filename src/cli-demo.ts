/**
 * AgentID CLI demo — GoodBot vs FakeBot (sybil-lite reputation)
 * Screen-recording friendly: large clear sections, labeled mock.
 *
 * Run: npm run demo
 */

import { AgentRegistry, TAGS } from "./registry.js";

const GOOD_OWNER = "0xGoodOwner1111111111111111111111111111111";
const FAKE_OWNER = "0xFakeOwner2222222222222222222222222222222";
const A1 = "0xAttesterA33333333333333333333333333333333";
const A2 = "0xAttesterB44444444444444444444444444444444";
const A3 = "0xAttesterC55555555555555555555555555555555";

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
  banner("AgentID — Sybil-lite reputation (in-memory mock)");
  console.log("  Track: Trust / Identity & AI Infrastructure (Monad Metropolis)");
  console.log("  Rules: No self-attest · One vote / attester · Average (not spam-sum)");
  console.log("  Author: Jimmy Wang");

  const registry = new AgentRegistry();

  banner("1) Register two agents that both claim to be helpful");
  const goodId = registry.registerAgent(GOOD_OWNER, "ipfs://agentid/good-bot");
  const fakeId = registry.registerAgent(FAKE_OWNER, "ipfs://agentid/fake-bot");
  console.log(`  GoodBot agentId: ${goodId}  uri: ipfs://agentid/good-bot`);
  console.log(`  FakeBot agentId: ${fakeId}  uri: ipfs://agentid/fake-bot`);

  banner("2) Attest — three peers for GoodBot (5 / 5 / 4)");
  registry.attest(A1, goodId, 5, TAGS.reliable, "ipfs://g1");
  registry.attest(A2, goodId, 5, TAGS.helpful, "ipfs://g2");
  registry.attest(A3, goodId, 4, TAGS.onTime, "ipfs://g3");
  console.log(`  tags: reliable, helpful, on-time`);

  banner("3) Attest — two peers for FakeBot (1 / 2)");
  registry.attest(A1, fakeId, 1, TAGS.spam, "ipfs://f1");
  registry.attest(A2, fakeId, 2, TAGS.impersonation, "ipfs://f2");
  console.log(`  tags: spam, impersonation`);

  banner("4) getReputation — portable average (×100)");
  const good = registry.getReputation(goodId);
  const fake = registry.getReputation(fakeId);
  console.log(
    `  GoodBot  avg=${fmtAvg(good.averageScoreX100)}  count=${good.count}  unique=${good.uniqueAttesters}`
  );
  console.log(
    `  FakeBot  avg=${fmtAvg(fake.averageScoreX100)}  count=${fake.count}  unique=${fake.uniqueAttesters}`
  );
  console.log(
    `  → GoodBot clearly beats FakeBot (${good.averageScoreX100} > ${fake.averageScoreX100})`
  );

  banner("5) Sybil-lite check — same attester cannot spam-sum");
  registry.attest(A1, goodId, 5, TAGS.reliable, "ipfs://g1-again");
  const after = registry.getReputation(goodId);
  console.log(
    `  re-attest from A1 → still count=${after.count} (overwrite, not +1)`
  );

  banner("Done — portable trust that resists self-boost and vote spam");
  console.log("  Solidity: contracts/AgentRegistry.sol");
  console.log("");
}

main();
