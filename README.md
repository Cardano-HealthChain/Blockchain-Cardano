# HealthChain: Aiken Smart Contracts (Cardano)

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
* **Smart Contracts:** Aiken
* **Identity:** Atala PRISM
* **Tooling:** cardano-cli, cardano-node, Aiken

### Core MVP Contracts

* **BL-1.2: Clinic Registry Script:** An Aiken script that maintains a whitelist of verified Clinic DIDs, ensuring only registered entities can write data.
* **BL-1.3: Permission/VC Script:** The core logic that manages the lifecycle of a Verifiable Credential. It must enforce rules for issuance, expiry, and revocation.
* **BL-1.4: On-Chain Anchor Service:** The transaction-building logic that anchors the off-chain data hash to the Cardano blockchain, referencing the correct DIDs and permission scripts.

### Getting Started

This project requires a specialized Cardano development environment.

1.  **Clone the repository:**
    ```bash
    git clone [repository-url]
    cd aiken-contracts
    ```

2.  **Setup Environment:**
    Please refer to the `DEVELOPMENT_GUIDE.md` for detailed instructions on setting up the Cardano development environment, `cardano-node`, `cardano-cli`, and Aiken for use with the testnet.

3.  **Build & Test:**
    ```bash
    # Build the Aiken scripts
    aiken build

    # Run tests
    aiken test
    ```
