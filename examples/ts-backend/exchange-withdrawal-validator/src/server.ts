import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

import { extractRouting, RoutingInput } from 'stellar-address-kit';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const port = 3000;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

app.post('/api/validate', (req, res) => {
  // Placeholder for address validation
  res.json({});
});

app.post('/api/analyze', (req, res) => {
  const { address, memoType, memoValue } = req.body;

  try {
    const input: RoutingInput = {
      destination: address,
      memoType: memoType === 'none' ? 'none' : memoType,
      memoValue: memoValue || null,
      sourceAccount: null,
    };

    const result = extractRouting(input);
    
    // Convert BigInt to string for JSON serialization
    const serializedResult = {
      ...result,
      routingId: result.routingId?.toString() || null,
    };

    res.json(serializedResult);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Exchange Withdrawal Validator listening at http://localhost:${port}`);
});
