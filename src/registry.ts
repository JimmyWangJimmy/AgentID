/**
 * AgentID — in-memory Agent Registry (mock of on-chain IAgentRegistry).
 *
 * Reputation policy (same as Solidity AgentRegistry):
 * - Score integer in [1, 5]; no self-attest; one vote per attester (overwrite).
 * - getReputation → unweighted average ×100 (baseline).
 * - getWeightedReputation → EigenTrust-lite one-hop: weight from seed set or
 *   attester's owned agent's unweighted avg; else BASE_WEIGHT.
 *
 * Narrative: ERC-8004 publishes feedback; AgentID decides whom to believe.
 */

export type Address = string;

export interface Agent {
  owner: Address;
  metadataURI: string;
  createdAt: number;
}

export interface Attestation {
  attester: Address;
  score: number;
  tag: string;
  evidenceURI: string;
  createdAt: number;
}

export interface Reputation {
  /** Average score × 100 (e.g. 4.5 → 450). 0 when count is 0. */
  averageScoreX100: number;
  count: number;
  uniqueAttesters: number;
  owner: Address;
  metadataURI: string;
}

export interface WeightedReputation {
  weightedAvgX100: number;
  count: number;
  uniqueAttesters: number;
  owner: Address;
  metadataURI: string;
}

export const SCORE_MIN = 1;
export const SCORE_MAX = 5;
export const BASE_WEIGHT = 10;
export const MAX_WEIGHT = 500;
export const ORACLE_SEED_WEIGHT = 500;

export const TAGS = {
  reliable: "reliable",
  helpful: "helpful",
  onTime: "on-time",
  spam: "spam",
  impersonation: "impersonation",
  sybilRing: "sybil-ring",
} as const;

export class AgentRegistry {
  private nextId = 1;
  private agents = new Map<number, Agent>();
  private attestations = new Map<number, Attestation[]>();
  private attesterIndex = new Map<number, Map<string, number>>();
  private agentOfOwnerMap = new Map<string, number>();
  private seedWeights = new Map<string, number>();
  readonly oracle: Address;

  constructor(oracle: Address = "0xOracle") {
    this.oracle = oracle.trim();
    this.seedWeights.set(this.oracle, ORACLE_SEED_WEIGHT);
  }

  setSeedWeight(caller: Address, who: Address, weight: number): void {
    if (caller.trim() !== this.oracle) {
      throw new Error("only oracle");
    }
    if (!who || !who.trim()) throw new Error("zero address");
    if (!Number.isInteger(weight) || weight < 0 || weight > MAX_WEIGHT) {
      throw new Error("weight cap");
    }
    this.seedWeights.set(who.trim(), weight);
  }

  seedWeight(who: Address): number {
    return this.seedWeights.get(who.trim()) ?? 0;
  }

  registerAgent(owner: Address, metadataURI: string): number {
    if (!owner || !owner.trim()) {
      throw new Error("owner address required");
    }
    if (!metadataURI || !metadataURI.trim()) {
      throw new Error("metadataURI required");
    }
    const agentId = this.nextId++;
    const o = owner.trim();
    this.agents.set(agentId, {
      owner: o,
      metadataURI: metadataURI.trim(),
      createdAt: Date.now(),
    });
    this.attestations.set(agentId, []);
    this.attesterIndex.set(agentId, new Map());
    this.agentOfOwnerMap.set(o, agentId);
    return agentId;
  }

  ownerOf(agentId: number): Address {
    return this.requireAgent(agentId).owner;
  }

  metadataURI(agentId: number): string {
    return this.requireAgent(agentId).metadataURI;
  }

  totalAgents(): number {
    return this.agents.size;
  }

  agentOfOwner(owner: Address): number {
    return this.agentOfOwnerMap.get(owner.trim()) ?? 0;
  }

  getAgent(agentId: number): Agent {
    return { ...this.requireAgent(agentId) };
  }

