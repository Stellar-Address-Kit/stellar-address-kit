import { StrKey } from "@stellar/stellar-sdk";

/**
 * Maximum value for a 64-bit unsigned integer.
 */
const MAX_UINT64 = 18446744073709551615n;

/**
 * Encodes a base G address and numeric ID into a muxed Stellar address (SEP-23).
 * Uses BigInt for the ID to prevent precision loss and ensures the ID is within uint64 boundaries.
 * 
 * @param baseG - Ed25519 public key string starting with 'G'.
 * @param id - The 64-bit routing ID as a BigInt.
 * @returns The encoded muxed address string starting with 'M'.
 * @throws {TypeError} If ID is not a BigInt.
 * @throws {RangeError} If ID is outside the uint64 range [0, 2^64-1].
 */
export function encodeMuxed(baseG: string, id: bigint): string {
  if (typeof id !== "bigint") {
    throw new TypeError(`ID must be a bigint, received ${typeof id}`);
  }

  if (id < 0n || id > MAX_UINT64) {
    throw new RangeError(`ID is outside the uint64 range: 0 to ${MAX_UINT64}`);
  }

  if (!StrKey.isValidEd25519PublicKey(baseG)) {
    throw new Error(`Invalid base G address (Ed25519 public key expected)`);
  }

  // Build the 40-byte med25519 payload: [pubkey (32 bytes)] [uint64 id (8 bytes, BE)].
  const pubkeyBytes = Buffer.from(StrKey.decodeEd25519PublicKey(baseG));
  const idBytes = Buffer.alloc(8);
  idBytes.writeBigUInt64BE(id);

  return StrKey.encodeMed25519PublicKey(Buffer.concat([pubkeyBytes, idBytes]));
}
