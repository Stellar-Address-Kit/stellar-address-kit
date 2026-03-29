/**
 * Unit tests for validate()
 *
 * validate(address, kind?) returns:
 *   - true  if the address is structurally valid AND (if kind is given) its
 *           detected kind matches the expected kind
 *   - false otherwise
 *
 * These tests cover:
 *  1. No-kind overload  – any valid address returns true
 *  2. Kind-match        – each kind matches itself
 *  3. Kind-mismatch     – each valid address returns false for every other kind
 *  4. Invalid inputs    – corrupted checksums, empty strings, garbage
 *  5. Case insensitivity – lowercase addresses are accepted
 */

import { describe, it, expect } from "vitest";
import { validate } from "../address/validate";

// ─── Canonical fixtures ───────────────────────────────────────────────────────

const G = "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H";
const M = "MBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OAAAAAAAAAAAPOGVY";
const C = "CAAQCAIBAEAQCAIBAEAQCAIBAEAQCAIBAEAQCAIBAEAQCAIBAEAQC526";

const G_BAD_CHECKSUM = "GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2X";

// ─── 1. No-kind overload ──────────────────────────────────────────────────────

describe("validate() – no kind argument (any valid address)", () => {
  it("returns true for a valid G-address", () => {
    expect(validate(G)).toBe(true);
  });

  it("returns true for a valid M-address", () => {
    expect(validate(M)).toBe(true);
  });

  it("returns true for a valid C-address", () => {
    expect(validate(C)).toBe(true);
  });

  it("returns false for an invalid string", () => {
    expect(validate("not-a-stellar-address")).toBe(false);
  });

  it("returns false for an empty string", () => {
    expect(validate("")).toBe(false);
  });
});

// ─── 2. Kind-match ────────────────────────────────────────────────────────────

describe("validate() – kind-match (correct kind returns true)", () => {
  it('validate(G, "G") → true', () => {
    expect(validate(G, "G")).toBe(true);
  });

  it('validate(M, "M") → true', () => {
    expect(validate(M, "M")).toBe(true);
  });

  it('validate(C, "C") → true', () => {
    expect(validate(C, "C")).toBe(true);
  });
});

// ─── 3. Kind-mismatch ─────────────────────────────────────────────────────────

describe("validate() – kind-mismatch (wrong kind returns false)", () => {
  // G-address against non-G kinds
  it('validate(G, "M") → false', () => {
    expect(validate(G, "M")).toBe(false);
  });

  it('validate(G, "C") → false', () => {
    expect(validate(G, "C")).toBe(false);
  });

  // M-address against non-M kinds
  it('validate(M, "G") → false', () => {
    expect(validate(M, "G")).toBe(false);
  });

  it('validate(M, "C") → false', () => {
    expect(validate(M, "C")).toBe(false);
  });

  // C-address against non-C kinds
  it('validate(C, "G") → false', () => {
    expect(validate(C, "G")).toBe(false);
  });

  it('validate(C, "M") → false', () => {
    expect(validate(C, "M")).toBe(false);
  });
});

// ─── 4. Invalid inputs ────────────────────────────────────────────────────────

describe("validate() – invalid inputs always return false", () => {
  it("returns false for a G-address with a corrupted checksum (no kind)", () => {
    expect(validate(G_BAD_CHECKSUM)).toBe(false);
  });

  it('returns false for a G-address with a corrupted checksum + kind "G"', () => {
    expect(validate(G_BAD_CHECKSUM, "G")).toBe(false);
  });

  it("returns false for a truncated G-address", () => {
    expect(validate(G.slice(0, 20))).toBe(false);
  });

  it("returns false for a truncated M-address", () => {
    expect(validate(M.slice(0, 20))).toBe(false);
  });

  it("returns false for a whitespace-only string", () => {
    expect(validate("   ")).toBe(false);
  });

  it("returns false for a purely numeric string", () => {
    expect(validate("123456789")).toBe(false);
  });

  it('returns false for an S-prefixed secret key (even with kind "G")', () => {
    expect(validate("SAWAIYNFPJI74KRGDL27V7GVMZ4WSTQRCWL6C67MAVXXVWU33MAE3PAD", "G")).toBe(false);
  });

  it("returns false for a G-address with extra trailing characters", () => {
    expect(validate(G + "AAAA")).toBe(false);
  });
});

// ─── 5. Case insensitivity ────────────────────────────────────────────────────

describe("validate() – case insensitivity", () => {
  it("returns true for a lowercase G-address (no kind)", () => {
    expect(validate(G.toLowerCase())).toBe(true);
  });

  it('returns true for a lowercase G-address with kind "G"', () => {
    expect(validate(G.toLowerCase(), "G")).toBe(true);
  });

  it("returns true for a lowercase M-address (no kind)", () => {
    expect(validate(M.toLowerCase())).toBe(true);
  });

  it('returns true for a lowercase M-address with kind "M"', () => {
    expect(validate(M.toLowerCase(), "M")).toBe(true);
  });

  it('returns false for a lowercase G-address with kind "M" (kind mismatch)', () => {
    expect(validate(G.toLowerCase(), "M")).toBe(false);
  });
});
