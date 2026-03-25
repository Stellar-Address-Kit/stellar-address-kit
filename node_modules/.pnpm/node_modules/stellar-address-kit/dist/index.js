"use strict";
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// src/index.ts
var index_exports = {};
__export(index_exports, {
  AddressParseError: () => AddressParseError,
  ExtractRoutingError: () => ExtractRoutingError,
  decodeMuxed: () => decodeMuxed,
  detect: () => detect,
  encodeMuxed: () => encodeMuxed,
  extractRouting: () => extractRouting,
  extractRoutingFromTx: () => extractRoutingFromTx,
  normalizeMemoTextId: () => normalizeMemoTextId,
  parse: () => parse,
  routingIdAsBigInt: () => routingIdAsBigInt,
  validate: () => validate
});
module.exports = __toCommonJS(index_exports);

// src/address/detect.ts
var import_stellar_sdk = require("@stellar/stellar-sdk");
var BASE32_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
function decodeBase32(input) {
  const s = input.toUpperCase().replace(/=+$/, "");
  const byteCount = Math.floor(s.length * 5 / 8);
  const result = new Uint8Array(byteCount);
  let buffer = 0;
  let bitsLeft = 0;
  let byteIndex = 0;
  for (const ch of s) {
    const value = BASE32_CHARS.indexOf(ch);
    if (value === -1) throw new Error(`Invalid base32 character: ${ch}`);
    buffer = buffer << 5 | value;
    bitsLeft += 5;
    if (bitsLeft >= 8) {
      if (byteIndex < byteCount) {
        result[byteIndex++] = buffer >> bitsLeft - 8 & 255;
      }
      bitsLeft -= 8;
      buffer &= (1 << bitsLeft) - 1;
    }
  }
  return result;
}
function crc16(bytes) {
  let crc = 0;
  for (const byte of bytes) {
    crc ^= byte << 8;
    for (let i = 0; i < 8; i++) {
      if (crc & 32768) {
        crc = crc << 1 ^ 4129;
      } else {
        crc <<= 1;
      }
      crc &= 65535;
    }
  }
  return crc;
}
function detect(address) {
  if (!address) return "invalid";
  const up = address.toUpperCase();
  if (import_stellar_sdk.StrKey.isValidEd25519PublicKey(up)) return "G";
  if (import_stellar_sdk.StrKey.isValidMed25519PublicKey(up)) return "M";
  if (import_stellar_sdk.StrKey.isValidContract(up)) return "C";
  try {
    const prefix = up[0];
    if (prefix === "M") {
      const decoded = decodeBase32(up);
      if (decoded.length === 43 && decoded[0] === 96) {
        const data = decoded.slice(0, decoded.length - 2);
        const checksum = decoded[decoded.length - 2] | decoded[decoded.length - 1] << 8;
        if (crc16(data) === checksum) {
          return "M";
        }
      }
    }
  } catch {
  }
  return "invalid";
}

// src/address/validate.ts
function validate(address, kind) {
  const detected = detect(address);
  if (detected === "invalid") return false;
  if (kind === void 0) return true;
  return detected === kind;
}

// src/muxed/decode.ts
var import_stellar_sdk2 = require("@stellar/stellar-sdk");
var BASE32_CHARS2 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
function decodeBase322(input) {
  const s = input.toUpperCase().replace(/=+$/, "");
  const byteCount = Math.floor(s.length * 5 / 8);
  const result = new Uint8Array(byteCount);
  let buffer = 0;
  let bitsLeft = 0;
  let byteIndex = 0;
  for (const ch of s) {
    const value = BASE32_CHARS2.indexOf(ch);
    if (value === -1) throw new Error(`Invalid base32 character: ${ch}`);
    buffer = buffer << 5 | value;
    bitsLeft += 5;
    if (bitsLeft >= 8) {
      if (byteIndex < byteCount) {
        result[byteIndex++] = buffer >> bitsLeft - 8 & 255;
      }
      bitsLeft -= 8;
    }
  }
  return result;
}
function crc162(bytes) {
  let crc = 0;
  for (const byte of bytes) {
    crc ^= byte << 8;
    for (let i = 0; i < 8; i++) {
      crc = crc & 32768 ? crc << 1 ^ 4129 : crc << 1;
    }
  }
  return crc & 65535;
}
function decodeStrKey(address) {
  const up = address.toUpperCase();
  const decoded = decodeBase322(up);
  if (decoded.length < 3) throw new Error("invalid encoded string");
  const data = decoded.slice(0, decoded.length - 2);
  const checksum = decoded[decoded.length - 2] | decoded[decoded.length - 1] << 8;
  const computed = crc162(data);
  if (computed !== checksum) throw new Error("invalid checksum");
  return data;
}
function decodeMuxed(mAddress) {
  const data = decodeStrKey(mAddress);
  if (data.length !== 41) throw new Error("invalid payload length");
  const pubkey = data.slice(1, 33);
  const idBytes = data.slice(33, 41);
  let id = 0n;
  for (const byte of idBytes) {
    id = (id << 8n) + BigInt(byte);
  }
  return {
    baseG: import_stellar_sdk2.StrKey.encodeEd25519PublicKey(Buffer.from(pubkey)),
    id: id.toString()
  };
}

