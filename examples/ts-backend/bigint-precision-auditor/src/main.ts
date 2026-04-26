import { encodeMuxed, decodeMuxed } from "stellar-address-kit";

/**
 * BigInt Precision Auditor - Single Address Comparison
 * 
 * This tool demonstrates how JavaScript's Number type (float64) silently
 * corrupts 64-bit integer IDs used in Stellar muxed addresses, and how
 * stellar-address-kit's BigInt implementation preserves them.
 */

const TEST_G_ADDRESS = "GA7QYNF7SOWQ3GLR2BGMZEHXAVIRZA4KVWLTJJFC7MGXUA74P7UJVWH4";
const DEFAULT_ID = 9007199254740993n; // 2^53 + 1 (First unsafe integer)

function audit(mAddress: string) {
  try {
    // Safe path: decode via stellar-address-kit, keep as BigInt
    const { id: safeId } = decodeMuxed(mAddress);
    
    // Unsafe path: extract muxed ID, convert to Number()
    const unsafeId = Number(safeId);
    
    // Comparison logic
    const diff = safeId - BigInt(unsafeId);
    const isMatch = diff === 0n;
    const matchStatus = isMatch ? "MATCH" : "CORRUPTED";

    // ASCII Box-drawing output
    console.log("+---------------------------------------------------------------+");
    console.log("| BIGINT PRECISION AUDIT: SINGLE ADDRESS COMPARISON             |");
    console.log("+---------------------------------------------------------------+");
    console.log(`| Address: ${mAddress.padEnd(52)} |`);
    console.log("+-----------------------+---------------------------------------+");
    console.log("| PATH                  | DECODED ID VALUE                      |");
    console.log("+-----------------------+---------------------------------------+");
    console.log(`| Safe (BigInt)         | ${safeId.toString().padEnd(37)} |`);
    console.log(`| Unsafe (Number)       | ${unsafeId.toString().padEnd(37)} |`);
    console.log("+-----------------------+---------------------------------------+");
    console.log(`| Match Status          | ${matchStatus.padEnd(37)} |`);
    console.log(`| Numeric Difference    | ${diff.toString().padEnd(37)} |`);
    console.log("+-----------------------+---------------------------------------+");

    if (!isMatch) {
      console.log("\n[!] ALERT: Precision loss detected!");
      console.log(`    The ID ${safeId} is too large for Number().`);
      console.log(`    It has been corrupted to ${unsafeId}.`);
    } else {
      console.log("\n[OK] No precision loss detected for this ID.");
    }
  } catch (error) {
    console.error(`\n[!] Error: ${error instanceof Error ? error.message : String(error)}`);
    process.exit(1);
  }
}

// Accept one CLI argument: a muxed M-address.
const arg = process.argv[2];
let targetAddress = arg;

if (!arg) {
  console.log(`No address provided. Auditing default ID: ${DEFAULT_ID}`);
  targetAddress = encodeMuxed(TEST_G_ADDRESS, DEFAULT_ID);
}

audit(targetAddress);
