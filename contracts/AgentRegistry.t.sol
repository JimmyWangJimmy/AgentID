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

        (int256 score, uint256 count) = registry.getReputation(id);
        assertEq(score, 5);
        assertEq(count, 1);
        assertEq(registry.attestationCount(id), 1);

        IAgentRegistryViews.Attestation memory a = registry.getAttestation(id, 0);
        assertEq(a.attester, attester);
        assertEq(a.score, int8(5));
        assertEq(a.tag, keccak256("reliable"));
    }

    function test_multiple_attestations_sum() public {
        vm.prank(owner);
        uint256 id = registry.registerAgent("ipfs://meta");

        vm.prank(attester);
        registry.attest(id, int8(5), keccak256("reliable"), "ipfs://ev1");
        vm.prank(attester2);
        registry.attest(id, int8(3), keccak256("helpful"), "ipfs://ev2");

        (int256 score, uint256 count) = registry.getReputation(id);
        assertEq(score, 8);
        assertEq(count, 2);
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
}