  attest(
    attester: Address,
    agentId: number,
    score: number,
    tag: string,
    evidenceURI: string
  ): void {
    const agent = this.requireAgent(agentId);
    if (!attester || !attester.trim()) {
      throw new Error("attester address required");
    }
    const who = attester.trim();
    if (who === agent.owner) {
      throw new Error("no self-attest");
    }
    if (!Number.isInteger(score) || score < SCORE_MIN || score > SCORE_MAX) {
      throw new Error(
        `score must be an integer in [${SCORE_MIN}, ${SCORE_MAX}]`
      );
    }
    if (!tag || !tag.trim()) {
      throw new Error("tag required");
    }
    if (!evidenceURI || !evidenceURI.trim()) {
      throw new Error("evidenceURI required");
    }

    const entry: Attestation = {
      attester: who,
      score,
      tag: tag.trim(),
      evidenceURI: evidenceURI.trim(),
      createdAt: Date.now(),
    };

    const list = this.attestations.get(agentId)!;
    const indexMap = this.attesterIndex.get(agentId)!;
    const existing = indexMap.get(who);
    if (existing === undefined) {
      indexMap.set(who, list.length);
      list.push(entry);
    } else {
      list[existing] = entry;
    }
  }

  attestationCount(agentId: number): number {
    this.requireAgent(agentId);
    return this.attestations.get(agentId)!.length;
  }

  getAttestation(agentId: number, index: number): Attestation {
    this.requireAgent(agentId);
    const list = this.attestations.get(agentId)!;
    if (index < 0 || index >= list.length) {
      throw new Error(`attestation index out of range: ${index}`);
    }
    return { ...list[index] };
  }

  getReputation(agentId: number): Reputation {
    const agent = this.requireAgent(agentId);
    const { averageScoreX100, count } = this.unweighted(agentId);
    return {
      averageScoreX100,
      count,
      uniqueAttesters: count,
      owner: agent.owner,
      metadataURI: agent.metadataURI,
    };
  }

  getWeightedReputation(agentId: number): WeightedReputation {
    const agent = this.requireAgent(agentId);
    const list = this.attestations.get(agentId)!;
    const count = list.length;
    if (count === 0) {
      return {
        weightedAvgX100: 0,
        count: 0,
        uniqueAttesters: 0,
        owner: agent.owner,
        metadataURI: agent.metadataURI,
      };
    }
    let weightedSum = 0;
    let weightSum = 0;
    for (const a of list) {
      const w = this.attesterWeight(a.attester);
      weightedSum += w * a.score;
      weightSum += w;
    }
    const weightedAvgX100 = Math.trunc((weightedSum * 100) / weightSum);
    return {
      weightedAvgX100,
      count,
      uniqueAttesters: count,
      owner: agent.owner,
      metadataURI: agent.metadataURI,
    };
  }

  attesterWeight(who: Address): number {
    const w = who.trim();
    const seeded = this.seedWeights.get(w) ?? 0;
    if (seeded > 0) {
      return Math.min(seeded, MAX_WEIGHT);
    }
    const owned = this.agentOfOwnerMap.get(w) ?? 0;
    if (owned === 0) return BASE_WEIGHT;
    const { averageScoreX100, count } = this.unweighted(owned);
    if (count === 0 || averageScoreX100 <= 0) return BASE_WEIGHT;
    return Math.min(MAX_WEIGHT, Math.max(BASE_WEIGHT, averageScoreX100));
  }

  private unweighted(agentId: number): {
    averageScoreX100: number;
    count: number;
  } {
    const list = this.attestations.get(agentId)!;
    const count = list.length;
    if (count === 0) return { averageScoreX100: 0, count: 0 };
    const sum = list.reduce((s, a) => s + a.score, 0);
    return { averageScoreX100: Math.trunc((sum * 100) / count), count };
  }

  private requireAgent(agentId: number): Agent {
    const agent = this.agents.get(agentId);
    if (!agent) {
      throw new Error(`unknown agentId: ${agentId}`);
    }
    return agent;
  }
}
