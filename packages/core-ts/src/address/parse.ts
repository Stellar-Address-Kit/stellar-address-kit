import { decodeMuxed } from "../muxed/decode";
import { detect } from "./detect";
import { ParseResult } from "./types";
import { AddressParseError } from "../address/errors";

/**
 * Parses a Stellar address string and returns a structured result.
 *
 * Parsing boundaries:
 * - **G addresses** (pubkey): 56 characters, base32-encoded ed25519 public key with CRC16 checksum
 * - **C addresses** (contract): 64 characters, base64-encoded contract ID
 * - **M addresses** (muxed): Starts with "M", contains embedded ed25519 pubkey + muxed account ID
 *
 * The input is automatically normalized to uppercase before parsing.
 * Invalid addresses result in thrown {@link AddressParseError} rather than
 * returning an error result, making this the primary validation entrypoint.
 *
 * @param address - The Stellar address string to parse (G... , C... , or M... prefix)
 * @returns A {@link ParseResult} containing the parsed address with kind and warnings
 * @throws {AddressParseError} When the address fails validation:
 *   - `"UNKNOWN_PREFIX"` - Address does not start with G, M, or C
 *   - `"INVALID_CHECKSUM"` - Base32 decoding or CRC16 checksum validation failed (pubkey/muxed)
 *   - `"INVALID_LENGTH"` - Address length does not match expected format
 *   - `"INVALID_BASE32"` - Address contains non-base32 characters (pubkey/muxed)
 *
 * @example
 * ```ts
 * // Parse a public key
 * const result = parse("GA7QYNF7SOWQ3GLR2BGMZEHXAVIRZA4KVWLTJJFC7MGXUA74P7UJVSGZ");
 * // => { kind: "G", address: "GA7QYNF7...", warnings: [] }
 *
 * // Parse a contract address
 * const contract = parse("CDLZFC3SYJYDZT7K67VZ75HPJVIEUVNIXF47ZG2FB2RMQQVU2HHGCYSC");
 * // => { kind: "C", address: "CDLZFC3...", warnings: [] }
 *
 * // Parse a muxed address
 * const muxed = parse("MBMM5N2TPABDA6OZHG5WSF6CXDABPK62L3DCMYC7QEYIIBPL6Q5DGDQ3");
 * // => { kind: "M", address: "...", baseG: "GA7QYNF...", muxedId: 12345n, warnings: [] }
 *
 * // Handle invalid addresses
 * try {
 *   parse("INVALID");
 * } catch (error) {
 *   if (error instanceof AddressParseError) {
 *     console.log(error.code);    // "UNKNOWN_PREFIX"
 *     console.log(error.input);   // "INVALID"
 *     console.log(error.message); // "Invalid address"
 *   }
 * }
 * ```
 */
export function parse(address: string): ParseResult {
  const up = address.toUpperCase();
  const kind = detect(up);

  if (kind === "invalid") {
    const first = up[0];
    if (first === "G" || first === "M" || first === "C") {
      throw new AddressParseError(
        "INVALID_CHECKSUM",
        address,
        "Invalid address checksum"
      );
    }

    throw new AddressParseError("UNKNOWN_PREFIX", address, "Invalid address");
  }

  switch (kind) {
    case "G":
      return { kind: "G", address: up, warnings: [] };
    case "C":
      return { kind: "C", address: up, warnings: [] };
    case "M": {
      try {
        const decoded = decodeMuxed(up);
        return {
          kind: "M",
          address: up,
          baseG: decoded.baseG,
          muxedId: decoded.id,
          warnings: [],
        };
      } catch (error) {
        if (error instanceof AddressParseError) {
          throw error;
        }

        throw new AddressParseError(
          "INVALID_CHECKSUM",
          address,
          "Invalid muxed address"
        );
      }
    }
  }
}

