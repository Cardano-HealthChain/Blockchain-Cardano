import express from 'express';
import { Lucid, Blockfrost } from 'lucid-cardano';
import dotenv from 'dotenv';
import { router } from './routes';

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

// Initialize Lucid
// In a real app, you'd handle this more robustly (e.g., waiting for initialization)
let lucid: Lucid;

const initLucid = async () => {
  try {
    lucid = await Lucid.new(
      new Blockfrost(
        process.env.BLOCKFROST_URL || "https://cardano-preprod.blockfrost.io/api/v0",
        process.env.BLOCKFROST_PROJECT_ID || "your_project_id"
      ),
      "Preprod",
    );
    console.log("Lucid initialized successfully");

    // Pass lucid to routes (middleware or dependency injection)
    app.locals.lucid = lucid;

  } catch (e) {
    console.error("Failed to initialize Lucid:", e);
  }
};

initLucid();

app.use('/', router);

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
