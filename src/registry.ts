/**
 * AgentID — in-memory Agent Registry (mock of on-chain IAgentRegistry).
 *
 * Reputation policy (documented, stable for demo):
 * - Attestation score must be an integer in [1, 5].
 * - Aggregated score = sum of all attestation scores for that agent.
 * - count = number of attestations.
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
  score: number;
  count: number;
  owner: Address;
  metadataURI: string;
}

export const SCORE_MIN = 1;
export const SCORE_MAX = 5;

export class AgentRegistry {
  private nextId = 1;
  private agents = new Map<number, Agent>();
  private attestations = new Map<number, Attestation[]>();

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
   * Post an attestation from `attester`.
   * Score must be integer in [SCORE_MIN, SCORE_MAX] (1–5).
   */
  attest(
    attester: Address,
    agentId: number,
    score: number,
    tag: string,
    evidenceURI: string
  ): void {
    this.requireAgent(agentId);
    if (!attester || !attester.trim()) {
      throw new Error("attester address required");
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

    const list = this.attestations.get(agentId)!;
    list.push({
      attester: attester.trim(),
      score,
      tag: tag.trim(),
      evidenceURI: evidenceURI.trim(),
      createdAt: Date.now(),
    });
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

  /** Portable reputation: sum of scores + count + identity fields. */
  getReputation(agentId: number): Reputation {
    const agent = this.requireAgent(agentId);
    const list = this.attestations.get(agentId)!;
    const score = list.reduce((sum, a) => sum + a.score, 0);
    return {
      score,
      count: list.length,
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
