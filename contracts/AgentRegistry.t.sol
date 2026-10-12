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
        assertEq(registry.agentOfOwner(owner), id);

        vm.prank(attester);
        registry.attest(id, int8(5), keccak256("reliable"), "ipfs://ev");

        (int256 avgX100, uint256 count, uint256 unique) = registry.getReputation(id);
        assertEq(avgX100, 500);
        assertEq(count, 1);
        assertEq(unique, 1);
        assertEq(registry.attestationCount(id), 1);
    }

    function test_average_of_multiple_attesters() public {
        vm.prank(owner);
        uint256 id = registry.registerAgent("ipfs://meta");

        vm.prank(attester);
        registry.attest(id, int8(5), keccak256("reliable"), "ipfs://ev1");
        vm.prank(attester2);
        registry.attest(id, int8(3), keccak256("helpful"), "ipfs://ev2");

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
        vm.prank(attester);
        registry.attest(id, int8(5), keccak256("reliable"), "ipfs://ev2");
        assertEq(registry.attestationCount(id), 1);

        (int256 avgX100, uint256 count, uint256 unique) = registry.getReputation(id);
        assertEq(avgX100, 500);
        assertEq(count, 1);
        assertEq(unique, 1);
    }

    function test_good_vs_fake_scenario() public {
        vm.prank(owner);
        uint256 good = registry.registerAgent("ipfs://agentid/good-bot");
        vm.prank(attester);
        registry.attest(good, int8(5), keccak256("reliable"), "ipfs://g1");
        vm.prank(attester2);
        registry.attest(good, int8(5), keccak256("helpful"), "ipfs://g2");
        vm.prank(attester3);
        registry.attest(good, int8(4), keccak256("on-time"), "ipfs://g3");

        address fakeOwner = address(0xF111111111111111111111111111111111111111);
        vm.prank(fakeOwner);
        uint256 fake = registry.registerAgent("ipfs://agentid/fake-bot");
        vm.prank(attester);
        registry.attest(fake, int8(1), keccak256("spam"), "ipfs://f1");
        vm.prank(attester2);
        registry.attest(fake, int8(2), keccak256("impersonation"), "ipfs://f2");

        (int256 goodAvg,,) = registry.getReputation(good);
        (int256 fakeAvg,,) = registry.getReputation(fake);
        assertEq(goodAvg, 466);
        assertEq(fakeAvg, 150);
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
        vm.expectRevert(bytes("unknown agentId"));
        registry.getWeightedReputation(99);
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
        (int256 wAvg, uint256 wCount, uint256 wUnique) = registry.getWeightedReputation(id);
        assertEq(wAvg, 0);
        assertEq(wCount, 0);
        assertEq(wUnique, 0);
    }

    function test_oracle_seed_weight_default() public {
        assertEq(registry.oracle(), address(this));
        assertEq(registry.seedWeight(address(this)), 500);
        assertEq(registry.attesterWeight(address(this)), 500);
        assertEq(registry.attesterWeight(attester), 10); // BASE_WEIGHT
    }

    function test_setSeedWeight_only_oracle() public {
        registry.setSeedWeight(attester, 400);
        assertEq(registry.attesterWeight(attester), 400);

        vm.prank(attester);
        vm.expectRevert(bytes("only oracle"));
        registry.setSeedWeight(attester2, 100);

        vm.expectRevert(bytes("weight cap"));
        registry.setSeedWeight(attester2, 501);
    }

    /// @notice Core differentiator: sockpuppet ring fools raw avg, dies on weighted.
    function test_sybil_ring_raw_high_weighted_low() public {
        // Bootstrap: seed mid/high-weight reviewers
        registry.setSeedWeight(attester, 500);
        registry.setSeedWeight(attester2, 400);
        registry.setSeedWeight(attester3, 400);

        // GoodBot — high scores from seeded reviewers
        vm.prank(owner);
        uint256 good = registry.registerAgent(
            "https://jimmywangjimmy.github.io/AgentID/agents/good-bot.json"
        );
        vm.prank(attester);
        registry.attest(good, int8(5), keccak256("reliable"), "ipfs://g1");
        vm.prank(attester2);
        registry.attest(good, int8(5), keccak256("helpful"), "ipfs://g2");
        vm.prank(attester3);
        registry.attest(good, int8(4), keccak256("on-time"), "ipfs://g3");

        (int256 gRaw,,) = registry.getReputation(good);
        (int256 gW,,) = registry.getWeightedReputation(good);
        assertEq(gRaw, 466);
        // All high weight → weighted ≈ raw
        assertEq(gW, 469); // (500*5+400*5+400*4)*100/1300 = 469

        // FakeBot — honestly low
        address fakeOwner = address(0xFA11);
        vm.prank(fakeOwner);
        uint256 fake = registry.registerAgent(
            "https://jimmywangjimmy.github.io/AgentID/agents/fake-bot.json"
        );
        vm.prank(attester);
        registry.attest(fake, int8(1), keccak256("spam"), "ipfs://f1");
        vm.prank(attester2);
        registry.attest(fake, int8(2), keccak256("impersonation"), "ipfs://f2");
        (int256 fRaw,,) = registry.getReputation(fake);
        (int256 fW,,) = registry.getWeightedReputation(fake);
        assertEq(fRaw, 150);
        assertEq(fW, 144); // (500*1 + 400*2)*100 / 900 = 130000/900 = 144

        // SybilBot — sockpuppet ring: 3 fresh wallets register worthless agents, all score 5
        address sybilOwner = address(0x51B1);
        address pup1 = address(0x1111);
        address pup2 = address(0x2222);
        address pup3 = address(0x3333);

        vm.prank(sybilOwner);
        uint256 sybil = registry.registerAgent(
            "https://jimmywangjimmy.github.io/AgentID/agents/sybil-bot.json"
        );

        vm.prank(pup1);
        registry.registerAgent("ipfs://puppet-1");
        vm.prank(pup2);
        registry.registerAgent("ipfs://puppet-2");
        vm.prank(pup3);
        registry.registerAgent("ipfs://puppet-3");

        // Puppets have 0 attestations → weight = BASE_WEIGHT (10)
        assertEq(registry.attesterWeight(pup1), 10);
        assertEq(registry.attesterWeight(pup2), 10);
        assertEq(registry.attesterWeight(pup3), 10);

        vm.prank(pup1);
        registry.attest(sybil, int8(5), keccak256("reliable"), "ipfs://s1");
        vm.prank(pup2);
        registry.attest(sybil, int8(5), keccak256("helpful"), "ipfs://s2");
        vm.prank(pup3);
        registry.attest(sybil, int8(5), keccak256("on-time"), "ipfs://s3");

        // Honest seed critic flags the ring
        vm.prank(attester); // weight 500
        registry.attest(sybil, int8(1), keccak256("sybil-ring"), "ipfs://s-flag");

        (int256 sRaw, uint256 sCount,) = registry.getReputation(sybil);
        (int256 sW,,) = registry.getWeightedReputation(sybil);

        // Raw: (5+5+5+1)/4 = 4.00 → 400 — looks "fine"
        assertEq(sRaw, 400);
        assertEq(sCount, 4);

        // Weighted: (10*5 + 10*5 + 10*5 + 500*1) * 100 / (10+10+10+500)
        //         = (150 + 500) * 100 / 530 = 65000 / 530 = 122
        assertEq(sW, 122);

        // The punchline
        assertGt(sRaw, sW);
        assertGt(gW, sW);
        assertGt(gRaw, fRaw);
    }

    function test_attester_earned_weight_from_owned_agent() public {
        // Give attester an agent that earned unweighted avg 500 from oracle
        vm.prank(attester);
        uint256 reviewerAgent = registry.registerAgent("ipfs://reviewer");
        // oracle (this) has seed weight 500
        registry.attest(reviewerAgent, int8(5), keccak256("reliable"), "ipfs://r1");
        assertEq(registry.attesterWeight(attester), 500); // earned from avg 500

        vm.prank(owner);
        uint256 target = registry.registerAgent("ipfs://target");
        vm.prank(attester);
        registry.attest(target, int8(4), keccak256("helpful"), "ipfs://t1");

        (int256 w,,) = registry.getWeightedReputation(target);
        assertEq(w, 400);
    }
}