// src/address/parse.ts
function parse(address) {
  const up = address.toUpperCase();
  const kind = detect(up);
  if (kind === "invalid") {
    const first = up[0];
    if (first === "G" || first === "M" || first === "C") {
      return {
        kind: "invalid",
        error: {
          code: "INVALID_CHECKSUM",
          input: address,
          message: "Invalid address checksum"
        }
      };
    }
    return {
      kind: "invalid",
      error: {
        code: "UNKNOWN_PREFIX",
        input: address,
        message: "Invalid address"
      }
    };
  }
  switch (kind) {
    case "G":
      return { kind: "G", address: up, warnings: [] };
    case "C":
      return { kind: "C", address: up, warnings: [] };
    case "M": {
      const decoded = decodeMuxed(up);
      return {
        kind: "M",
        address: up,
        baseG: decoded.baseG,
        muxedId: BigInt(decoded.id),
        warnings: []
      };
    }
  }
}

// src/address/errors.ts
var AddressParseError = class _AddressParseError extends Error {
  code;
  input;
  constructor(code, input, message) {
    super(message);
    this.name = "AddressParseError";
    this.code = code;
    this.input = input;
    Object.setPrototypeOf(this, _AddressParseError.prototype);
  }
};

// src/muxed/encode.ts
var import_stellar_sdk3 = require("@stellar/stellar-sdk");
var MAX_UINT64 = 18446744073709551615n;
function encodeMuxed(baseG, id) {
  if (typeof id !== "bigint") {
    throw new TypeError(`ID must be a bigint, received ${typeof id}`);
  }
  if (id < 0n || id > MAX_UINT64) {
    throw new Error(`ID is outside the uint64 range: ${id.toString()}`);
  }
  if (import_stellar_sdk3.StrKey.isValidEd25519PublicKey(baseG) === false) {
    throw new Error(`Invalid base G address: ${baseG}`);
  }
  const baseAccount = new import_stellar_sdk3.Account(baseG, "0");
  const muxedAccount = new import_stellar_sdk3.MuxedAccount(baseAccount, id.toString());
  return muxedAccount.accountId();
}

// src/routing/memo.ts
var UINT64_MAX = BigInt("18446744073709551615");
function normalizeMemoTextId(s) {
  const warnings = [];
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
      message: "Memo routing ID had leading zeros. Normalized to canonical decimal.",
      normalization: { original: s, normalized }
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

// src/routing/extract.ts
var ExtractRoutingError = class _ExtractRoutingError extends Error {
  constructor(message) {
    super(message);
    this.name = "ExtractRoutingError";
    Object.setPrototypeOf(this, _ExtractRoutingError.prototype);
  }
};
function extractRouting(input) {
  const parsed = parse(input.destination);
  if (parsed.kind === "invalid") {
    return {
      destinationBaseAccount: null,
      routingId: null,
      routingSource: "none",
      warnings: [],
      destinationError: {
        code: parsed.error.code,
        message: parsed.error.message
      }
    };
  }
  if (parsed.kind === "C") {
    throw new ExtractRoutingError("Contract addresses cannot be routed");
  }
  if (parsed.kind === "M") {
    const { baseG, id } = decodeMuxed(parsed.address);
    const warnings2 = [...parsed.warnings];
    if (input.memoType === "id" || input.memoType === "text" && /^\d+$/.test(input.memoValue ?? "")) {
      warnings2.push({
        code: "MEMO_PRESENT_WITH_MUXED",
        severity: "warn",
        message: "Routing ID found in both M-address and Memo. M-address ID takes precedence."
      });
    } else if (input.memoType !== "none") {
      warnings2.push({
        code: "MEMO_IGNORED_FOR_MUXED",
        severity: "info",
        message: "Memo present with M-address. Any potential routing ID in memo is ignored."
      });
    }
    return {
      destinationBaseAccount: baseG,
      routingId: id,
      routingSource: "muxed",
      warnings: warnings2
    };
  }
  let routingId = null;
  let routingSource = "none";
  const warnings = [...parsed.warnings];
  if (input.memoType === "id") {
    const norm = normalizeMemoTextId(input.memoValue ?? "");
    routingId = norm.normalized;
    routingSource = norm.normalized ? "memo" : "none";
    warnings.push(...norm.warnings);
    if (!norm.normalized) {
      warnings.push({
        code: "MEMO_ID_INVALID_FORMAT",
        severity: "warn",
        message: "MEMO_ID was empty, non-numeric, or exceeded uint64 max."
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
        message: "MEMO_TEXT was not a valid numeric uint64."
      });
    }
  } else if (input.memoType === "hash" || input.memoType === "return") {
    warnings.push({
      code: "UNSUPPORTED_MEMO_TYPE",
      severity: "warn",
      message: `Memo type ${input.memoType} is not supported for routing.`,
      context: { memoType: input.memoType }
    });
  } else if (input.memoType !== "none") {
    warnings.push({
      code: "UNSUPPORTED_MEMO_TYPE",
      severity: "warn",
      message: `Unrecognized memo type: ${input.memoType}`,
      context: { memoType: "unknown" }
    });
  }
  return {
    destinationBaseAccount: parsed.address,
    routingId,
    routingSource,
    warnings
  };
}

// src/routing/extractFromTx.ts
function extractRoutingFromTx(tx) {
  const op = tx.operations[0];
  if (!op || op.type !== "payment") return null;
  return extractRouting({
    destination: op.destination,
    memoType: tx.memo.type,
    memoValue: tx.memo.value?.toString() ?? null,
    sourceAccount: tx.source ?? null
  });
}

// src/routing/types.ts
function routingIdAsBigInt(routingId) {
  return routingId ? BigInt(routingId) : null;
}
// Annotate the CommonJS export names for ESM import in node:
0 && (module.exports = {
  AddressParseError,
  ExtractRoutingError,
  decodeMuxed,
  detect,
  encodeMuxed,
  extractRouting,
  extractRoutingFromTx,
  normalizeMemoTextId,
  parse,
  routingIdAsBigInt,
  validate
});
