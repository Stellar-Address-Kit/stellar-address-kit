/**
 * End-to-end integration test: encodeMuxed → extractRouting pipeline
 *
 * Verifies that an M-address produced by encodeMuxed() faithfully round-trips
 * through extractRouting(), recovering both the original base G-address and
 * the original uint64 routing ID without loss or mutation.
 *
 * Test categories
 * ───────────────
 *  1. Basic round-trip: standard ID → M-address → routing result
 *  2. uint64 boundary: id = 0n (minimum) and id = MAX_UINT64 (maximum)
 *  3. SEP-0023 precision canary: id > 2^53 (beyond JS float64 safe range)
 *  4. Memo conflict: M-address + numeric memo-id → M-address ID wins, warning emitted
 *  5. Memo ignored: M-address + non-numeric memo → info warning, ID still from M-address
 */

import { describe, it, expect, beforeEach } from "vitest";
import { encodeMuxed } from "../muxed/encode";
import { extractRouting } from "../routing/extract";
import { routingIdAsBigInt } from "../routing/types";
import type { RoutingResult } from "../routing/types";

// ─── Test fixtures ────────────────────────────────────────────────────────────

// Well-known G-address sourced from the project's spec/vectors.json
// (muxed_encode vectors), so no external keypair generation is required.
const G_ADDRESS = "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI";

const STANDARD_ID = 42n;
const MAX_UINT64 = 18446744073709551615n;
// First integer that cannot be represented as a JS float64 without truncation.
const CANARY_ID = 9007199254740993n; // 2^53 + 1

// ─── Helpers ──────────────────────────────────────────────────────────────────

function makeInput(
  mAddress: string,
  memoType = "none",
  memoValue: string | null = null
) {
  return { destination: mAddress, memoType, memoValue, sourceAccount: null };
}

// ─── Test suite ───────────────────────────────────────────────────────────────

describe("encodeMuxed → extractRouting integration pipeline", () => {
  // ── 1. Basic round-trip ───────────────────────────────────────────────────
  describe("standard ID round-trip (id = 42n)", () => {
    let mAddress: string;
    let result: RoutingResult;

    beforeEach(() => {
      mAddress = encodeMuxed(G_ADDRESS, STANDARD_ID);
      result = extractRouting(makeInput(mAddress));
    });

    it("encodeMuxed produces a string starting with M", () => {
      expect(mAddress).toMatch(/^M/);
    });

    it("extractRouting recovers the exact base G-address", () => {
      expect(result.destinationBaseAccount).toBe(G_ADDRESS);
    });

    it("extractRouting recovers the exact routing ID as a bigint", () => {
      expect(routingIdAsBigInt(result.routingId)).toBe(STANDARD_ID);
    });

    it("routing source is 'muxed'", () => {
      expect(result.routingSource).toBe("muxed");
    });

    it("no warnings are emitted", () => {
      expect(result.warnings).toHaveLength(0);
    });

    it("no destination error is present", () => {
      expect(result.destinationError).toBeUndefined();
    });
  });

  // ── 2. Boundary values ────────────────────────────────────────────────────
  describe("uint64 boundary values", () => {
    it("round-trips id = 0n (minimum uint64)", () => {
      const mAddress = encodeMuxed(G_ADDRESS, 0n);
      const result = extractRouting(makeInput(mAddress));

      expect(result.destinationBaseAccount).toBe(G_ADDRESS);
      expect(routingIdAsBigInt(result.routingId)).toBe(0n);
      expect(result.routingSource).toBe("muxed");
    });

    it("round-trips id = MAX_UINT64 (maximum uint64)", () => {
      const mAddress = encodeMuxed(G_ADDRESS, MAX_UINT64);
      const result = extractRouting(makeInput(mAddress));

      expect(result.destinationBaseAccount).toBe(G_ADDRESS);
      expect(routingIdAsBigInt(result.routingId)).toBe(MAX_UINT64);
      expect(result.routingSource).toBe("muxed");
    });
  });

  // ── 3. SEP-0023 precision canary (id > 2^53) ──────────────────────────────
  describe("uint64 precision canary (id = 2^53 + 1 = 9007199254740993n)", () => {
    let result: RoutingResult;

    beforeEach(() => {
      const mAddress = encodeMuxed(G_ADDRESS, CANARY_ID);
      result = extractRouting(makeInput(mAddress));
    });

    it("preserves the full uint64 ID without float truncation", () => {
      expect(routingIdAsBigInt(result.routingId)).toBe(CANARY_ID);
    });

    it("recovered ID differs from the truncated float64 representation", () => {
      const truncated = BigInt(Number(CANARY_ID)); // 9007199254740992n
      expect(routingIdAsBigInt(result.routingId)).not.toBe(truncated);
    });

    it("base G-address is still recovered correctly", () => {
      expect(result.destinationBaseAccount).toBe(G_ADDRESS);
    });
  });

  // ── 4. Memo conflict: numeric memo-id alongside M-address ─────────────────
  describe("M-address with conflicting numeric memo-id", () => {
    let result: RoutingResult;

    beforeEach(() => {
      const mAddress = encodeMuxed(G_ADDRESS, STANDARD_ID);
      // Supply a different numeric ID via memo — should be ignored.
      result = extractRouting(makeInput(mAddress, "id", "99999"));
    });

    it("routing ID comes from the M-address, not the memo", () => {
      expect(routingIdAsBigInt(result.routingId)).toBe(STANDARD_ID);
    });

    it("base G-address is recovered correctly", () => {
      expect(result.destinationBaseAccount).toBe(G_ADDRESS);
    });

    it("routing source is still 'muxed'", () => {
      expect(result.routingSource).toBe("muxed");
    });

    it("emits a MEMO_PRESENT_WITH_MUXED warning", () => {
      const codes = result.warnings.map((w) => w.code);
      expect(codes).toContain("MEMO_PRESENT_WITH_MUXED");
    });

    it("the conflicting memo value does not leak into the result", () => {
      expect(JSON.stringify(result)).not.toContain("99999");
    });
  });

  // ── 5. Non-numeric memo alongside M-address ───────────────────────────────
  describe("M-address with non-numeric text memo (informational warning)", () => {
    let result: RoutingResult;

    beforeEach(() => {
      const mAddress = encodeMuxed(G_ADDRESS, STANDARD_ID);
      result = extractRouting(makeInput(mAddress, "text", "order-ref-xyz"));
    });

    it("routing ID still comes from the M-address", () => {
      expect(routingIdAsBigInt(result.routingId)).toBe(STANDARD_ID);
    });

    it("routing source is 'muxed'", () => {
      expect(result.routingSource).toBe("muxed");
    });

    it("emits a MEMO_IGNORED_FOR_MUXED warning", () => {
      const codes = result.warnings.map((w) => w.code);
      expect(codes).toContain("MEMO_IGNORED_FOR_MUXED");
    });
  });
});
