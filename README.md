# HealthChain: Plutus Smart Contracts (Cardano)

This repository contains all on-chain logic for the HealthChain project, built on the Cardano blockchain.

This code represents the decentralized "trust layer" of our ecosystem. It is responsible for:
* Managing the decentralized identities (DIDs) of Residents, Clinics, and Authorities via Atala PRISM.
* Maintaining a registry of verified, trusted Clinic DIDs.
* Enforcing permission logic for reading and writing health data via Verifiable Credentials (VCs).
* Anchoring immutable, time-stamped hashes of encrypted health records to a Resident's DID.

➡️ **View the main organization page:** [Link to your GitHub Org]

---

### Technology Stack

* **Blockchain:** Cardano
* **Smart Contracts:** Plutus
* **Identity:** Atala PRISM
* **Tooling:** cardano-cli, cardano-node, (Aiken, PlutusTx, or similar)

### Core MVP Contracts

* **BL-1.2: Clinic Registry Script:** A Plutus script that maintains a whitelist of verified Clinic DIDs, ensuring only registered entities can write data.
* **BL-1.3: Permission/VC Script:** The core logic that manages the lifecycle of a Verifiable Credential. It must enforce rules for issuance, expiry, and revocation.
* **BL-1.4: On-Chain Anchor Service:** The transaction-building logic that anchors the off-chain data hash to the Cardano blockchain, referencing the correct DIDs and permission scripts.

### Getting Started

This project requires a specialized Cardano development environment.

1.  **Clone the repository:**
    ```bash
    git clone [repository-url]
    cd plutus-contracts
    ```

2.  **Setup Environment:**
    Please refer to the `DEVELOPMENT_GUIDE.md` for detailed instructions on setting up the Cardano development environment, `cardano-node`, and `cardano-cli` for use with the testnet.

3.  **Build & Test:**
    ```bash
    # (Commands will be specific to your chosen Plutus toolchain)
    # e.g., aiken build
    # e.g., cardano-cli transaction build ...
    ```
