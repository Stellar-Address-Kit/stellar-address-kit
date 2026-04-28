import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const port = 3000;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

app.post('/api/validate', (req, res) => {
  const { address } = req.body;
  if (!address) {
    return res.json({ valid: false, error: 'Address is required' });
  }

  const firstChar = address.charAt(0).toUpperCase();
  
  if (firstChar === 'M') {
    return res.json({
      valid: true,
      type: 'M',
      memoDisabled: true,
      reason: 'Multiplexed addresses (M...) already encode a memo ID. Manual memo is disabled to prevent conflicts.'
    });
  }

  if (firstChar === 'C') {
    return res.json({
      valid: false,
      type: 'C',
      error: 'Withdrawals to contract addresses (C...) are not supported.'
    });
  }

  if (firstChar === 'G') {
    return res.json({
      valid: true,
      type: 'G',
      memoDisabled: false
    });
  }

  return res.json({
    valid: false,
    error: 'Invalid Stellar address format.'
  });
});

app.post('/api/analyze', (req, res) => {
  const { address, memoType, memoValue } = req.body;
  res.json({
    status: 'success',
    analysis: {
      address,
      memoProvided: memoType !== 'none',
      timestamp: new Date().toISOString(),
      recommendation: 'Safe to proceed with withdrawal'
    }
  });
});

app.listen(port, () => {
  console.log(`Exchange Withdrawal Validator listening at http://localhost:${port}`);
});
