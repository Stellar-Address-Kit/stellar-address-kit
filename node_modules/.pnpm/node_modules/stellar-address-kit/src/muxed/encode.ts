import { StrKey } from "@stellar/stellar-sdk";

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
  // Build the 40-byte med25519 payload directly:
  // [ed25519 pubkey (32 bytes)] [uint64 id (8 bytes, big-endian)].
  // This avoids runtime constructor-contract drift in MuxedAccount across SDK versions.
  const pubkeyBytes = Buffer.from(StrKey.decodeEd25519PublicKey(baseG));
  const idBytes = Buffer.alloc(8);
  idBytes.writeBigUInt64BE(id);

  return StrKey.encodeMed25519PublicKey(Buffer.concat([pubkeyBytes, idBytes]));
}
