// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../contracts/AgentRegistry.sol";

/// @notice Seed GoodBot / FakeBot / SybilBot story (raw vs weighted).
contract Seed is Script {
    AgentRegistry internal registry;

    function run() external {
        registry = AgentRegistry(vm.envAddress("REGISTRY"));
        uint256 oraclePk = vm.envUint("PRIVATE_KEY");

        _setSeeds(oraclePk);

        uint256 goodId = _reg(oraclePk, "https://jimmywangjimmy.github.io/AgentID/agents/good-bot.json");
        uint256 fakeId = _reg(vm.envUint("FAKE_OWNER_KEY"), "https://jimmywangjimmy.github.io/AgentID/agents/fake-bot.json");
        uint256 sybilId = _reg(vm.envUint("SYBIL_OWNER_KEY"), "https://jimmywangjimmy.github.io/AgentID/agents/sybil-bot.json");
        console2.log("GoodBot", goodId);
        console2.log("FakeBot", fakeId);
        console2.log("SybilBot", sybilId);

        _reg(vm.envUint("PUPPET1_KEY"), "ipfs://agentid/puppet-1");
        _reg(vm.envUint("PUPPET2_KEY"), "ipfs://agentid/puppet-2");
        _reg(vm.envUint("PUPPET3_KEY"), "ipfs://agentid/puppet-3");

        _attest(vm.envUint("ATTESTER1_KEY"), goodId, 5, "reliable", "ipfs://agentid/ev/good-reliable");
        _attest(vm.envUint("ATTESTER2_KEY"), goodId, 5, "helpful", "ipfs://agentid/ev/good-helpful");
        _attest(vm.envUint("ATTESTER3_KEY"), goodId, 4, "on-time", "ipfs://agentid/ev/good-ontime");

        _attest(vm.envUint("ATTESTER1_KEY"), fakeId, 1, "spam", "ipfs://agentid/ev/fake-spam");
        _attest(vm.envUint("ATTESTER2_KEY"), fakeId, 2, "impersonation", "ipfs://agentid/ev/fake-impersonation");

        _attest(vm.envUint("PUPPET1_KEY"), sybilId, 5, "reliable", "ipfs://agentid/ev/sybil-p1");
        _attest(vm.envUint("PUPPET2_KEY"), sybilId, 5, "helpful", "ipfs://agentid/ev/sybil-p2");
        _attest(vm.envUint("PUPPET3_KEY"), sybilId, 5, "on-time", "ipfs://agentid/ev/sybil-p3");
        _attest(vm.envUint("ATTESTER1_KEY"), sybilId, 1, "sybil-ring", "ipfs://agentid/ev/sybil-flag");

        _log("GoodBot", goodId);
        _log("FakeBot", fakeId);
        _log("SybilBot", sybilId);
    }

    function _setSeeds(uint256 oraclePk) internal {
        vm.startBroadcast(oraclePk);
        registry.setSeedWeight(vm.addr(vm.envUint("ATTESTER1_KEY")), 500);
        registry.setSeedWeight(vm.addr(vm.envUint("ATTESTER2_KEY")), 400);
        registry.setSeedWeight(vm.addr(vm.envUint("ATTESTER3_KEY")), 400);
        vm.stopBroadcast();
    }

    function _reg(uint256 pk, string memory uri) internal returns (uint256 id) {
        vm.startBroadcast(pk);
        id = registry.registerAgent(uri);
        vm.stopBroadcast();
    }

    function _attest(uint256 pk, uint256 agentId, int8 score, string memory tag, string memory uri)
        internal
    {
        vm.startBroadcast(pk);
        registry.attest(agentId, score, keccak256(bytes(tag)), uri);
        vm.stopBroadcast();
    }

    function _log(string memory label, uint256 id) internal view {
        (int256 raw, uint256 count, uint256 unique) = registry.getReputation(id);
        (int256 weighted,,) = registry.getWeightedReputation(id);
        console2.log(label);
        console2.log("  id", id);
        console2.log("  rawX100", uint256(raw));
        console2.log("  weightedX100", uint256(weighted));
        console2.log("  count", count);
        console2.log("  unique", unique);
    }
}
