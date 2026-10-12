// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

/// @notice Dual-path: register an agent on the official ERC-8004 IdentityRegistry
///         on Monad testnet (CREATE2 singleton).
/// @dev Identity: 0x8004A818BFB912233c491871b3d84c89A494BD9e
///      Spec: https://eips.ethereum.org/EIPS/eip-8004
///      Env: PRIVATE_KEY, AGENT_URI (HTTPS registration-v1 JSON)
interface IERC8004Identity {
    function register(string calldata agentURI) external returns (uint256 agentId);
    function setAgentURI(uint256 agentId, string calldata newURI) external;
}

contract Register8004 is Script {
    address constant IDENTITY =
        0x8004A818BFB912233c491871b3d84c89A494BD9e;

    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        string memory uri = vm.envString("AGENT_URI");
        vm.startBroadcast(pk);
        uint256 agentId = IERC8004Identity(IDENTITY).register(uri);
        console2.log("Official ERC-8004 IdentityRegistry agentId:", agentId);
        console2.log("agentURI:", uri);
        console2.log("Global id: eip155:10143:0x8004A818BFB912233c491871b3d84c89A494BD9e");
        vm.stopBroadcast();
    }
}
