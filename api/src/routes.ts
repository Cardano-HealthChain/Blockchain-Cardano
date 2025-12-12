import express, { Request, Response } from 'express';
import { Lucid, Blockfrost, Data, Constr } from 'lucid-cardano';

export const router = express.Router();

// Mock Data schemas (should match Aiken types)
const ClinicRegistrySchema = Data.Object({
  clinics: Data.Map(Data.Bytes(), Data.Object({
    approved_by: Data.Bytes(),
    approved_at: Data.Integer(),
    revoked_at: Data.Nullable(Data.Integer())
  })),
  authority: Data.Bytes()
});

router.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

router.post('/register-clinic', async (req: Request, res: Response) => {
  try {
    const lucid: Lucid = req.app.locals.lucid;
    if (!lucid) return res.status(500).json({ error: "Lucid not initialized" });

    const { validatorAddress, clinicDid, authorityKey } = req.body; // In real app, derived from session/config

    // 1. Read current datum from UTxO
    const utxos = await lucid.utxosAt(validatorAddress);
    if (utxos.length === 0) return res.status(404).json({ error: "Registry UTxO not found" });

    const registryUtxo = utxos[0];
    const currentDatum = Data.from(registryUtxo.datum!);

    // 2. Construct new datum (mock logic)
    // In reality: Update map in off-chain code similar to on-chain logic
    // This requires parsing the 'clinics' map, adding the new entry, and re-serializing.
    // For MVP mock: we just assume the client sends the *new* full datum or we just stub it.

    // Stub: Let's assume we just want to prove we can build the tx
    const newDatum = currentDatum;

    const tx = await lucid.newTx()
      .collectFrom([registryUtxo]) // We don't have the redeemer stubbed yet
      .payToContract(validatorAddress, { inline: Data.to(newDatum) }, {})
      .addSigner(authorityKey)
      .complete();

    const signedTx = await tx.sign().complete();
    const txHash = await signedTx.submit();

    res.json({ txHash });
  } catch (error: any) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});
