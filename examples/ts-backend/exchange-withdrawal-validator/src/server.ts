import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

import { detect, validate, parse } from 'stellar-address-kit';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const port = 3000;

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

/**
 * POST /api/validate
 * Accepts { address: string, memoType?: string, memoValue?: string }
 * Returns structured feedback based on address type (G, M, C).
 */
app.post('/api/validate', (req, res) => {
  const { address } = req.body;

  if (!address || typeof address !== 'string') {
    return res.status(400).json({ 
      valid: false, 
      error: "Address is required" 
    });
  }

  try {
    // 1. Basic validation using the kit
    const isValid = validate(address);
    if (!isValid) {
      return res.json({ 
        valid: false, 
        error: "Invalid Stellar address" 
      });
    }

    // 2. Detect and Parse for detailed feedback
    const kind = detect(address);
    const parsed = parse(address);

    switch (kind) {
      case "M":
        return res.json({
          valid: true,
          addressKind: "muxed",
          muxedId: parsed.kind === "M" ? parsed.muxedId.toString() : undefined,
          memoDisabled: true,
          reason: "Muxed addresses carry their own routing ID"
        });

      case "C":
        return res.json({
          valid: false,
          addressKind: "contract",
          error: "Contract addresses cannot receive direct exchange withdrawals"
        });

      case "G":
        return res.json({
          valid: true,
          addressKind: "classic",
          memoDisabled: false
        });

      default:
        return res.json({ 
          valid: false, 
          error: "Invalid Stellar address" 
        });
    }
  } catch (error) {
    return res.json({ 
      valid: false, 
      error: "Invalid Stellar address" 
    });
  }
});

app.post('/api/analyze', (req, res) => {
  // Placeholder for advanced address analysis
  res.json({ message: "Endpoint for advanced routing analysis placeholder" });
});

app.listen(port, () => {
  console.log(`Exchange Withdrawal Validator listening at http://localhost:${port}`);
});
