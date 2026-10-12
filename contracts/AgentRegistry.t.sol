// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./AgentRegistry.sol";

/// @dev `forge test -vv`
contract AgentRegistryTest is Test {
    AgentRegistry internal registry;
    address internal owner = address(0xA11CE);
    address internal attester = address(0xB0B);
    address internal attester2 = address(0xC0DE);
    address internal attester3 = address(0xD00D);

    function setUp() public {
        registry = new AgentRegistry();
    }

    function test_register_attest_reputation() public {
        vm.prank(owner);
        uint256 id = registry.registerAgent("ipfs://meta");
        assertEq(id, 1);
        assertEq(registry.ownerOf(id), owner);
        assertEq(registry.metadataURI(id), "ipfs://meta");
        assertEq(registry.totalAgents(), 1);

        vm.prank(attester);
        registry.attest(id, int8(5), keccak256("reliable"), "ipfs://ev");

        (int256 avgX100, uint256 count, uint256 unique) = registry.getReputation(id);
        assertEq(avgX100, 500); // 5.00
        assertEq(count, 1);
        assertEq(unique, 1);
        assertEq(registry.attestationCount(id), 1);

        IAgentRegistryViews.Attestation memory a = registry.getAttestation(id, 0);
        assertEq(a.attester, attester);
        assertEq(a.score, int8(5));
        assertEq(a.tag, keccak256("reliable"));
    }

    function test_average_of_multiple_attesters() public {
        vm.prank(owner);
        uint256 id = registry.registerAgent("ipfs://meta");

        vm.prank(attester);
        registry.attest(id, int8(5), keccak256("reliable"), "ipfs://ev1");
        vm.prank(attester2);
        registry.attest(id, int8(3), keccak256("helpful"), "ipfs://ev2");

        // avg = (5+3)/2 = 4.00 → 400
        (int256 avgX100, uint256 count, uint256 unique) = registry.getReputation(id);
        assertEq(avgX100, 400);
        assertEq(count, 2);
        assertEq(unique, 2);
    }

    function test_no_self_attest() public {
        vm.prank(owner);
        uint256 id = registry.registerAgent("ipfs://meta");

        vm.prank(owner);
        vm.expectRevert(bytes("no self-attest"));
        registry.attest(id, int8(5), keccak256("reliable"), "ipfs://ev");
    }

    function test_replace_same_attester() public {
        vm.prank(owner);
        uint256 id = registry.registerAgent("ipfs://meta");

        vm.prank(attester);
        registry.attest(id, int8(2), keccak256("spam"), "ipfs://ev1");
        assertEq(registry.attestationCount(id), 1);

        // same attester overwrites — still one vote
        vm.prank(attester);
        registry.attest(id, int8(5), keccak256("reliable"), "ipfs://ev2");
        assertEq(registry.attestationCount(id), 1);

        IAgentRegistryViews.Attestation memory a = registry.getAttestation(id, 0);
        assertEq(a.score, int8(5));
        assertEq(a.tag, keccak256("reliable"));

        (int256 avgX100, uint256 count, uint256 unique) = registry.getReputation(id);
        assertEq(avgX100, 500);
        assertEq(count, 1);
        assertEq(unique, 1);
    }

    function test_good_vs_fake_scenario() public {
        // GoodBot: 5, 5, 4 → avg 466
        vm.prank(owner);
        uint256 good = registry.registerAgent("ipfs://agentid/good-bot");
        vm.prank(attester);
        registry.attest(good, int8(5), keccak256("reliable"), "ipfs://g1");
        vm.prank(attester2);
        registry.attest(good, int8(5), keccak256("helpful"), "ipfs://g2");
        vm.prank(attester3);
        registry.attest(good, int8(4), keccak256("on-time"), "ipfs://g3");

        // FakeBot: 1, 2 → avg 150
        address fakeOwner = address(0xF111111111111111111111111111111111111111);
        vm.prank(fakeOwner);
        uint256 fake = registry.registerAgent("ipfs://agentid/fake-bot");
        vm.prank(attester);
        registry.attest(fake, int8(1), keccak256("spam"), "ipfs://f1");
        vm.prank(attester2);
        registry.attest(fake, int8(2), keccak256("impersonation"), "ipfs://f2");

        (int256 goodAvg, uint256 goodCount, uint256 goodUnique) = registry.getReputation(good);
        (int256 fakeAvg, uint256 fakeCount, uint256 fakeUnique) = registry.getReputation(fake);

        assertEq(goodAvg, 466); // (5+5+4)*100/3 = 1400/3 = 466
        assertEq(goodCount, 3);
        assertEq(goodUnique, 3);
        assertEq(fakeAvg, 150); // (1+2)*100/2 = 150
        assertEq(fakeCount, 2);
        assertEq(fakeUnique, 2);
        assertGt(goodAvg, fakeAvg);
    }

    function test_score_out_of_range_reverts() public {
        vm.prank(owner);
        uint256 id = registry.registerAgent("ipfs://meta");

        vm.prank(attester);
        vm.expectRevert(bytes("score out of range"));
        registry.attest(id, int8(0), keccak256("bad"), "ipfs://ev");

        vm.prank(attester);
        vm.expectRevert(bytes("score out of range"));
        registry.attest(id, int8(6), keccak256("bad"), "ipfs://ev");
    }

    function test_empty_metadata_reverts() public {
        vm.prank(owner);
        vm.expectRevert(bytes("metadataURI required"));
        registry.registerAgent("");
    }

    function test_unknown_agent_reverts() public {
        vm.expectRevert(bytes("unknown agentId"));
        registry.ownerOf(1);

        vm.expectRevert(bytes("unknown agentId"));
        registry.getReputation(99);
    }

    function test_tag_and_uri_required() public {
        vm.prank(owner);
        uint256 id = registry.registerAgent("ipfs://meta");

        vm.prank(attester);
        vm.expectRevert(bytes("tag required"));
        registry.attest(id, int8(5), bytes32(0), "ipfs://ev");

        vm.prank(attester);
        vm.expectRevert(bytes("uri required"));
        registry.attest(id, int8(5), keccak256("reliable"), "");
    }

    function test_zero_attestations_reputation() public {
        vm.prank(owner);
        uint256 id = registry.registerAgent("ipfs://meta");
        (int256 avg, uint256 count, uint256 unique) = registry.getReputation(id);
        assertEq(avg, 0);
        assertEq(count, 0);
        assertEq(unique, 0);
    }
}
