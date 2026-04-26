/**
 * BigInt Precision Auditor
 * This tool demonstrates how JavaScript's Number type can silently corrupt
 * Stellar muxed account IDs (uint64) and how stellar-address-kit solves this.
 */

interface CorruptionResult {
  id: string;
  unsafeNumber: number;
  safeBigInt: string;
  corrupted: boolean;
  difference: string;
}

function auditBigIntPrecision(ids: bigint[]): CorruptionResult[] {
  const results: CorruptionResult[] = [];

  for (const id of ids) {
    const safeBigInt = id;
    const unsafeNumber = Number(id);
    const corrupted = BigInt(unsafeNumber) !== safeBigInt;
    const difference = (safeBigInt - BigInt(unsafeNumber)).toString();

    results.push({
      id: id.toString(),
      unsafeNumber,
      safeBigInt: safeBigInt.toString(),
      corrupted,
      difference,
    });
  }

  return results;
}

function printTable(results: CorruptionResult[]): void {
  console.log("BigInt Precision Audit Results");
  console.log("================================");
  console.log("");
  console.log("ID".padEnd(22), "Unsafe Number".padEnd(17), "Safe BigInt".padEnd(22), "Corrupted".padEnd(10), "Difference");
  console.log("-".repeat(95));

  for (const result of results) {
    console.log(
      result.id.padEnd(22),
      result.unsafeNumber.toString().padEnd(17),
      result.safeBigInt.padEnd(22),
      result.corrupted.toString().padEnd(10),
      result.difference
    );
  }
}

function main() {
  const args = process.argv.slice(2);
  const jsonFlag = args.includes("--json");

  // Test IDs that demonstrate the precision loss
  const testIds = [
    0n,
    1n,
    (1n << 53n) - 1n, // MAX_SAFE_INTEGER
    1n << 53n,         // Just above safe integer
    (1n << 53n) + 1n,  // Canary case
    (1n << 64n) - 1n,  // Max uint64
  ];

  const results = auditBigIntPrecision(testIds);

  if (jsonFlag) {
    console.log(JSON.stringify(results, null, 2));
  } else {
    printTable(results);
  }

  // Exit with code 1 if any corruption detected
  const hasCorruption = results.some(r => r.corrupted);
  process.exit(hasCorruption ? 1 : 0);
}

main();
