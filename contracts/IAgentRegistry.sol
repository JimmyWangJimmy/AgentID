// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IAgentRegistry — AgentID interface (Metropolis / Monad)
/// @notice Minimal ERC-8004-inspired identity + attestation + reputation view.
/// @dev Not audit-ready. Deploy on Monad testnet (chain id 10143).
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

    // ── Identity ────────────────────────────────────────────────────────
    /// @notice Register a new agent identity bound to msg.sender.
    /// @param uri Off-chain metadata (e.g. ipfs://… JSON with name, endpoints).
    /// @return agentId Newly assigned unique id.
    function registerAgent(string calldata uri) external returns (uint256 agentId);

    /// @notice Owner of an agent identity.
    function ownerOf(uint256 agentId) external view returns (address);

    /// @notice Metadata URI for an agent.
    function metadataURI(uint256 agentId) external view returns (string memory);

    /// @notice Total number of registered agents.
    function totalAgents() external view returns (uint256);

    // ── Attestations ────────────────────────────────────────────────────
    /// @notice Post an attestation about an agent.
    /// @param agentId Target agent.
    /// @param score Score contribution; AgentRegistry policy is 1..5.
    /// @param tag Short category (e.g. keccak256("reliable")).
    /// @param uri Evidence / claim URI.
    function attest(
        uint256 agentId,
        int8 score,
        bytes32 tag,
        string calldata uri
    ) external;

    /// @notice Number of attestations recorded for an agent.
    function attestationCount(uint256 agentId) external view returns (uint256);

    // ── Reputation view ─────────────────────────────────────────────────
    /// @notice Portable reputation snapshot (sum of scores + count).
    function getReputation(uint256 agentId)
        external
        view
        returns (int256 score, uint256 count);
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
}
