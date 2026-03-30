import { describe, it, expect } from "vitest";
import { encodeMuxed } from "../muxed/encode";
import { decodeMuxed } from "../muxed/decode";

const G_ADDRESS = "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI";
const EDGE_IDS = [
  0n,
  1n,
  (1n << 53n) - 1n,
  1n << 53n,
  (1n << 53n) + 1n,
  (1n << 64n) - 1n,
] as const;

describe("BigInt boundary edge-case tests", () => {
  it("round-trips boundary IDs through muxed encode/decode without precision loss", () => {
    for (const id of EDGE_IDS) {
      const mAddress = encodeMuxed(G_ADDRESS, id);
      const decoded = decodeMuxed(mAddress);

      expect(mAddress).toMatch(/^M/);
      expect(decoded.baseG).toBe(G_ADDRESS);
      expect(decoded.id).toBe(id);
      expect(decoded.id.toString()).toBe(id.toString());
    }
  });

  it("keeps literal parity for 2^53 + 1 (Number-unsafe canary)", () => {
    const canary = (1n << 53n) + 1n;
    const decoded = decodeMuxed(encodeMuxed(G_ADDRESS, canary));
    const truncated = BigInt(Number(canary));

    expect(decoded.id).toBe(canary);
    expect(decoded.id).not.toBe(truncated);
    expect(decoded.id.toString()).toBe("9007199254740993");
  });
});
