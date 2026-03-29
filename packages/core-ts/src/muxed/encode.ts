import { MuxedAccount, StrKey } from "@stellar/stellar-sdk";

// Use BigInt literal for the 64-bit unsigned integer maximum
const MAX_UINT64 = 18446744073709551615n;

/**
 * Encodes a muxed Stellar address using a base G address and numeric ID.
 * Adheres to BigInt audit requirements to prevent precision loss.
 */
export function encodeMuxed(baseG: string, id: bigint): string {
  // 1. Strict Type Enforcement
  // Ensure we are working with a BigInt immediately
  if (typeof id !== "bigint") {
    throw new TypeError(`ID must be a bigint, received ${typeof id}`);
  }

  // 2. Uint64 Boundary Check
  // Using BigInt literals (0n) for comparison
  if (id < 0n || id > MAX_UINT64) {
    throw new RangeError(`ID is outside the uint64 range: 0 to ${MAX_UINT64}`);
  }

  // 3. Address Validation
  if (!StrKey.isValidEd25519PublicKey(baseG)) {
    throw new Error(`Invalid base G address (Ed25519 public key expected)`);
  }

  // 4. Safe Encoding
  // We pass the string representation to MuxedAccount to avoid 
  // any internal SDK attempts to cast a large number to a float.
  const muxed = new MuxedAccount(baseG, id.toString());

  return muxed.accountId();
}