# AgentID — On-chain deploy (Monad testnet)

## Live deployment (Metropolis)

| | |
|---|---|
| **Status** | Deployed |
| **Network** | Monad Testnet · chain id `10143` |
| **RPC** | `https://testnet-rpc.monad.xyz` |
| **Contract** | [`0x7Be01cFC771fA2FD292113dA83881E0deC56ad13`](https://testnet.monadvision.com/address/0x7Be01cFC771fA2FD292113dA83881E0deC56ad13) |
| **Deploy tx** | [`0x01a0d4f55603dac0a7d9425f0fd75935fea732156a6604d06d59ba274f8c3cd1`](https://testnet.monadvision.com/tx/0x01a0d4f55603dac0a7d9425f0fd75935fea732156a6604d06d59ba274f8c3cd1) |
| **Explorers** | [MonadVision](https://testnet.monadvision.com/address/0x7Be01cFC771fA2FD292113dA83881E0deC56ad13) · [Monadscan](https://testnet.monadscan.com/address/0x7Be01cFC771fA2FD292113dA83881E0deC56ad13) |
| **Deployer** | Ephemeral hackathon-only wallet `0xE713f7750A9dFbD2CA091ad75d77229786C73F41` — **no mainnet funds** |

`forge test` 6/6 pass. Broadcast artifact: `broadcast/Deploy.s.sol/10143/run-latest.json`.

---

## Network reference

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
REG=0x7Be01cFC771fA2FD292113dA83881E0deC56ad13

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

## Redeploy notes

README already lists the live address above. To redeploy (new ephemeral key + faucet):

```
Contract: 0x…
Explorer: https://testnet.monadvision.com/address/0x…
Chain ID: 10143
```

## What you need to redeploy

| Item | Why |
|------|-----|
| Testnet private key (or approve generating an ephemeral one) | Sign deploy + demo txs |
| Faucet MON on that address | Cover gas |
| Confirmation: testnet only | No mainnet spend |

Recommended: generate a **throwaway** wallet for Metropolis, faucet it, deploy, then discard or keep only for the demo. Prefer a secure form / env injection over pasting the key in chat.
