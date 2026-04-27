import { encodeMuxed, decodeMuxed } from "stellar-address-kit";

/**
 * BigInt Precision Auditor
 * This tool demonstrates how JavaScript's Number type silently corrupts
 * Stellar muxed account IDs (uint64) and how stellar-address-kit solves this.
 */

const TEST_G_ADDRESS = "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI";

// Test these IDs: [0, 1, 2^53-1, 2^53, 2^53+1, 2^64-1]
const ids = [
  0n,
  1n,
  (2n ** 53n) - 1n, // 2^53-1: MAX_SAFE_INTEGER
  2n ** 53n,        // 2^53: Still representable
  (2n ** 53n) + 1n, // 2^53+1: First unrepresentable uint64
  18446744073709551615n // 2^64-1: MAX_UINT64
];

console.log("BigInt Precision Audit: Batch ID Range Corruption Sweep\n");

let corruptedCount = 0;

for (const id of ids) {
  try {
    // Encode muxed address
    const mAddress = encodeMuxed(TEST_G_ADDRESS, id);
    
    // Path A: BigInt path (Library Default)
    const safeId = decodeMuxed(mAddress).id;
    
    // Path B: Number path (Lossy coercion)
    const unsafeId = Number(safeId);
    
    // Audit comparison
    const isMatch = BigInt(unsafeId) === safeId;
    if (!isMatch) {
      corruptedCount++;
    }
    
    const status = isMatch ? "✓ Match" : "✗ CORRUPTED";
    
    // Output format: ID Number: BigInt: ✓ Match or ✗ CORRUPTED.
    console.log(`ID ${id} Number: ${unsafeId} BigInt: ${safeId} ${status}`);
  } catch (error) {
    console.log(`ID ${id} ✗ FAILED: ${error instanceof Error ? error.message : String(error)}`);
  }
}

console.log(`\n${corruptedCount} of ${ids.length} IDs corrupted by Number()`);
