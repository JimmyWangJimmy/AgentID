import { describe, it, expect, beforeEach } from "vitest";
import {
  AgentRegistry,
  SCORE_MIN,
  SCORE_MAX,
} from "../src/registry.js";

const OWNER = "0xOwner";
const ATTESTER_A = "0xAttesterA";
const ATTESTER_B = "0xAttesterB";

describe("AgentRegistry", () => {
  let registry: AgentRegistry;

  beforeEach(() => {
    registry = new AgentRegistry();
  });

  describe("registerAgent", () => {
    it("assigns incremental agentIds and stores identity", () => {
      const id1 = registry.registerAgent(OWNER, "ipfs://a");
      const id2 = registry.registerAgent(OWNER, "ipfs://b");
      expect(id1).toBe(1);
      expect(id2).toBe(2);
      expect(registry.ownerOf(id1)).toBe(OWNER);
      expect(registry.metadataURI(id1)).toBe("ipfs://a");
      expect(registry.totalAgents()).toBe(2);
    });

    it("rejects empty owner or metadataURI", () => {
      expect(() => registry.registerAgent("", "ipfs://x")).toThrow(/owner/);
      expect(() => registry.registerAgent(OWNER, "")).toThrow(/metadataURI/);
    });
  });

  describe("attest", () => {
    it("records attestation and updates count", () => {
      const id = registry.registerAgent(OWNER, "ipfs://meta");
      registry.attest(ATTESTER_A, id, 5, "reliable", "ipfs://ev");
      expect(registry.attestationCount(id)).toBe(1);
      const a = registry.getAttestation(id, 0);
      expect(a.attester).toBe(ATTESTER_A);
      expect(a.score).toBe(5);
      expect(a.tag).toBe("reliable");
      expect(a.evidenceURI).toBe("ipfs://ev");
    });

    it("rejects score outside 1–5", () => {
      const id = registry.registerAgent(OWNER, "ipfs://meta");
      expect(() =>
        registry.attest(ATTESTER_A, id, 0, "t", "ipfs://e")
      ).toThrow(/score/);
      expect(() =>
        registry.attest(ATTESTER_A, id, 6, "t", "ipfs://e")
      ).toThrow(/score/);
      expect(() =>
        registry.attest(ATTESTER_A, id, 3.5, "t", "ipfs://e")
      ).toThrow(/score/);
    });

    it("rejects unknown agentId", () => {
      expect(() =>
        registry.attest(ATTESTER_A, 99, 3, "t", "ipfs://e")
      ).toThrow(/unknown agentId/);
    });

    it("accepts boundary scores SCORE_MIN and SCORE_MAX", () => {
      const id = registry.registerAgent(OWNER, "ipfs://meta");
      registry.attest(ATTESTER_A, id, SCORE_MIN, "low", "ipfs://e1");
      registry.attest(ATTESTER_B, id, SCORE_MAX, "high", "ipfs://e2");
      expect(registry.attestationCount(id)).toBe(2);
    });
  });

  describe("getReputation", () => {
    it("sums scores and returns identity fields", () => {
      const id = registry.registerAgent(OWNER, "ipfs://meta");
      expect(registry.getReputation(id)).toEqual({
        score: 0,
        count: 0,
        owner: OWNER,
        metadataURI: "ipfs://meta",
      });

      registry.attest(ATTESTER_A, id, 5, "reliable", "ipfs://e1");
      registry.attest(ATTESTER_B, id, 3, "helpful", "ipfs://e2");

      const rep = registry.getReputation(id);
      expect(rep.score).toBe(8);
      expect(rep.count).toBe(2);
      expect(rep.owner).toBe(OWNER);
      expect(rep.metadataURI).toBe("ipfs://meta");
    });

    it("throws for unknown agent", () => {
      expect(() => registry.getReputation(1)).toThrow(/unknown agentId/);
    });
  });

  describe("happy path register → attest → score", () => {
    it("matches the demo walkthrough", () => {
      const id = registry.registerAgent(
        "0xOwner111111111111111111111111111111111111",
        "ipfs://QmAgentMetaDemo001"
      );
      expect(id).toBe(1);

      registry.attest(
        "0xAttester2222222222222222222222222222222222",
        id,
        5,
        "reliable",
        "ipfs://QmEvidenceDemo001"
      );

      const rep = registry.getReputation(id);
      expect(rep.score).toBe(5);
      expect(rep.count).toBe(1);
    });
  });
});
