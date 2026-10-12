import { describe, it, expect, beforeEach } from "vitest";
import {
  AgentRegistry,
  SCORE_MIN,
  SCORE_MAX,
  BASE_WEIGHT,
  TAGS,
} from "../src/registry.js";

const ORACLE = "0xOracle";
const OWNER = "0xOwner";
const ATTESTER_A = "0xAttesterA";
const ATTESTER_B = "0xAttesterB";
const ATTESTER_C = "0xAttesterC";

describe("AgentRegistry", () => {
  let registry: AgentRegistry;

  beforeEach(() => {
    registry = new AgentRegistry(ORACLE);
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
      expect(registry.agentOfOwner(OWNER)).toBe(2); // latest
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
      registry.attest(ATTESTER_A, id, 5, TAGS.reliable, "ipfs://e2");
      expect(registry.attestationCount(id)).toBe(1);
      expect(registry.getReputation(id).averageScoreX100).toBe(500);
    });

    it("rejects score outside 1–5", () => {
      const id = registry.registerAgent(OWNER, "ipfs://meta");
      expect(() =>
        registry.attest(ATTESTER_A, id, 0, "t", "ipfs://e")
      ).toThrow(/score/);
      expect(() =>
        registry.attest(ATTESTER_A, id, 6, "t", "ipfs://e")
      ).toThrow(/score/);
    });

    it("accepts boundary scores", () => {
      const id = registry.registerAgent(OWNER, "ipfs://meta");
      registry.attest(ATTESTER_A, id, SCORE_MIN, "low", "ipfs://e1");
      registry.attest(ATTESTER_B, id, SCORE_MAX, "high", "ipfs://e2");
      expect(registry.attestationCount(id)).toBe(2);
    });
  });

  describe("getReputation", () => {
    it("returns unweighted average ×100", () => {
      const id = registry.registerAgent(OWNER, "ipfs://meta");
      registry.attest(ATTESTER_A, id, 5, TAGS.reliable, "ipfs://e1");
      registry.attest(ATTESTER_B, id, 3, TAGS.helpful, "ipfs://e2");
      const rep = registry.getReputation(id);
      expect(rep.averageScoreX100).toBe(400);
      expect(rep.count).toBe(2);
    });
  });

  describe("good vs fake story", () => {
    it("GoodBot average clearly beats FakeBot", () => {
      const good = registry.registerAgent(OWNER, "ipfs://agentid/good-bot");
      registry.attest(ATTESTER_A, good, 5, TAGS.reliable, "ipfs://g1");
      registry.attest(ATTESTER_B, good, 5, TAGS.helpful, "ipfs://g2");
      registry.attest(ATTESTER_C, good, 4, TAGS.onTime, "ipfs://g3");

      const fake = registry.registerAgent("0xFakeOwner", "ipfs://agentid/fake-bot");
      registry.attest(ATTESTER_A, fake, 1, TAGS.spam, "ipfs://f1");
      registry.attest(ATTESTER_B, fake, 2, TAGS.impersonation, "ipfs://f2");

      expect(registry.getReputation(good).averageScoreX100).toBe(466);
      expect(registry.getReputation(fake).averageScoreX100).toBe(150);
    });
  });

  describe("EigenTrust-lite weighted reputation", () => {
    it("oracle has default seed weight; unknown has BASE_WEIGHT", () => {
      expect(registry.attesterWeight(ORACLE)).toBe(500);
      expect(registry.attesterWeight(ATTESTER_A)).toBe(BASE_WEIGHT);
    });

    it("setSeedWeight only from oracle", () => {
      registry.setSeedWeight(ORACLE, ATTESTER_A, 400);
      expect(registry.attesterWeight(ATTESTER_A)).toBe(400);
      expect(() =>
        registry.setSeedWeight(ATTESTER_A, ATTESTER_B, 100)
      ).toThrow(/only oracle/);
    });

    it("sybil ring: raw looks fine, weighted dies", () => {
      registry.setSeedWeight(ORACLE, ATTESTER_A, 500);
      registry.setSeedWeight(ORACLE, ATTESTER_B, 400);
      registry.setSeedWeight(ORACLE, ATTESTER_C, 400);

      const good = registry.registerAgent(OWNER, "https://…/good-bot.json");
      registry.attest(ATTESTER_A, good, 5, TAGS.reliable, "ipfs://g1");
      registry.attest(ATTESTER_B, good, 5, TAGS.helpful, "ipfs://g2");
      registry.attest(ATTESTER_C, good, 4, TAGS.onTime, "ipfs://g3");

      const gRaw = registry.getReputation(good).averageScoreX100;
      const gW = registry.getWeightedReputation(good).weightedAvgX100;
      expect(gRaw).toBe(466);
      expect(gW).toBe(469); // unequal seed weights

      const fake = registry.registerAgent("0xFake", "https://…/fake-bot.json");
      registry.attest(ATTESTER_A, fake, 1, TAGS.spam, "ipfs://f1");
      registry.attest(ATTESTER_B, fake, 2, TAGS.impersonation, "ipfs://f2");
      expect(registry.getReputation(fake).averageScoreX100).toBe(150);
      // (500*1 + 400*2)*100 / 900 = 144
      expect(registry.getWeightedReputation(fake).weightedAvgX100).toBe(144);

      const sybil = registry.registerAgent("0xSybil", "https://…/sybil-bot.json");
      const pup1 = "0xPup1";
      const pup2 = "0xPup2";
      const pup3 = "0xPup3";
      registry.registerAgent(pup1, "ipfs://puppet-1");
      registry.registerAgent(pup2, "ipfs://puppet-2");
      registry.registerAgent(pup3, "ipfs://puppet-3");
      expect(registry.attesterWeight(pup1)).toBe(BASE_WEIGHT);

      registry.attest(pup1, sybil, 5, TAGS.reliable, "ipfs://s1");
      registry.attest(pup2, sybil, 5, TAGS.helpful, "ipfs://s2");
      registry.attest(pup3, sybil, 5, TAGS.onTime, "ipfs://s3");
      registry.attest(ATTESTER_A, sybil, 1, TAGS.sybilRing, "ipfs://s-flag");

      const sRaw = registry.getReputation(sybil).averageScoreX100;
      const sW = registry.getWeightedReputation(sybil).weightedAvgX100;
      expect(sRaw).toBe(400); // (5+5+5+1)/4
      // (10*5*3 + 500*1)*100 / 530 = 122
      expect(sW).toBe(122);
      expect(sRaw).toBeGreaterThan(sW);
      expect(gW).toBeGreaterThan(sW);
    });

    it("attester earns weight from owned agent's unweighted avg", () => {
      const reviewerAgent = registry.registerAgent(ATTESTER_A, "ipfs://reviewer");
      registry.attest(ORACLE, reviewerAgent, 5, TAGS.reliable, "ipfs://r1");
      expect(registry.attesterWeight(ATTESTER_A)).toBe(500);

      const target = registry.registerAgent(OWNER, "ipfs://target");
      registry.attest(ATTESTER_A, target, 4, TAGS.helpful, "ipfs://t1");
      expect(registry.getWeightedReputation(target).weightedAvgX100).toBe(400);
    });
  });
});
