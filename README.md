# HealthChain – Cardano Smart Contracts (Aiken)

HealthChain is a decentralized health-data infrastructure built on the Cardano blockchain.
This repository contains all on-chain logic, along with instructions for building, deploying, and integrating the smart contracts with backend services and frontend applications.

# 📌 Overview

These Aiken smart contracts implement the core trust and permissions layer of the HealthChain ecosystem:

Decentralized identities (DIDs) for Residents, Clinics, and Authorities via Atala PRISM

Permissioned access using Verifiable Credentials (VCs)

On-chain Clinic Registry to validate which clinics may write data

Anchor Script for timestamped, immutable hashes of encrypted medical records

This ensures that all health transactions are secure, auditable, and decentralized.

# 📦 Technology Stack
* Component	Technology
* Smart Contracts	Aiken
* Blockchain	Cardano (Preprod Testnet)
* Identity Layer	Atala PRISM
* Deployment	Lucid + Blockfrost
* Backend API (optional)	Node.js
* Frontend	Next.js, Lucid
* 🧱 Smart Contract Modules (MVP)

* Clinic Registry (BL-1.2)

Maintains a whitelist of verified Clinic DIDs, ensuring only trusted clinics can anchor records.

* VC Permission Script (BL-1.3)

Enforces issuance, expiration, and revocation rules for Verifiable Credentials.

* Anchor Script (BL-1.4)

Anchors hashes of encrypted medical records to the blockchain, ensuring integrity and tamper-proof history.

* Output

Aiken produces a single blueprint:

plutus.json


This contains all compiled validators for deployment.

# 🚀 Getting Started
``Clone the Repository
git clone <repo-url>
cd aiken-contracts

# 🛠 Development Environment

# See DEVELOPMENT_GUIDE.md for installation instructions for:

cardano-node
cardano-cli
Aiken toolchain
Testnet configuration

* 🔧 Build & Test Contracts
``aiken build
  aiken test
``
* Verify the blueprint:

``ls -la plutus.json
``

# 🌐 Testnet Deployment (Preprod)

*These instructions align with the official HealthChain deployment workflow.

# 📋 Prerequisites
``Tools
Tool	Version
Aiken	v1.1.x
Node.js	v18+
npm	v9+
Accounts
``
* Blockfrost Preprod Project

Preprod Wallet (Eternl / Lace)
Test ADA from Cardano faucet

# ⚙️ API Environment Setup

* Create:

``/api/.env
``

* Add:

``BLOCKFROST_API_KEY=preprodXXXXXXXXXXXXXXXXXXXXXXXX
NETWORK=preprod
PORT=3000
``
* 🏗 Step 1: Build Smart Contracts
``aiken build
``
* 🛰 Step 2: Deploy Validators

* Run the deployment script:

``./deploy.sh
``

* This extracts validators and prints:

Contract script hashes

Policy IDs

Validator addresses

* 🧩 Step 3: Initialize Registry UTxOs

Use Lucid to fund the Clinic Registry contract with its initial datum.

const clinicValidator = blueprint.validators.find(
  (v) => v.title === "clinic.clinic_validator.spend"
);


* This creates:

First registry datum

First validator UTxO

Initial authority assignment

* Output:

Registry initialized: <txHash>
Validator Address: <addr_test...>

# 🧪 Backend API (Optional)
* Start API Server
``cd api
  npm start
``
Example Endpoints
* Health Check
``GET /health
``
* Register Clinic
``POST /register-clinic
``

``Payload:
{
  "validatorAddress": "addr_test1...",
  "clinicDid": "did:healthchain:clinic:123",
  "authorityKey": "ed25519_sk..."
}
``
# 🖥 Frontend Integration (Next.js)
``Install Lucid
npm install lucid-cardano
``
* Connect Wallet
``const api = await window.cardano.eternl.enable();
lucid.selectWallet(api);
``
* Call API Example
``const r = await fetch("/register-clinic", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    validatorAddress: "...",
    clinicDid: "did:healthchain:clinic:123",
    authorityKey: await lucid.wallet.address()
  })
});
``
* 🔗 Validator Hashes (After Deployment)

These hashes come from your generated plutus.json:

``Validator	Hash
anchor_validator	90937bde389d697214611267d1e587445be3532121e3e891794856af
clinic_validator	f57e5e32c4317e95d74cde7870258a96fcc92a337f8b66d6852ac19c
did_validator	373c4985665c775801ad804f1f4dd55b6c9ef0cd458eb043c39ca9b4
vc_validator	84e7c791288aef34438af1330ad366af88b95dc551dd5c80d8ce0ef5
``
* 🛠 Troubleshooting
``Issue	Solution
Missing Blockfrost Key	Add .env file
Insufficient Funds	Use faucet
Script budget exceeded	Reduce datum size
Datum mismatch	Ensure correct encoding from frontend
Address mismatch	Re-run deployment to regenerate addresses
``
## 📚 Useful Commands
# Build contracts
aiken build

# Run tests
aiken check

# Start API
cd api && npm start

# Tail logs
tail -f api/logs/app.log

🔗 Organization

Visit the HealthChain organization:
