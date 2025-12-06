# HealthChain MVP - Testnet Deployment & Frontend Integration Guide

## Overview

This document provides step-by-step instructions for deploying the HealthChain smart contracts to Cardano Preprod testnet and integrating them with a frontend application.

---

## Prerequisites

### Tools Required
| Tool | Version | Purpose |
|------|---------|---------|
| Aiken | v1.1.x | Smart contract compiler |
| Node.js | v18+ | Backend API runtime |
| npm | v9+ | Package manager |

### Accounts Required
1. **Blockfrost Account** - [Sign up](https://blockfrost.io)
   - Create a project for **Preprod** network
   - Copy your API key (e.g., `preprodXXXXXXXXXXXXXXXXXXXXXXXX`)

2. **Preprod Wallet**
   - Use [Eternl](https://eternl.io) or [Lace](https://www.lace.io) in testnet mode
   - Get test ADA from [Cardano Faucet](https://docs.cardano.org/cardano-testnet/tools/faucet)

---

## Step 1: Build Smart Contracts

```bash
cd /Users/mac/team\ healthchain/Blockchain-Cardano

# Build contracts
aiken build

# Verify output
ls -la plutus.json
```

**Expected output:** `plutus.json` (blueprint with compiled validators)

---

## Step 2: Configure Environment

Create `/api/.env`:

```env
# Blockfrost API Key (Preprod)
BLOCKFROST_API_KEY=preprodXXXXXXXXXXXXXXXXXXXXXXXX

# Network
NETWORK=preprod

# Server Port
PORT=3000
```

---

## Step 3: Deploy to Testnet

### 3.1 Run Deployment Script
```bash
./deploy.sh
```

### 3.2 Start API Server
```bash
cd api
npm start
```

### 3.3 Initialize Registry UTxOs

Use Lucid to create the initial registry UTxOs. Example script:

```typescript
import { Blockfrost, Lucid, Data } from "lucid-cardano";
import blueprint from "./plutus.json";

const lucid = await Lucid.new(
  new Blockfrost(
    "https://cardano-preprod.blockfrost.io/api/v0",
    process.env.BLOCKFROST_API_KEY
  ),
  "Preprod"
);

// Load wallet (use your seed phrase)
lucid.selectWalletFromSeed("your 24 word seed phrase here");

// Get validator from blueprint
const clinicValidator = blueprint.validators.find(
  v => v.title === "clinic.clinic_validator.spend"
);

const validatorAddress = lucid.utils.validatorToAddress({
  type: "PlutusV3",
  script: clinicValidator.compiledCode
});

// Create initial datum
const initialDatum = Data.to({
  clinics: new Map(),
  authority: lucid.utils.paymentCredentialOf(await lucid.wallet.address()).hash
});

// Fund the validator
const tx = await lucid.newTx()
  .payToContract(validatorAddress, { inline: initialDatum }, { lovelace: 5000000n })
  .complete();

const signedTx = await tx.sign().complete();
const txHash = await signedTx.submit();

console.log("Registry initialized:", txHash);
console.log("Validator Address:", validatorAddress);
```

---

## Step 4: API Endpoints

### Health Check
```
GET /health
Response: { "status": "ok" }
```

### Register Clinic
```
POST /register-clinic
Body: {
  "validatorAddress": "addr_test1...",
  "clinicDid": "did:healthchain:clinic:123",
  "authorityKey": "ed25519_sk..."
}
Response: { "txHash": "abc123..." }
```

---

## Step 5: Frontend Integration

### 5.1 Install Dependencies
```bash
npm install lucid-cardano
```

### 5.2 Initialize Lucid
```typescript
import { Blockfrost, Lucid } from "lucid-cardano";

const lucid = await Lucid.new(
  new Blockfrost(
    "https://cardano-preprod.blockfrost.io/api/v0",
    "YOUR_API_KEY"
  ),
  "Preprod"
);

// Connect wallet (browser extension)
const api = await window.cardano.eternl.enable();
lucid.selectWallet(api);
```

### 5.3 Call API Endpoints
```typescript
const response = await fetch("http://localhost:3000/register-clinic", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    validatorAddress: "addr_test1...",
    clinicDid: "did:healthchain:clinic:123",
    authorityKey: await lucid.wallet.address()
  })
});

const { txHash } = await response.json();
console.log("Transaction:", `https://preprod.cardanoscan.io/transaction/${txHash}`);
```

---

## Validator Addresses

After deployment, extract addresses from `plutus.json`:

| Validator | Hash |
|-----------|------|
| `anchor_validator` | `90937bde389d697214611267d1e587445be3532121e3e891794856af` |
| `clinic_validator` | `f57e5e32c4317e95d74cde7870258a96fcc92a337f8b66d6852ac19c` |
| `did_validator` | `373c4985665c775801ad804f1f4dd55b6c9ef0cd458eb043c39ca9b4` |
| `vc_validator` | `84e7c791288aef34438af1330ad366af88b95dc551dd5c80d8ce0ef5` |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `BLOCKFROST_API_KEY not set` | Add `.env` file with your key |
| `Insufficient funds` | Get test ADA from faucet |
| `Script budget exceeded` | Simplify datum or split transaction |
| `Datum mismatch` | Ensure frontend sends correct datum format |

---

## Quick Reference

```bash
# Build contracts
aiken build

# Run tests
aiken check

# Start API
cd api && npm start

# View logs
tail -f api/logs/app.log
```
