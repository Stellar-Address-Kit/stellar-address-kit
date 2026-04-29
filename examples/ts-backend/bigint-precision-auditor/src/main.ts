import { encodeMuxed, decodeMuxed } from "stellar-address-kit";

/**
 * BigInt Precision Auditor - Single Address Comparison
 * 
 * This tool demonstrates how JavaScript's Number type (float64) silently
 * corrupts 64-bit integer IDs used in Stellar muxed addresses, and how
 * stellar-address-kit's BigInt implementation preserves them.
 */

const TEST_G_ADDRESS = "GAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADRSI";
const DEFAULT_ID = 9007199254740993n; // 2^53 + 1 (First unsafe integer)

function audit(mAddress: string) {
  const { id: safeId } = decodeMuxed(mAddress);
  const unsafeId = Number(safeId);
  const diff = safeId - BigInt(unsafeId);
  const isMatch = diff === 0n;

  return {
    id: safeId.toString(),
    unsafeNumber: unsafeId,
    safeBigInt: safeId.toString(),
    corrupted: !isMatch,
    difference: diff.toString(),
  };
}

function renderTable(result: ReturnType<typeof audit>, mAddress: string) {
  const safeId = result.safeBigInt;
  const unsafeId = result.unsafeNumber.toString();
  const matchStatus = result.corrupted ? "CORRUPTED" : "MATCH";

  console.log("+-------------------------------------------------------------------------------------+");
  console.log(`| ${"BIGINT PRECISION AUDIT: SINGLE ADDRESS COMPARISON".padEnd(83)} |`);
  console.log("+-------------------------------------------------------------------------------------+");
  console.log(`| ${`Address: ${mAddress}`.padEnd(83)} |`);
  console.log("+-----------------------+-----------------------------------------------------------+");
  console.log(`| ${"PATH".padEnd(21)} | ${"DECODED ID VALUE".padEnd(59)} |`);
  console.log("+-----------------------+-----------------------------------------------------------+");
  console.log(`| ${"Safe (BigInt)".padEnd(21)} | ${safeId.padEnd(59)} |`);
  console.log(`| ${"Unsafe (Number)".padEnd(21)} | ${unsafeId.padEnd(59)} |`);
  console.log("+-----------------------+-----------------------------------------------------------+");
  console.log(`| ${"Match Status".padEnd(21)} | ${matchStatus.padEnd(59)} |`);
  console.log(`| ${"Numeric Difference".padEnd(21)} | ${result.difference.padEnd(59)} |`);
  console.log("+-----------------------+-----------------------------------------------------------+");

  if (result.corrupted) {
    console.log("\n[!] ALERT: Precision loss detected!");
    console.log(`    The ID ${safeId} is too large for Number().`);
    console.log(`    It has been corrupted to ${unsafeId}.`);
  } else {
    console.log("\n[OK] No precision loss detected for this ID.");
  }
}

const rawArgs = process.argv.slice(2);
const jsonMode = rawArgs.includes("--json");
const addresses = rawArgs.filter((arg) => arg !== "--json");

const targetAddresses = addresses.length > 0
  ? addresses
  : [encodeMuxed(TEST_G_ADDRESS, DEFAULT_ID)];

try {
  const results = targetAddresses.map((address) => audit(address));

  if (jsonMode) {
    console.log(JSON.stringify(results, null, 2));
  } else {
    if (addresses.length === 0) {
      console.log(`No address provided. Auditing default ID: ${DEFAULT_ID}`);
      console.log(`Encoded M-address: ${targetAddresses[0]}`);
      console.log("");
    }

    results.forEach((result, index) => {
      renderTable(result, targetAddresses[index]);
      if (index < results.length - 1) {
        console.log("");
      }
    });
  }

  process.exitCode = results.some((result) => result.corrupted) ? 1 : 0;
} catch (error) {
  console.error(`\n[!] Error: ${error instanceof Error ? error.message : String(error)}`);
  process.exit(1);
}
