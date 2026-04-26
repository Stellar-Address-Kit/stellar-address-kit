import { encodeMuxed, decodeMuxed } from "stellar-address-kit";

/**
 * BigInt Precision Auditor
 * This tool demonstrates how JavaScript's Number type silently corrupts
 * Stellar muxed account IDs (uint64) and how stellar-address-kit solves this.
 */

const TEST_G_ADDRESS = "GA7QYNF7SOWQ3GLR2BGMZEHXAVIRZA4KVWLTJJFC7MGXUA74P7UJVWH4";

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
  // Encode muxed address
  const mAddress = encodeMuxed(TEST_G_ADDRESS, id);
  
  // Path A: BigInt path (Library Default)
  const decodedBigInt = decodeMuxed(mAddress).id;
  
  // Path B: Number path (Lossy coercion)
  const decodedNumber = Number(decodedBigInt);
  
  // Audit comparison
  const isMatch = BigInt(decodedNumber) === decodedBigInt;
  if (!isMatch) {
    corruptedCount++;
  }
  
  const status = isMatch ? "✓ Match" : "✗ CORRUPTED";
  
  // Output format: ID Number: BigInt: ✓ Match or ✗ CORRUPTED.
  console.log(`ID ${id} Number: ${decodedNumber} BigInt: ${decodedBigInt} ${status}`);
}

console.log(`\n${corruptedCount} of ${ids.length} IDs corrupted by Number()`);
