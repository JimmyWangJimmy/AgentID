# AgentID — On-chain deploy (Monad testnet) · v4 · 8004 feedback + EigenTrust-lite

## Narrative

> **ERC-8004 gives public feedback; AgentID is the anti-Sybil aggregator on Monad — a sockpuppet ring looks fine on raw average, dies on trust-weighted score.**

## Live deployment (v3) — current

| | |
|---|---|
| **Status** | Deployed + seeded + official Identity **and** Reputation `giveFeedback` (v4) |
| **Network** | Monad Testnet · chain id `10143` |
| **RPC** | `https://testnet-rpc.monad.xyz` |
| **AgentID scorer** | [`0x8916357EDB7598d20E257404213CF3D1C099c310`](https://testnet.monadvision.com/address/0x8916357EDB7598d20E257404213CF3D1C099c310) |
| **Deploy tx** | [`0x24f5ef3e…8031`](https://testnet.monadvision.com/tx/0x24f5ef3e290ee44b2d3c4c75c60b0041f3a296f17db7237c6cd50ab90fe98031) |
| **Policy** | No self-attest · one vote / attester · `getReputation` (raw) + `getWeightedReputation` (EigenTrust-lite) |
| **Weights** | `BASE_WEIGHT=10` · `MAX_WEIGHT=500` · oracle/seed bootstrap · one-hop unweighted avg of attester's agent |
| **Deployer / oracle** | `0xE713f7750A9dFbD2CA091ad75d77229786C73F41` — ephemeral hackathon wallet, **no mainnet funds** |

### Official ERC-8004 (Monad testnet CREATE2)

| Registry | Address |
|----------|---------|
| Identity | [`0x8004A818BFB912233c491871b3d84c89A494BD9e`](https://testnet.monadvision.com/address/0x8004A818BFB912233c491871b3d84c89A494BD9e) |
| Reputation | `0x8004B663056A597Dffe9eCcC1965A193B7388713` |
| Validation | `0x8004Cb1BF31DAf7788923b405b754f57acEB4272` |

| Agent | AgentID scorer id | Official Identity agentId | Registration JSON |
|-------|-------------------|---------------------------|-------------------|
| **GoodBot** | 1 | **2204** | [good-bot.json](./agents/good-bot.json) |
| **FakeBot** | 2 | **2205** | [fake-bot.json](./agents/fake-bot.json) |
| **SybilBot** | 3 | **2206** | [sybil-bot.json](./agents/sybil-bot.json) |

Official register txs:

| Agent | Tx |
|-------|-----|
| GoodBot → Identity #2204 | [`0x62320139…5914`](https://testnet.monadvision.com/tx/0x6232013954d468e0c764d07a5edb83c320bb6656ca218f2b29e6239c67d05914) |
| FakeBot → Identity #2205 | [`0x8f511368…32cb`](https://testnet.monadvision.com/tx/0x8f51136800e37f9022b11ac8d4fabeabc59bb93387628d4c7c243aeb145332cb) |
| SybilBot → Identity #2206 | [`0xd7253991…c503`](https://testnet.monadvision.com/tx/0xd725399132b7f3a8a59d115e6872e57936e97c4783923bd56462b9def447c503) |

Global id form: `eip155:10143:0x8004A818BFB912233c491871b3d84c89A494BD9e` + `agentId`.

### Raw vs weighted (explorer-verifiable)

| Agent | Id | Raw ×100 | Weighted ×100 | Count | Story |
|-------|-----|----------|---------------|-------|-------|
| **GoodBot** | 1 | **466** (4.66) | **469** (4.69) | 3 | High scores from seeded reviewers (w=500/400/400) |
| **FakeBot** | 2 | **150** (1.50) | **144** (1.44) | 2 | Honestly toxic |
| **SybilBot** | 3 | **400** (4.00) | **122** (1.22) | 4 | 3 puppets × 5★ (w=10) + seed flag × 1 (w=500) |

Punchline: **SybilBot raw looks fine (4.00); weighted dies (1.22).**

Verify:

```bash
REG=0x8916357EDB7598d20E257404213CF3D1C099c310
RPC=https://testnet-rpc.monad.xyz
for id in 1 2 3; do
  cast call "$REG" "getReputation(uint256)(int256,uint256,uint256)" $id --rpc-url $RPC
  cast call "$REG" "getWeightedReputation(uint256)(int256,uint256,uint256)" $id --rpc-url $RPC
done
# expect: Good 466/469 · Fake 150/144 · Sybil 400/122
```

### Seed tx map (AgentID scorer)

| Step | Tx |
|------|-----|
| setSeedWeight A1=500 | [`0x9e3ccc59…1ad2`](https://testnet.monadvision.com/tx/0x9e3ccc59bd6f199470c2be798a4912431433c0067f6ccd9498e8e5d60ff31ad2) |
| setSeedWeight A2=400 | [`0x4fce2a30…b00a`](https://testnet.monadvision.com/tx/0x4fce2a30adfe1cc17fe38631e6e7f5cb8d084acc4ec0c3f3b0da87b06c0ab00a) |
| setSeedWeight A3=400 | [`0x5576f557…7f8b`](https://testnet.monadvision.com/tx/0x5576f5578e6339502e0c40936e701a9cb540f83434a9a7cab1982edee6037f8b) |
| Register GoodBot | [`0xe833b867…8d50`](https://testnet.monadvision.com/tx/0xe833b86702c97a7b889fbba2df1a9adeb32523f9b05440d553cc0606007c8d50) |
| Register FakeBot | [`0xc5c83586…8129`](https://testnet.monadvision.com/tx/0xc5c8358642dfe3b5d61c2e5ceceb0bf5059ff82e3e1dfc06343adbf1b4848129) |
| Register SybilBot | [`0x4e787fe9…1643`](https://testnet.monadvision.com/tx/0x4e787fe9ce387565f36c0fe498ee781a982041896da529dbc8af9627e07f1643) |
| Register puppet-1 | [`0x00dcc13f…e5bd`](https://testnet.monadvision.com/tx/0x00dcc13fd7d89134b738bd572a2a424dcc7f96614add7f8ab23a2cdd2c95e5bd) |
| Register puppet-2 | [`0xeec31777…aea6`](https://testnet.monadvision.com/tx/0xeec31777fb7f96bcccdd776bc9b4b66ad2a90a8d39a6dcd5ffc5795a9187aea6) |
| Register puppet-3 | [`0x01d795b2…6275`](https://testnet.monadvision.com/tx/0x01d795b2188e483c76a7e1ab2f1256e431b601b4e34bb2a948ffa4c12f356275) |
| Attest Good #1 (5) | [`0x66bb512b…a706`](https://testnet.monadvision.com/tx/0x66bb512b0765aea3fc66c0a0e5fa2d3f02614034435220d508d88ae1ca31a706) |
| Attest Good #2 (5) | [`0x2939db5f…94b4`](https://testnet.monadvision.com/tx/0x2939db5f574e31623e8b6cef8d49901713a801c15553a91695d911d6747794b4) |
| Attest Good #3 (4) | [`0xa0b8e625…b9bc`](https://testnet.monadvision.com/tx/0xa0b8e6257efc461a4b639c65490151922d1848a0f8eab911949de10b4853b9bc) |
| Attest Fake #1 (1) | [`0x30994a87…2ead`](https://testnet.monadvision.com/tx/0x30994a87aae4cd7730011c6441cf14e5eee01e8055e336b1bdee353668ce2ead) |
| Attest Fake #2 (2) | [`0x92e9be14…e6d8`](https://testnet.monadvision.com/tx/0x92e9be1440bda9e75ba7db863082134cf34bdd54053e5fcd5236a6a5a227e6d8) |
| Attest Sybil p1 (5) | [`0xdadc5d33…5f5f`](https://testnet.monadvision.com/tx/0xdadc5d339de6c97b8c519d428f94661757e7f1a0e2150a67854876df00625f5f) |
| Attest Sybil p2 (5) | [`0x88e64e58…423f`](https://testnet.monadvision.com/tx/0x88e64e5859bee71bdf1bf7480b6203a57945e81878c4356984a7defce381423f) |
| Attest Sybil p3 (5) | [`0xbbcda736…beb1`](https://testnet.monadvision.com/tx/0xbbcda7362a6294d74c2f46ea40bbb9db90554116e8fc2349fb82073bf462beb1) |
| Attest Sybil flag (1) | [`0x640cb053…44db`](https://testnet.monadvision.com/tx/0x640cb053ab32934d08ee6322f985b2ddc66cc35f0ea30860aafddbcad59c44db) |

Addresses (public):

| Role | Address |
|------|---------|
| Oracle / GoodBot owner | `0xE713f7750A9dFbD2CA091ad75d77229786C73F41` |
| FakeBot owner | `0xC72f714f62056F415800Bc5679812A2a0f889993` |
| SybilBot owner | `0x15dE4089D3FbE78d384B817E45EAC69D4A45d9Cb` |
| Attester1 (seed 500) | `0x2606Bd77AF4A939e72766285AF0dAcAA405dFc06` |
| Attester2 (seed 400) | `0x2e26876454C294bDeF1C1E22a08df62BA5594733` |
| Attester3 (seed 400) | `0xf3C4490DDD771488B147c1F3dA56885D6AD485CF` |
| Puppet1 | `0x6E4866835fb9d60Eb91a5DfCae89F4f9b1e2268d` |
| Puppet2 | `0x2c8CecdCA8F47e4Cddf138c172671635827149f8` |
| Puppet3 | `0x48b81AC2ea5399b5ea039eECfFa6C5bd73B7f554` |

### Dual-path (AgentID + official 8004)

**(a) AgentID scoring engine** — this contract: register / attest / `getReputation` + `getWeightedReputation`.

**(b) Official IdentityRegistry** — mint ERC-721 agent NFT:

```bash
# script/Register8004.s.sol
export PRIVATE_KEY=0x...
export AGENT_URI=https://jimmywangjimmy.github.io/AgentID/agents/good-bot.json
forge script script/Register8004.s.sol:Register8004 --rpc-url https://testnet-rpc.monad.xyz --broadcast
```

ABI snippet:

```solidity
interface IERC8004Identity {
    function register(string calldata agentURI) external returns (uint256 agentId);
    function setAgentURI(uint256 agentId, string calldata newURI) external;
}
// Identity = 0x8004A818BFB912233c491871b3d84c89A494BD9e
```

Reference: [EIP-8004](https://eips.ethereum.org/EIPS/eip-8004) · [erc-8004-contracts](https://github.com/erc-8004/erc-8004-contracts).

### Official ReputationRegistry feedback (v4) — LIVE

AgentID is the aggregator lens. The same seed story is now written as `giveFeedback` on the official registry:

| Registry | Address |
|----------|---------|
| Reputation | [`0x8004B663056A597Dffe9eCcC1965A193B7388713`](https://testnet.monadvision.com/address/0x8004B663056A597Dffe9eCcC1965A193B7388713) |

| Agent | Official id | Clients | `getSummary` (stars, decimals=0) |
|-------|-------------|---------|----------------------------------|
| GoodBot | 2204 | 3 | count 3–4 · summary ≈ **4** |
| FakeBot | 2205 | 2 | count 2 · summary ≈ **1** |
| SybilBot | 2206 | 4 | count 4 · summary ≈ **4** (raw still looks fine!) |

Feedback txs:

| Agent | Note | Tx |
|-------|------|----|
| GoodBot #2204 | A1 reliable 5 | [`0x44b7205d…ea8c`](https://testnet.monadvision.com/tx/0x44b7205dd287b3b99c7d2ff7f10d13d6385a2f6d5fc706bb7ecc3b821d73ea8c) |
| GoodBot #2204 | A2 helpful 5 | [`0xd54a3151…fe09`](https://testnet.monadvision.com/tx/0xd54a3151027040b87aea9a242b5ca3a5bdd1f2d88d90cca705c5deea10b6fe09) |
| GoodBot #2204 | A3 on-time 4 | [`0x5d39ce68…6cbd`](https://testnet.monadvision.com/tx/0x5d39ce688896ed0f258d1c3a173ddb505983906d3258db13c02908ee30336cbd) |
| FakeBot #2205 | A1 spam 1 | [`0xc38cf6ba…0b8e`](https://testnet.monadvision.com/tx/0xc38cf6baac88a077cfd4e62f746ba0ba6a97b7c9059145cfc13d5209e0d00b8e) |
| FakeBot #2205 | A2 impersonation 2 | [`0x4d5688da…0798`](https://testnet.monadvision.com/tx/0x4d5688da8925fdce79bc62cc48cf367a40784b9a6ce62a5b9ab574ab00ad0798) |
| SybilBot #2206 | P1 reliable 5 | [`0x2006d74e…34d3`](https://testnet.monadvision.com/tx/0x2006d74e3ce2ecb8ae01b2763b773e0f0caca672ff072c160769f4a5a10234d3) |
| SybilBot #2206 | P2 helpful 5 | [`0x440422b1…d8f9`](https://testnet.monadvision.com/tx/0x440422b1e719e9ebbf16b0a720d1c0def7f5a1ccd5986a1b79443c551ffdd8f9) |
| SybilBot #2206 | P3 on-time 5 | [`0x03032eab…a563`](https://testnet.monadvision.com/tx/0x03032eabea565804e068726b6835ec79af9329108c7aee33ca9a5d8d56f7a563) |
| SybilBot #2206 | A1 sybil-ring 1 | [`0x4e3126da…eb86`](https://testnet.monadvision.com/tx/0x4e3126da432a0e2450b07407b42797e96b4d296afa8760e6f7c9c03bb455eb86) |

```bash
REP=0x8004B663056A597Dffe9eCcC1965A193B7388713
RPC=https://testnet-rpc.monad.xyz
cast call $REP "getClients(uint256)(address[])" 2206 --rpc-url $RPC
```

Adapter notes: [`ADAPTER.md`](./ADAPTER.md). Script: `script/Feedback8004.s.sol`.

**Deferred:** Validation Registry (spec unstable). Attester bonds. Full log→score mirror indexer.


### Superseded

| Version | Contract | Note |
|---------|----------|------|
| v2 sybil-lite avg | [`0xDCcBbFFC…f859`](https://testnet.monadvision.com/address/0xDCcBbFFC7D0912674760579fAba210a2a729f859) | No weighted / no SybilRing |
| v1 sum-only | [`0x7Be01cFC…ad13`](https://testnet.monadvision.com/address/0x7Be01cFC771fA2FD292113dA83881E0deC56ad13) | Pre–average API |

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
# plus FAKE_OWNER_KEY, ATTESTER1..3_KEY, SYBIL_OWNER_KEY, PUPPET1..3_KEY

forge script script/Deploy.s.sol:Deploy --rpc-url "$RPC_URL" --broadcast -vvvv
export REGISTRY=0x...
forge script script/Seed.s.sol:Seed --rpc-url "$RPC_URL" --broadcast --slow -vvvv
```

Fund ephemeral wallets with tiny MON from the deployer before seeding. Keys only in local `600` env files.
