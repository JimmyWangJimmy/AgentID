# AgentID — On-chain deploy (Monad testnet)

**Network:** Monad Testnet  
**Chain ID:** `10143`  
**Currency:** `MON`  
**Public RPC:** `https://testnet-rpc.monad.xyz`  
**Explorers:** [MonadVision](https://testnet.monadvision.com) · [Monadscan](https://testnet.monadscan.com)  
**Faucet:** [https://faucet.monad.xyz](https://faucet.monad.xyz)

Do **not** use mainnet or spend real money. Testnet only.

## Prerequisites

1. [Foundry](https://book.getfoundry.sh/) (`forge`, `cast`)
2. A funded **testnet** wallet (ephemeral key recommended for the hackathon)
3. Env vars (never commit `.env`):

```bash
export PRIVATE_KEY=0xYOUR_TESTNET_PRIVATE_KEY   # 32-byte hex, with 0x
export RPC_URL=https://testnet-rpc.monad.xyz    # optional; foundry.toml has default
```

Get MON from the [faucet](https://faucet.monad.xyz) before broadcasting.

## Build & test (no key needed)

```bash
cd AgentID
forge install          # if lib/forge-std missing
forge build
forge test -vv
```

## Deploy (broadcast)

### Option A — forge script (preferred)

```bash
export PRIVATE_KEY=0x...
export RPC_URL=https://testnet-rpc.monad.xyz

forge script script/Deploy.s.sol:Deploy \
  --rpc-url "$RPC_URL" \
  --broadcast \
  -vvvv
```

Or use the named endpoint from `foundry.toml`:

```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url monad_testnet \
  --broadcast \
  -vvvv
```

The script logs `AgentRegistry deployed at: 0x…`.

### Option B — forge create

```bash
forge create contracts/AgentRegistry.sol:AgentRegistry \
  --rpc-url "$RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast
```

## Smoke-test on chain

```bash
REG=0xDEPLOYED_ADDRESS

# register (from deployer or any wallet)
cast send "$REG" "registerAgent(string)" "ipfs://agentid-demo" \
  --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY"

# attest (use a second key if you want a different attester)
cast send "$REG" "attest(uint256,int8,bytes32,string)" \
  1 5 $(cast keccak "reliable") "ipfs://evidence" \
  --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY"

# reputation
cast call "$REG" "getReputation(uint256)(int256,uint256)" 1 \
  --rpc-url "$RPC_URL"
```

## After deploy — update README

Paste into `README.md`:

```
Contract: 0x…
Explorer: https://testnet.monadvision.com/address/0x…
Chain ID: 10143
```

## What Jimmy / parent must provide

| Item | Why |
|------|-----|
| Testnet private key (or approve generating an ephemeral one) | Sign deploy + demo txs |
| Faucet MON on that address | Cover gas |
| Confirmation: testnet only | No mainnet spend |

Recommended: generate a **throwaway** wallet for Metropolis, faucet it, deploy, then discard or keep only for the demo. Prefer a secure form / env injection over pasting the key in chat.
