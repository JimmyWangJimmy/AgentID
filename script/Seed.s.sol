// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../contracts/AgentRegistry.sol";

/// @notice Seed GoodBot vs FakeBot story on a deployed AgentRegistry.
/// @dev Env: PRIVATE_KEY (GoodBot owner), FAKE_OWNER_KEY, ATTESTER1_KEY,
///      ATTESTER2_KEY, ATTESTER3_KEY, REGISTRY (address).
contract Seed is Script {
    function run() external {
        address registryAddr = vm.envAddress("REGISTRY");
        AgentRegistry registry = AgentRegistry(registryAddr);

        uint256 goodPk = vm.envUint("PRIVATE_KEY");
        uint256 fakePk = vm.envUint("FAKE_OWNER_KEY");
        uint256 a1Pk = vm.envUint("ATTESTER1_KEY");
        uint256 a2Pk = vm.envUint("ATTESTER2_KEY");
        uint256 a3Pk = vm.envUint("ATTESTER3_KEY");

        // ── Register GoodBot ────────────────────────────────────────────
        vm.startBroadcast(goodPk);
        uint256 goodId = registry.registerAgent("ipfs://agentid/good-bot");
        vm.stopBroadcast();
        console2.log("GoodBot agentId:", goodId);

        // ── Register FakeBot (different owner) ──────────────────────────
        vm.startBroadcast(fakePk);
        uint256 fakeId = registry.registerAgent("ipfs://agentid/fake-bot");
        vm.stopBroadcast();
        console2.log("FakeBot agentId:", fakeId);

        // ── Attest GoodBot: 5 / 5 / 4 ───────────────────────────────────
        vm.startBroadcast(a1Pk);
        registry.attest(goodId, int8(5), keccak256("reliable"), "ipfs://agentid/ev/good-reliable");
        vm.stopBroadcast();

        vm.startBroadcast(a2Pk);
        registry.attest(goodId, int8(5), keccak256("helpful"), "ipfs://agentid/ev/good-helpful");
        vm.stopBroadcast();

        vm.startBroadcast(a3Pk);
        registry.attest(goodId, int8(4), keccak256("on-time"), "ipfs://agentid/ev/good-ontime");
        vm.stopBroadcast();

        // ── Attest FakeBot: 1 / 2 ───────────────────────────────────────
        vm.startBroadcast(a1Pk);
        registry.attest(fakeId, int8(1), keccak256("spam"), "ipfs://agentid/ev/fake-spam");
        vm.stopBroadcast();

        vm.startBroadcast(a2Pk);
        registry.attest(fakeId, int8(2), keccak256("impersonation"), "ipfs://agentid/ev/fake-impersonation");
        vm.stopBroadcast();

        (int256 gAvg, uint256 gCount, uint256 gUnique) = registry.getReputation(goodId);
        (int256 fAvg, uint256 fCount, uint256 fUnique) = registry.getReputation(fakeId);
        console2.log("GoodBot avgX100:", uint256(gAvg));
        console2.log("GoodBot count:", gCount);
        console2.log("GoodBot unique:", gUnique);
        console2.log("FakeBot avgX100:", uint256(fAvg));
        console2.log("FakeBot count:", fCount);
        console2.log("FakeBot unique:", fUnique);
    }
}
