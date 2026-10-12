// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IAgentRegistry — AgentID interface (Metropolis / Monad)
/// @notice ERC-8004-aligned identity + sybil-lite attest + EigenTrust-lite weighted reputation.
/// @dev Not audit-ready. Deploy on Monad testnet (chain id 10143).
///      AgentID is the anti-Sybil aggregator: ERC-8004 publishes feedback; we decide whom to believe.
interface IAgentRegistry {
    // ── Events ──────────────────────────────────────────────────────────
    event AgentRegistered(
        uint256 indexed agentId,
        address indexed owner,
        string metadataURI
    );

    event Attested(
        uint256 indexed agentId,
        address indexed attester,
        int8 score,
        bytes32 tag,
        string uri
    );

    event SeedWeightSet(address indexed who, uint256 weight);

    // ── Identity ────────────────────────────────────────────────────────
    /// @notice Register a new agent identity bound to msg.sender.
    /// @param uri Off-chain metadata (HTTPS registration-v1 JSON preferred).
    /// @return agentId Newly assigned unique id.
    function registerAgent(string calldata uri) external returns (uint256 agentId);

    function ownerOf(uint256 agentId) external view returns (address);

    function metadataURI(uint256 agentId) external view returns (string memory);

    function totalAgents() external view returns (uint256);

    /// @notice Primary agent id for an owner (latest registration). 0 if none.
    function agentOfOwner(address owner) external view returns (uint256);

    // ── Attestations (sybil-lite) ────────────────────────────────────────
    /// @dev Policy: no self-attest; one vote per attester (overwrite prior).
    function attest(
        uint256 agentId,
        int8 score,
        bytes32 tag,
        string calldata uri
    ) external;

    function attestationCount(uint256 agentId) external view returns (uint256);

    // ── Reputation views ────────────────────────────────────────────────
    /// @notice Unweighted average ×100 (baseline / comparison).
    function getReputation(uint256 agentId)
        external
        view
        returns (
            int256 averageScoreX100,
            uint256 count,
            uint256 uniqueAttesters
        );

    /// @notice EigenTrust-lite: one-hop weight from attester's unweighted rep or seed.
    function getWeightedReputation(uint256 agentId)
        external
        view
        returns (
            int256 weightedAvgX100,
            uint256 count,
            uint256 uniqueAttesters
        );

    /// @notice Weight used for an attester wallet (BASE / seed / agent unweighted avg).
    function attesterWeight(address who) external view returns (uint256);
}

/// @title Optional read helpers for agent cards / indexers
interface IAgentRegistryViews is IAgentRegistry {
    struct Agent {
        address owner;
        string metadataURI;
        uint64 createdAt;
    }

    struct Attestation {
        address attester;
        int8 score;
        bytes32 tag;
        string uri;
        uint64 createdAt;
    }

    function getAgent(uint256 agentId) external view returns (Agent memory);

    function getAttestation(uint256 agentId, uint256 index)
        external
        view
        returns (Attestation memory);

    function setSeedWeight(address who, uint256 weight) external;

    function seedWeight(address who) external view returns (uint256);

    function oracle() external view returns (address);
}
