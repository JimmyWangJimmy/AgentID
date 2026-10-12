// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IAgentRegistry.sol";

/// @title AgentRegistry — AgentID on-chain registry (Metropolis / Monad)
/// @notice Score policy: attestation score is int8 in [1, 5]; reputation = sum of scores.
/// @dev Not audit-ready. Target: Monad testnet (chain id 10143).
contract AgentRegistry is IAgentRegistryViews {
    uint256 private _nextId = 1;

    mapping(uint256 => Agent) private _agents;
    mapping(uint256 => Attestation[]) private _attestations;

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
        require(
            score >= int8(uint8(SCORE_MIN)) && score <= int8(uint8(SCORE_MAX)),
            "score out of range"
        );
        require(tag != bytes32(0), "tag required");
        require(bytes(uri).length > 0, "uri required");

        _attestations[agentId].push(
            Attestation({
                attester: msg.sender,
                score: score,
                tag: tag,
                uri: uri,
                createdAt: uint64(block.timestamp)
            })
        );
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
        returns (int256 score, uint256 count)
    {
        require(_exists(agentId), "unknown agentId");
        Attestation[] storage list = _attestations[agentId];
        count = list.length;
        int256 sum = 0;
        for (uint256 i = 0; i < list.length; i++) {
            sum += list[i].score;
        }
        score = sum;
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
