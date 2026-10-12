/**
 * AgentID CLI demo — register → attest → getReputation
 * Screen-recording friendly: large clear sections, labeled mock.
 *
 * Run: npm run demo
 */

import { AgentRegistry } from "./registry.js";

const OWNER = "0xOwner111111111111111111111111111111111111";
const ATTESTER = "0xAttester2222222222222222222222222222222222";

function banner(title: string) {
  console.log("");
  console.log("=".repeat(64));
  console.log(`  ${title}`);
  console.log("=".repeat(64));
}

function main() {
  banner("AgentID — Mock registry (in-memory)");
  console.log("  Track: Trust / Identity & AI Infrastructure (Monad Metropolis)");
  console.log("  Mode:  MOCK — no chain deploy required");
  console.log("  Policy: attestation score 1–5; reputation = sum of scores");
  console.log("  Author: Jimmy Wang");

  const registry = new AgentRegistry();

  // ── 1. Register ────────────────────────────────────────────────────
  banner("1) registerAgent");
  const metadataURI = "ipfs://QmAgentMetaDemo001";
  console.log(`  owner:       ${OWNER}`);
  console.log(`  metadataURI: ${metadataURI}`);
  const agentId = registry.registerAgent(OWNER, metadataURI);
  console.log(`  → agentId:   ${agentId}`);
  console.log(`  → ownerOf:   ${registry.ownerOf(agentId)}`);
  console.log(`  → totalAgents: ${registry.totalAgents()}`);

  // ── 2. Attest ──────────────────────────────────────────────────────
  banner("2) attest (second wallet)");
  const score = 5;
  const tag = "reliable";
  const evidenceURI = "ipfs://QmEvidenceDemo001";
  console.log(`  attester:    ${ATTESTER}`);
  console.log(`  agentId:     ${agentId}`);
  console.log(`  score:       ${score}  (clamp 1–5)`);
  console.log(`  tag:         ${tag}`);
  console.log(`  evidenceURI: ${evidenceURI}`);
  registry.attest(ATTESTER, agentId, score, tag, evidenceURI);
  console.log(`  → attestationCount: ${registry.attestationCount(agentId)}`);

  // ── 3. Reputation ──────────────────────────────────────────────────
  banner("3) getReputation");
  const rep = registry.getReputation(agentId);
  console.log(`  agentId:     ${agentId}`);
  console.log(`  owner:       ${rep.owner}`);
  console.log(`  metadataURI: ${rep.metadataURI}`);
  console.log(`  → score:     ${rep.score}`);
  console.log(`  → count:     ${rep.count}`);

  banner("Done — register → attest → score");
  console.log("  Portable trust in one call. That's AgentID.");
  console.log("  Solidity interfaces: contracts/IAgentRegistry.sol");
  console.log("  Implementation sketch: contracts/AgentRegistry.sol");
  console.log("");
}

main();
