# AgentID — On-chain deploy (Monad testnet)

## Live deployment (Metropolis) — current

| | |
|---|---|
| **Status** | Deployed + seeded (GoodBot vs FakeBot) |
| **Network** | Monad Testnet · chain id `10143` |
| **RPC** | `https://testnet-rpc.monad.xyz` |
| **Contract** | [`0xDCcBbFFC7D0912674760579fAba210a2a729f859`](https://testnet.monadvision.com/address/0xDCcBbFFC7D0912674760579fAba210a2a729f859) |
| **Deploy tx** | [`0xbf6e15f64d19b8ac558a2c5a93d9f2fb12de2f9c8facdd90966ef694f412a3ab`](https://testnet.monadvision.com/tx/0xbf6e15f64d19b8ac558a2c5a93d9f2fb12de2f9c8facdd90966ef694f412a3ab) |
| **Policy** | No self-attest · one vote / attester · `getReputation` → `(avg×100, count, unique)` |
| **Deployer** | Ephemeral hackathon wallet `0xE713f7750A9dFbD2CA091ad75d77229786C73F41` — **no mainnet funds** |

### Seeded story

| Agent | Id | URI | Reputation |
|-------|----|-----|------------|
| **GoodBot** | 1 | `ipfs://agentid/good-bot` | avg **466** · count 3 · unique 3 |
| **FakeBot** | 2 | `ipfs://agentid/fake-bot` | avg **150** · count 2 · unique 2 |

| Step | Tx |
|------|-----|
| Register GoodBot | [`0x830a1a87…`](https://testnet.monadvision.com/tx/0x830a1a87b1cbeacbf321d9284db4b876de9198e77b1a7ca29d7b8e2ca4995f0c) |
| Register FakeBot | [`0x4c583cef…`](https://testnet.monadvision.com/tx/0x4c583cef5f4a1db9348c39906acc821b1872e769f1a96b54531faf175c917ede) |
| Attest GoodBot #1 (5 · reliable) | [`0xbbe20a9a…`](https://testnet.monadvision.com/tx/0xbbe20a9a372708cc9aea5f5d3167a632f80befe1e06262253bfd1e4e0826b981) |
| Attest GoodBot #2 (5 · helpful) | [`0xb98cd94e…`](https://testnet.monadvision.com/tx/0xb98cd94eab77956e990b9a45882f353aa47809d9dfdeab4ac07f01e26dd9d6ec) |
| Attest GoodBot #3 (4 · on-time) | [`0xd7bb28c4…`](https://testnet.monadvision.com/tx/0xd7bb28c4401b6f6fa1f169179c4255327b6fcda66d5c3a54ec01b0825b550853) |
| Attest FakeBot #1 (1 · spam) | [`0x2849f086…`](https://testnet.monadvision.com/tx/0x2849f086cb79a7915a6119abb284604e7315ba63fea5358db25c07e0f0368a98) |
| Attest FakeBot #2 (2 · impersonation) | [`0x2a35434a…`](https://testnet.monadvision.com/tx/0x2a35434a1195afced28f346938334e095add6230c9179b26ac541c3ed52dcece) |

Verify:

```bash
REG=0xDCcBbFFC7D0912674760579fAba210a2a729f859
cast call "$REG" "getReputation(uint256)(int256,uint256,uint256)" 1 --rpc-url https://testnet-rpc.monad.xyz
cast call "$REG" "getReputation(uint256)(int256,uint256,uint256)" 2 --rpc-url https://testnet-rpc.monad.xyz
# expect: 466 3 3  and  150 2 2
```

Broadcast artifacts: `broadcast/Deploy.s.sol/10143/` · `broadcast/Seed.s.sol/10143/`.

### Superseded (v1 sum-only demo)

| | |
|---|---|
| Contract | [`0x7Be01cFC771fA2FD292113dA83881E0deC56ad13`](https://testnet.monadvision.com/address/0x7Be01cFC771fA2FD292113dA83881E0deC56ad13) |
| Note | Pre–sybil-lite / pre–average API. Keep for provenance only. |

---

## Network reference

**Network:** Monad Testnet · **Chain ID:** `10143` · **Currency:** `MON`  
**RPC:** `https://testnet-rpc.monad.xyz`  
**Explorers:** [MonadVision](https://testnet.monadvision.com) · [Monadscan](https://testnet.monadscan.com)  
**Faucet:** [https://faucet.monad.xyz](https://faucet.monad.xyz)

## Build & test

```bash
cd AgentID
forge test -vv
npm test
```

## Deploy + seed

```bash
export PRIVATE_KEY=0x...          # never commit
export RPC_URL=https://testnet-rpc.monad.xyz
export FAKE_OWNER_KEY=0x...
export ATTESTER1_KEY=0x...
export ATTESTER2_KEY=0x...
export ATTESTER3_KEY=0x...

forge script script/Deploy.s.sol:Deploy --rpc-url "$RPC_URL" --broadcast -vvvv
export REGISTRY=0x...             # from deploy log
forge script script/Seed.s.sol:Seed --rpc-url "$RPC_URL" --broadcast --slow -vvvv
```

Fund ephemeral attesters with tiny MON from the deployer before seeding.
