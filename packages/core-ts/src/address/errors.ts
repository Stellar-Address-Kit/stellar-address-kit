export type ErrorCode =
  | "INVALID_CHECKSUM"
  | "INVALID_LENGTH"
  | "INVALID_BASE32"
  | "UNKNOWN_PREFIX";

export class AddressParseError extends Error {
  code: ErrorCode;
  input: string;

  constructor(code: ErrorCode, input: string, message: string) {
    super(message);
    this.name = "AddressParseError";
    this.code = code;
    this.input = input;
    Object.setPrototypeOf(this, AddressParseError.prototype);
  }
}
