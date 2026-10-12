// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IAgentRegistry.sol";

/// @title AgentRegistry — AgentID on-chain registry (Metropolis / Monad)
/// @notice Sybil-lite: no self-attest; one vote per attester; reputation = average ×100.
/// @dev Not audit-ready. Target: Monad testnet (chain id 10143).
///
/// Suggested tags (bytes32 = keccak256 of label):
///   "reliable", "helpful", "on-time", "spam", "impersonation"
contract AgentRegistry is IAgentRegistryViews {
    uint256 private _nextId = 1;

    mapping(uint256 => Agent) private _agents;
    mapping(uint256 => Attestation[]) private _attestations;
    /// @dev agentId => attester => (index + 1); 0 means none.
    mapping(uint256 => mapping(address => uint256)) private _attesterIndexPlusOne;

    uint8 public constant SCORE_MIN = 1;
    uint8 public constant SCORE_MAX = 5;

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
        Attestation[] storage list = _attestations[agentId];
        count = list.length;
        uniqueAttesters = count; // one vote per attester ⇒ equal
        if (count == 0) {
            return (0, 0, 0);
        }
        int256 sum = 0;
        for (uint256 i = 0; i < list.length; i++) {
            sum += list[i].score;
        }
        averageScoreX100 = (sum * 100) / int256(count);
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

    function _exists(uint256 agentId) private view returns (bool) {
        return agentId > 0 && agentId < _nextId;
    }
}
