// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

interface IERC8004Reputation {
    function giveFeedback(
        uint256 agentId,
        int128 value,
        uint8 valueDecimals,
        string calldata tag1,
        string calldata tag2,
        string calldata endpoint,
        string calldata feedbackURI,
        bytes32 feedbackHash
    ) external;

    function getClients(uint256 agentId) external view returns (address[] memory);
    function getSummary(
        uint256 agentId,
        address[] calldata clientAddresses,
        string calldata tag1,
        string calldata tag2
    ) external view returns (uint64 count, int128 summaryValue, uint8 summaryValueDecimals);
}

/// @notice Mirror AgentID seed story onto official ERC-8004 ReputationRegistry.
/// @dev Callers must NOT be agent owners/operators (self-feedback blocked).
contract Feedback8004 is Script {
    address constant REP = 0x8004B663056A597Dffe9eCcC1965A193B7388713;
    uint256 constant GOOD = 2204;
    uint256 constant FAKE = 2205;
    uint256 constant SYBIL = 2206;

    function run() external {
        IERC8004Reputation rep = IERC8004Reputation(REP);

        // GoodBot #2204 — trusted reviewers (high)
        _fb(vm.envUint("ATTESTER1_KEY"), GOOD, 5, "reliable", "quality");
        _fb(vm.envUint("ATTESTER2_KEY"), GOOD, 5, "helpful", "quality");
        _fb(vm.envUint("ATTESTER3_KEY"), GOOD, 4, "on-time", "quality");

        // FakeBot #2205 — toxic
        _fb(vm.envUint("ATTESTER1_KEY"), FAKE, 1, "spam", "toxicity");
        _fb(vm.envUint("ATTESTER2_KEY"), FAKE, 2, "impersonation", "toxicity");

        // SybilBot #2206 — sockpuppet ring + seed flag
        _fb(vm.envUint("PUPPET1_KEY"), SYBIL, 5, "reliable", "sybil");
        _fb(vm.envUint("PUPPET2_KEY"), SYBIL, 5, "helpful", "sybil");
        _fb(vm.envUint("PUPPET3_KEY"), SYBIL, 5, "on-time", "sybil");
        _fb(vm.envUint("ATTESTER1_KEY"), SYBIL, 1, "sybil-ring", "flag");

        _summary(rep, "GoodBot", GOOD);
        _summary(rep, "FakeBot", FAKE);
        _summary(rep, "SybilBot", SYBIL);
    }

    function _fb(uint256 pk, uint256 agentId, int128 value, string memory tag1, string memory tag2)
        internal
    {
        string memory uri = string.concat(
            "https://jimmywangjimmy.github.io/AgentID/agents/feedback-",
            vm.toString(agentId),
            "-",
            tag1,
            ".json"
        );
        vm.startBroadcast(pk);
        IERC8004Reputation(REP).giveFeedback(
            agentId,
            value,
            0, // star scale 1-5, no decimals
            tag1,
            tag2,
            "https://jimmywangjimmy.github.io/AgentID/",
            uri,
            bytes32(0)
        );
        vm.stopBroadcast();
        console2.log("feedback agent", agentId);
        console2.log("  value", uint256(uint128(value)));
        console2.log("  tag", tag1);
    }

    function _summary(IERC8004Reputation rep, string memory label, uint256 agentId) internal view {
        address[] memory clients = rep.getClients(agentId);
        console2.log(label, "clients", clients.length);
        if (clients.length == 0) return;
        (uint64 count, int128 summary,) = rep.getSummary(agentId, clients, "", "");
        console2.log("  count", uint256(count));
        console2.log("  summary", int256(summary));
    }
}
