// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../contracts/AgentRegistry.sol";

/// @notice Broadcast deploy of AgentRegistry to Monad testnet (or any EVM RPC).
/// @dev Example:
///   export PRIVATE_KEY=0x...
///   export RPC_URL=https://testnet-rpc.monad.xyz
///   forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL --broadcast -vvvv
contract Deploy is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(pk);
        vm.startBroadcast(pk);
        AgentRegistry registry = new AgentRegistry();
        console2.log("AgentRegistry deployed at:", address(registry));
        console2.log("Deployer:", deployer);
        vm.stopBroadcast();
    }
}
