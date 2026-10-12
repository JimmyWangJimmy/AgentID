// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IAgentRegistry.sol";

/// @title AgentRegistry — AgentID anti-Sybil aggregator on Monad
/// @notice EigenTrust-lite: unweighted avg for comparison; weighted avg discounts sockpuppets.
/// @dev Not audit-ready. Target: Monad testnet (chain id 10143).
///
/// Weight policy (one-hop, non-recursive):
///   - If `seedWeight[W] > 0` → that weight (capped at MAX_WEIGHT). Bootstrap trust.
///   - Else if W owns a registered agent with ≥1 attestation → max(BASE, unweightedAvg×100 of that agent).
///   - Else → BASE_WEIGHT (fresh / worthless sockpuppet).
/// Suggested tags: "reliable", "helpful", "on-time", "spam", "impersonation", "sybil-ring"
contract AgentRegistry is IAgentRegistryViews {
    uint256 private _nextId = 1;

    mapping(uint256 => Agent) private _agents;
    mapping(uint256 => Attestation[]) private _attestations;
    /// @dev agentId => attester => (index + 1); 0 means none.
    mapping(uint256 => mapping(address => uint256)) private _attesterIndexPlusOne;
    /// @dev owner => primary agentId (latest registration)
    mapping(address => uint256) private _agentOfOwner;
    /// @dev pre-trust / oracle seed weights
    mapping(address => uint256) private _seedWeight;

    address public immutable override oracle;

    uint8 public constant SCORE_MIN = 1;
    uint8 public constant SCORE_MAX = 5;
    /// @notice Floor weight for unknown / zero-rep attesters (sockpuppets).
    uint256 public constant BASE_WEIGHT = 10;
    /// @notice Cap for seed and earned weights.
    uint256 public constant MAX_WEIGHT = 500;
    /// @notice Default oracle/deployer seed weight.
    uint256 public constant ORACLE_SEED_WEIGHT = 500;

    constructor() {
        oracle = msg.sender;
        _seedWeight[msg.sender] = ORACLE_SEED_WEIGHT;
        emit SeedWeightSet(msg.sender, ORACLE_SEED_WEIGHT);
    }

    function setSeedWeight(address who, uint256 weight) external override {
        require(msg.sender == oracle, "only oracle");
        require(who != address(0), "zero address");
        require(weight <= MAX_WEIGHT, "weight cap");
        _seedWeight[who] = weight;
        emit SeedWeightSet(who, weight);
    }

    function seedWeight(address who) external view override returns (uint256) {
        return _seedWeight[who];
    }

    function registerAgent(string calldata uri)
        external
        override
        returns (uint256 agentId)
    {
        require(bytes(uri).length > 0, "metadataURI required");
        agentId = _nextId++;
        _agents[agentId] = Agent({
            owner: msg.sender,
            metadataURI: uri,
            createdAt: uint64(block.timestamp)
        });
        _agentOfOwner[msg.sender] = agentId;
        emit AgentRegistered(agentId, msg.sender, uri);
    }

    function ownerOf(uint256 agentId) external view override returns (address) {
        require(_exists(agentId), "unknown agentId");
        return _agents[agentId].owner;
    }

    function metadataURI(uint256 agentId)
        external
        view
        override
        returns (string memory)
    {
        require(_exists(agentId), "unknown agentId");
        return _agents[agentId].metadataURI;
    }

    function totalAgents() external view override returns (uint256) {
        return _nextId - 1;
    }

    function agentOfOwner(address owner) external view override returns (uint256) {
        return _agentOfOwner[owner];
    }

    function attest(
        uint256 agentId,
        int8 score,
        bytes32 tag,
        string calldata uri
    ) external override {
        require(_exists(agentId), "unknown agentId");
        require(msg.sender != _agents[agentId].owner, "no self-attest");
        require(
            score >= int8(uint8(SCORE_MIN)) && score <= int8(uint8(SCORE_MAX)),
            "score out of range"
        );
        require(tag != bytes32(0), "tag required");
        require(bytes(uri).length > 0, "uri required");

        Attestation memory a = Attestation({
            attester: msg.sender,
            score: score,
            tag: tag,
            uri: uri,
            createdAt: uint64(block.timestamp)
        });

        uint256 idxPlus = _attesterIndexPlusOne[agentId][msg.sender];
        if (idxPlus == 0) {
            _attestations[agentId].push(a);
            _attesterIndexPlusOne[agentId][msg.sender] = _attestations[agentId].length;
        } else {
            _attestations[agentId][idxPlus - 1] = a;
        }

        emit Attested(agentId, msg.sender, score, tag, uri);
    }

    function attestationCount(uint256 agentId)
        external
        view
        override
        returns (uint256)
    {
        require(_exists(agentId), "unknown agentId");
        return _attestations[agentId].length;
    }

    function getReputation(uint256 agentId)
        external
        view
        override
        returns (
            int256 averageScoreX100,
            uint256 count,
            uint256 uniqueAttesters
        )
    {
        require(_exists(agentId), "unknown agentId");
        return _unweighted(agentId);
    }

    function getWeightedReputation(uint256 agentId)
        external
        view
        override
        returns (
            int256 weightedAvgX100,
            uint256 count,
            uint256 uniqueAttesters
        )
    {
        require(_exists(agentId), "unknown agentId");
        Attestation[] storage list = _attestations[agentId];
        count = list.length;
        uniqueAttesters = count;
        if (count == 0) {
            return (0, 0, 0);
        }
        int256 weightedSum = 0;
        uint256 weightSum = 0;
        for (uint256 i = 0; i < list.length; i++) {
            uint256 w = _weightOf(list[i].attester);
            weightedSum += int256(w) * int256(list[i].score);
            weightSum += w;
        }
        // weightSum always > 0 because BASE_WEIGHT >= 1
        weightedAvgX100 = (weightedSum * 100) / int256(weightSum);
    }

    function attesterWeight(address who) external view override returns (uint256) {
        return _weightOf(who);
    }

    function getAgent(uint256 agentId)
        external
        view
        override
        returns (Agent memory)
    {
        require(_exists(agentId), "unknown agentId");
        return _agents[agentId];
    }

    function getAttestation(uint256 agentId, uint256 index)
        external
        view
        override
        returns (Attestation memory)
    {
        require(_exists(agentId), "unknown agentId");
        require(index < _attestations[agentId].length, "index OOB");
        return _attestations[agentId][index];
    }

    // ── Internals ───────────────────────────────────────────────────────

    function _exists(uint256 agentId) private view returns (bool) {
        return agentId > 0 && agentId < _nextId;
    }

    function _unweighted(uint256 agentId)
        private
        view
        returns (int256 averageScoreX100, uint256 count, uint256 uniqueAttesters)
    {
        Attestation[] storage list = _attestations[agentId];
        count = list.length;
        uniqueAttesters = count;
        if (count == 0) {
            return (0, 0, 0);
        }
        int256 sum = 0;
        for (uint256 i = 0; i < list.length; i++) {
            sum += list[i].score;
        }
        averageScoreX100 = (sum * 100) / int256(count);
    }

    /// @dev One-hop EigenTrust-lite weight. Uses unweighted avg of attester's agent — never recursive weighted.
    function _weightOf(address who) private view returns (uint256) {
        uint256 seeded = _seedWeight[who];
        if (seeded > 0) {
            return seeded > MAX_WEIGHT ? MAX_WEIGHT : seeded;
        }
        uint256 owned = _agentOfOwner[who];
        if (owned == 0) {
            return BASE_WEIGHT;
        }
        (int256 avgX100, uint256 count,) = _unweighted(owned);
        if (count == 0) {
            return BASE_WEIGHT; // registered but no trust earned
        }
        if (avgX100 <= 0) {
            return BASE_WEIGHT;
        }
        uint256 earned = uint256(avgX100); // e.g. 466 for avg 4.66
        if (earned < BASE_WEIGHT) earned = BASE_WEIGHT;
        if (earned > MAX_WEIGHT) earned = MAX_WEIGHT;
        return earned;
    }
}
