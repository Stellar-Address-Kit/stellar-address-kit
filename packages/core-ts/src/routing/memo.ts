import { Warning } from "./types";

export type NormalizeResult = {
  normalized: string | null;
  warnings: Warning[];
};

/**
 * Maximum value for a 64-bit unsigned integer (uint64).
 */
const UINT64_MAX = BigInt("18446744073709551615");

/**
 * Normalizes a numeric string into a canonical uint64 representation.
 * Strips leading zeros and validates that the value is within uint64 boundaries.
 * 
 * @param s - The numeric string to normalize.
 * @returns Result containing the normalized string (or null if invalid) and any warnings.
 */
export function normalizeMemoTextId(s: string): NormalizeResult {
  const warnings: Warning[] = [];

  if (s.length === 0 || !/^\d+$/.test(s)) {
    return { normalized: null, warnings };
  }

  let normalized = s.replace(/^0+/, "");
  if (normalized === "") {
    normalized = "0";
  }

  if (normalized !== s) {
    warnings.push({
      code: "NON_CANONICAL_ROUTING_ID",
      severity: "warn",
      message:
        "Memo routing ID had leading zeros. Normalized to canonical decimal.",
      normalization: { original: s, normalized },
    });
  }

  try {
    const val = BigInt(normalized);
    if (val > UINT64_MAX) {
      return { normalized: null, warnings };
    }
  } catch {
    return { normalized: null, warnings };
  }

  return { normalized, warnings };
}
