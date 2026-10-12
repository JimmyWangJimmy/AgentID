/**
 * AgentID — in-memory Agent Registry (mock of on-chain IAgentRegistry).
 *
 * Reputation policy (same as Solidity AgentRegistry):
 * - Attestation score must be an integer in [1, 5].
 * - No self-attest: attester cannot be the agent owner.
 * - One vote per attester: a second attest from the same address overwrites.
 * - getReputation → averageScoreX100 (e.g. 4.5 → 450), count, uniqueAttesters.
 *
 * Suggested tags: reliable, helpful, on-time, spam, impersonation.
 *
 * Addresses are opaque strings (wallet hex or labels) so the CLI demo
 * works without a real chain.
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

export const SCORE_MIN = 1;
export const SCORE_MAX = 5;

/** Story tags used in GoodBot vs FakeBot seed / demo. */
export const TAGS = {
  reliable: "reliable",
  helpful: "helpful",
  onTime: "on-time",
  spam: "spam",
  impersonation: "impersonation",
} as const;

export class AgentRegistry {
  private nextId = 1;
  private agents = new Map<number, Agent>();
  private attestations = new Map<number, Attestation[]>();
  /** agentId → attester → index in attestations array */
  private attesterIndex = new Map<number, Map<string, number>>();

  /** Register a new agent bound to `owner`. Returns agentId. */
  registerAgent(owner: Address, metadataURI: string): number {
    if (!owner || !owner.trim()) {
      throw new Error("owner address required");
    }
    if (!metadataURI || !metadataURI.trim()) {
      throw new Error("metadataURI required");
    }
    const agentId = this.nextId++;
    this.agents.set(agentId, {
      owner: owner.trim(),
      metadataURI: metadataURI.trim(),
      createdAt: Date.now(),
    });
    this.attestations.set(agentId, []);
    this.attesterIndex.set(agentId, new Map());
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

  getAgent(agentId: number): Agent {
    return { ...this.requireAgent(agentId) };
  }

  /**
   * Post or replace an attestation from `attester`.
   * Score must be integer in [SCORE_MIN, SCORE_MAX] (1–5).
   * Rejects self-attest; one vote per attester (overwrite).
   */
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

  /**
   * Portable reputation: average ×100 + count + unique attesters + identity.
   * averageScoreX100 uses integer division (same as Solidity).
   */
  getReputation(agentId: number): Reputation {
    const agent = this.requireAgent(agentId);
    const list = this.attestations.get(agentId)!;
    const count = list.length;
    if (count === 0) {
      return {
        averageScoreX100: 0,
        count: 0,
        uniqueAttesters: 0,
        owner: agent.owner,
        metadataURI: agent.metadataURI,
      };
    }
    const sum = list.reduce((s, a) => s + a.score, 0);
    const averageScoreX100 = Math.trunc((sum * 100) / count);
    return {
      averageScoreX100,
      count,
      uniqueAttesters: count, // one vote per attester
      owner: agent.owner,
      metadataURI: agent.metadataURI,
    };
  }

  private requireAgent(agentId: number): Agent {
    const agent = this.agents.get(agentId);
    if (!agent) {
      throw new Error(`unknown agentId: ${agentId}`);
    }
    return agent;
  }
}
