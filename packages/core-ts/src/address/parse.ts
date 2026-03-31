import { decodeMuxed } from "../muxed/decode";
import { detect } from "./detect";
import { ParseResult } from "./types";
import { AddressParseError } from "../address/errors";

/**
 * Parses a Stellar address string and returns a structured result.
 * Supports G (Public Key), C (Contract), and M (Muxed) addresses.
 * 
 * @param address - The Stellar address string to parse.
 * @returns A {@link ParseResult} containing the parsed address components.
 * @throws {AddressParseError} If the address prefix is unknown or checksum/length validation fails.
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

