import { RoutingInput, RoutingResult, Warning } from "./types";
import { parse } from "../address/parse";
import { AddressParseError } from "../address/errors";
import { normalizeMemoTextId } from "./memo";

export class ExtractRoutingError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ExtractRoutingError";
    Object.setPrototypeOf(this, ExtractRoutingError.prototype);
  }
}

/**
 * Validates that the destination string passes the minimum structural
 * requirements for a Stellar address before routing logic is applied.
 * Only G-addresses and M-addresses are valid routing targets.
 * Throws ExtractRoutingError for anything that fails this check.
 */
function assertRoutableAddress(destination: string): void {
  if (!destination || typeof destination !== "string") {
    throw new ExtractRoutingError(
      "Invalid input: destination must be a non-empty string."
    );
  }

  const prefix = destination.trim()[0]?.toUpperCase();
  if (prefix !== "G" && prefix !== "M") {
    throw new ExtractRoutingError(
      `Invalid destination: expected a G or M address, got "${destination}".`
    );
  }
}

/**
 * Resolves deposit routing from a destination address plus memo context.
 *
 * Decision tree:
 * 1. Destination pre-check (`assertRoutableAddress`)
 *    - Requires a non-empty string starting with `G` or `M`.
 *    - Throws `ExtractRoutingError` for structurally invalid routing targets.
 * 2. Destination parse (`parse`)
 *    - If parsing throws `AddressParseError`, returns `routingSource: "none"`
 *      with `destinationError` populated.
 * 3. Parsed kind branches
 *    - `M`: routing ID is extracted from muxed ID (`routingSource: "muxed"`).
 *      - If memo also looks routable (`memoType: "id"` or numeric `memoType: "text"`),
 *        emits `MEMO_PRESENT_WITH_MUXED` because muxed ID takes precedence.
 *      - If any other memo is present, emits `MEMO_IGNORED_FOR_MUXED`.
 *    - `G`: routing can come from memo (`routingSource: "memo"`) or be absent.
 *      - `memoType: "id"`: validates/normalizes uint64 decimal; invalid values emit
 *        `MEMO_ID_INVALID_FORMAT`.
 *      - `memoType: "text"`: routable only when numeric uint64; otherwise emits
 *        `MEMO_TEXT_UNROUTABLE`.
 *      - `memoType: "hash" | "return"` or unknown non-`none` memo type: emits
 *        `MEMO_TEXT_UNROUTABLE` and keeps `routingSource: "none"`.
 *    - `C`: treated as non-routable in this flow; returns `routingSource: "none"`
 *      with `CONTRACT_SENDER_DETECTED` warning.
 *    - `invalid`: returns `routingSource: "none"` with empty warnings.
 *
 * Output guarantees:
 * - `destinationBaseAccount` is:
 *   - Base G-address for `M` inputs,
 *   - Canonical G-address for `G` inputs,
 *   - `null` when non-routable.
 * - `routingId` is a canonical decimal string when present.
 * - `warnings` accumulates parse normalization warnings plus routing-policy warnings.
 *
 * @param input Routing context with destination, memo type/value, and optional source account.
 * @returns A `RoutingResult` describing destination base account, selected routing ID,
 * routing source (`muxed`, `memo`, or `none`), and any warnings/errors.
 */
export function extractRouting(input: RoutingInput): RoutingResult {
  assertRoutableAddress(input.destination);

  let parsed;
  try {
    parsed = parse(input.destination);
  } catch (error) {
    if (error instanceof AddressParseError) {
      return {
        destinationBaseAccount: null,
        routingId: null,
        routingSource: "none",
        warnings: [],
        destinationError: {
          code: error.code,
          message: error.message,
        },
      };
    }
    throw error;
  }

  if (parsed.kind === "invalid") {
    return {
      destinationBaseAccount: null,
      routingId: null,
      routingSource: "none",
      warnings: [],
    };
  }

  if (parsed.kind === "C") {
    const warnings: Warning[] = [...parsed.warnings];

    warnings.push({
      code: "CONTRACT_SENDER_DETECTED",
      severity: "warn",
      message:
        "Contract address detected. Contract addresses cannot be used as transaction senders.",
    });

    return {
      destinationBaseAccount: null,
      routingId: null,
      routingSource: "none",
      warnings,
    };
  }

  if (parsed.kind === "M") {
    const warnings: Warning[] = [...parsed.warnings];

    if (
      input.memoType === "id" ||
      (input.memoType === "text" && /^\d+$/.test(input.memoValue ?? ""))
    ) {
      warnings.push({
        code: "MEMO_PRESENT_WITH_MUXED",
        severity: "warn",
        message:
          "Routing ID found in both M-address and Memo. M-address ID takes precedence.",
      });
    } else if (input.memoType !== "none") {
      warnings.push({
        code: "MEMO_IGNORED_FOR_MUXED",
        severity: "info",
        message:
          "Memo present with M-address. Any potential routing ID in memo is ignored.",
      });
    }

    return {
      destinationBaseAccount: parsed.baseG,
      routingId: parsed.muxedId,
      routingSource: "muxed",
      warnings,
    };
  }

  let routingId: string | bigint | null = null;
  let routingSource: "none" | "memo" = "none";
  const warnings: Warning[] = [...parsed.warnings];

  if (input.memoType === "id") {
    const rawValue = input.memoValue ?? "";
    const norm = normalizeMemoTextId(rawValue);

    if (norm.normalized) {
      // Explicit bigint parsing for MEMO_ID to avoid Number precision issues.
      const parsedMemoId = BigInt(norm.normalized);
      routingId = parsedMemoId.toString();
      routingSource = "memo";
      warnings.push(...norm.warnings);
    } else {
      routingSource = "none";
      warnings.push(...norm.warnings);
      warnings.push({
        code: "MEMO_ID_INVALID_FORMAT",
        severity: "warn",
        message: "MEMO_ID was empty, non-numeric, or exceeded uint64 max.",
      });
    }
  } else if (input.memoType === "text" && input.memoValue) {
    const norm = normalizeMemoTextId(input.memoValue);
    if (norm.normalized) {
      routingId = norm.normalized;
      routingSource = "memo";
      warnings.push(...norm.warnings);
    } else {
      warnings.push({
        code: "MEMO_TEXT_UNROUTABLE",
        severity: "warn",
        message: "MEMO_TEXT was not a valid numeric uint64.",
      });
    }
  } else if (input.memoType === "hash" || input.memoType === "return") {
    warnings.push({
      code: "MEMO_TEXT_UNROUTABLE",
      severity: "warn",
      message: `Memo type ${input.memoType} is not supported for routing.`,
    });
  } else if (input.memoType !== "none") {
    warnings.push({
      code: "MEMO_TEXT_UNROUTABLE",
      severity: "warn",
      message: `Unrecognized memo type: ${input.memoType}`,
    });
  }

  return {
    destinationBaseAccount: parsed.address,
    routingId,
    routingSource,
    warnings,
  };
}