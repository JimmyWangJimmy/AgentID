// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./AgentRegistry.sol";

/// @dev Run with Foundry when installed: `forge test`
contract AgentRegistryTest is Test {
    AgentRegistry internal registry;
    address internal owner = address(0xA11CE);
    address internal attester = address(0xB0B);

    function setUp() public {
        registry = new AgentRegistry();
    }

    function test_register_attest_reputation() public {
        vm.prank(owner);
        uint256 id = registry.registerAgent("ipfs://meta");
        assertEq(id, 1);
        assertEq(registry.ownerOf(id), owner);
        assertEq(registry.totalAgents(), 1);

        vm.prank(attester);
        registry.attest(id, int8(5), keccak256("reliable"), "ipfs://ev");

        (int256 score, uint256 count) = registry.getReputation(id);
        assertEq(score, 5);
        assertEq(count, 1);
    }

    function test_score_out_of_range_reverts() public {
        vm.prank(owner);
        uint256 id = registry.registerAgent("ipfs://meta");

        vm.prank(attester);
        vm.expectRevert(bytes("score out of range"));
        registry.attest(id, int8(0), keccak256("bad"), "ipfs://ev");
    }
}
