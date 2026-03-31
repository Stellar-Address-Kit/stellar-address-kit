import { MuxedAccount } from "@stellar/stellar-sdk";

/**
 * Decodes a muxed Stellar address (SEP-23) into its base account and ID.
 * Uses the official Stellar SDK MuxedAccount parser to ensure specification compliance.
 * 
 * @param mAddress - The muxed address string starting with 'M'.
 * @returns Metadata containing the base G address and the 64-bit BigInt ID.
 * @throws {Error} If the address is not a valid muxed address.
 */
export function decodeMuxed(mAddress: string): { baseG: string; id: bigint } {
  // MuxedAccount.fromAddress requires a sequence number. Since this is an
  // offline decoding of the address parts, we provide a placeholder.
  const muxed = MuxedAccount.fromAddress(mAddress, "0");

  return {
    baseG: muxed.baseAccount().accountId(),
    id: BigInt(muxed.id()),
  };
}
