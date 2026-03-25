import { Transaction } from '@stellar/stellar-sdk';

/**
 * Detects the kind of a Stellar address.
 * Standard addresses (G, M, C) are validated using the Stellar SDK.
 * Custom M-addresses (0x60 format) are validated using internal logic.
 */
declare function detect(address: string): "G" | "M" | "C" | "invalid";

type ErrorCode = "INVALID_CHECKSUM" | "INVALID_LENGTH" | "INVALID_BASE32" | "REJECTED_SEED_KEY" | "REJECTED_PREAUTH" | "REJECTED_HASH_X" | "FEDERATION_ADDRESS_NOT_SUPPORTED" | "UNKNOWN_PREFIX";
declare class AddressParseError extends Error {
    code: ErrorCode;
    input: string;
    constructor(code: ErrorCode, input: string, message: string);
}

type AddressKind = "G" | "M" | "C";
type WarningCode = "NON_CANONICAL_ADDRESS" | "NON_CANONICAL_ROUTING_ID" | "MEMO_IGNORED_FOR_MUXED" | "MEMO_PRESENT_WITH_MUXED" | "CONTRACT_SENDER_DETECTED" | "MEMO_TEXT_UNROUTABLE" | "MEMO_ID_INVALID_FORMAT" | "UNSUPPORTED_MEMO_TYPE" | "INVALID_DESTINATION";
type Warning = {
    code: "NON_CANONICAL_ADDRESS" | "NON_CANONICAL_ROUTING_ID";
    severity: "warn";
    message: string;
    normalization: {
        original: string;
        normalized: string;
    };
} | {
    code: "INVALID_DESTINATION";
    severity: "error";
    message: string;
    context: {
        destinationKind: "C";
    };
} | {
    code: "UNSUPPORTED_MEMO_TYPE";
    severity: "warn";
    message: string;
    context: {
        memoType: "hash" | "return" | "unknown";
    };
} | {
    code: Exclude<WarningCode, "NON_CANONICAL_ADDRESS" | "NON_CANONICAL_ROUTING_ID" | "INVALID_DESTINATION" | "UNSUPPORTED_MEMO_TYPE">;
    severity: "info" | "warn" | "error";
    message: string;
};
type Address = {
    kind: "G";
    address: string;
    warnings: Warning[];
} | {
    kind: "M";
    address: string;
    baseG: string;
    muxedId: bigint;
    warnings: Warning[];
} | {
    kind: "C";
    address: string;
    warnings: Warning[];
};
type ParseResult = Address | {
    kind: "invalid";
    error: {
        code: ErrorCode;
        input: string;
        message: string;
    };
};

declare function validate(address: string, kind?: AddressKind): boolean;

declare function parse(address: string): ParseResult;

declare function encodeMuxed(baseG: string, id: bigint): string;

declare function decodeMuxed(mAddress: string): {
    baseG: string;
    id: string;
};

type RoutingInput = {
    destination: string;
    memoType: string;
    memoValue: string | null;
    sourceAccount: string | null;
};
type KnownMemoType = "none" | "id" | "text" | "hash" | "return";
type RoutingResult = {
    destinationBaseAccount: string | null;
    routingId: string | null;
    routingSource: "muxed" | "memo" | "none";
    warnings: Warning[];
    destinationError?: {
        code: ErrorCode;
        message: string;
    };
};
/**
 * Ergonomic helper for TypeScript callers to get a BigInt from the routingId string.
 */
declare function routingIdAsBigInt(routingId: string | null): bigint | null;

declare class ExtractRoutingError extends Error {
    constructor(message: string);
}
declare function extractRouting(input: RoutingInput): RoutingResult;

declare function extractRoutingFromTx(tx: Transaction): RoutingResult | null;

type NormalizeResult = {
    normalized: string | null;
    warnings: Warning[];
};
declare function normalizeMemoTextId(s: string): NormalizeResult;

export { type Address, type AddressKind, AddressParseError, type ErrorCode, ExtractRoutingError, type KnownMemoType, type NormalizeResult, type ParseResult, type RoutingInput, type RoutingResult, type Warning, type WarningCode, decodeMuxed, detect, encodeMuxed, extractRouting, extractRoutingFromTx, normalizeMemoTextId, parse, routingIdAsBigInt, validate };
