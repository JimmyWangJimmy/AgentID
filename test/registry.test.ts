import { describe, it, expect, beforeEach } from "vitest";
import {
  AgentRegistry,
  SCORE_MIN,
  SCORE_MAX,
  TAGS,
} from "../src/registry.js";

const OWNER = "0xOwner";
const ATTESTER_A = "0xAttesterA";
const ATTESTER_B = "0xAttesterB";
const ATTESTER_C = "0xAttesterC";

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
      registry.attest(ATTESTER_A, id, 5, TAGS.reliable, "ipfs://ev");
      expect(registry.attestationCount(id)).toBe(1);
      const a = registry.getAttestation(id, 0);
      expect(a.attester).toBe(ATTESTER_A);
      expect(a.score).toBe(5);
      expect(a.tag).toBe("reliable");
      expect(a.evidenceURI).toBe("ipfs://ev");
    });

    it("rejects self-attest", () => {
      const id = registry.registerAgent(OWNER, "ipfs://meta");
      expect(() =>
        registry.attest(OWNER, id, 5, TAGS.reliable, "ipfs://ev")
      ).toThrow(/no self-attest/);
    });

    it("replaces prior vote from same attester", () => {
      const id = registry.registerAgent(OWNER, "ipfs://meta");
      registry.attest(ATTESTER_A, id, 2, TAGS.spam, "ipfs://e1");
      expect(registry.attestationCount(id)).toBe(1);
      registry.attest(ATTESTER_A, id, 5, TAGS.reliable, "ipfs://e2");
      expect(registry.attestationCount(id)).toBe(1);
      const a = registry.getAttestation(id, 0);
      expect(a.score).toBe(5);
      expect(a.tag).toBe("reliable");
      const rep = registry.getReputation(id);
      expect(rep.averageScoreX100).toBe(500);
      expect(rep.count).toBe(1);
      expect(rep.uniqueAttesters).toBe(1);
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
    it("returns average ×100 and unique attesters", () => {
      const id = registry.registerAgent(OWNER, "ipfs://meta");
      expect(registry.getReputation(id)).toEqual({
        averageScoreX100: 0,
        count: 0,
        uniqueAttesters: 0,
        owner: OWNER,
        metadataURI: "ipfs://meta",
      });

      registry.attest(ATTESTER_A, id, 5, TAGS.reliable, "ipfs://e1");
      registry.attest(ATTESTER_B, id, 3, TAGS.helpful, "ipfs://e2");

      const rep = registry.getReputation(id);
      expect(rep.averageScoreX100).toBe(400); // (5+3)/2 * 100
      expect(rep.count).toBe(2);
      expect(rep.uniqueAttesters).toBe(2);
      expect(rep.owner).toBe(OWNER);
      expect(rep.metadataURI).toBe("ipfs://meta");
    });

    it("throws for unknown agent", () => {
      expect(() => registry.getReputation(1)).toThrow(/unknown agentId/);
    });
  });

  describe("good vs fake story", () => {
    it("GoodBot average clearly beats FakeBot", () => {
      const good = registry.registerAgent(OWNER, "ipfs://agentid/good-bot");
      registry.attest(ATTESTER_A, good, 5, TAGS.reliable, "ipfs://g1");
      registry.attest(ATTESTER_B, good, 5, TAGS.helpful, "ipfs://g2");
      registry.attest(ATTESTER_C, good, 4, TAGS.onTime, "ipfs://g3");

      const fakeOwner = "0xFakeOwner";
      const fake = registry.registerAgent(fakeOwner, "ipfs://agentid/fake-bot");
      registry.attest(ATTESTER_A, fake, 1, TAGS.spam, "ipfs://f1");
      registry.attest(ATTESTER_B, fake, 2, TAGS.impersonation, "ipfs://f2");

      const goodRep = registry.getReputation(good);
      const fakeRep = registry.getReputation(fake);
      expect(goodRep.averageScoreX100).toBe(466); // (5+5+4)*100/3
      expect(goodRep.count).toBe(3);
      expect(fakeRep.averageScoreX100).toBe(150); // (1+2)*100/2
      expect(fakeRep.count).toBe(2);
      expect(goodRep.averageScoreX100).toBeGreaterThan(fakeRep.averageScoreX100);
    });
  });
});
