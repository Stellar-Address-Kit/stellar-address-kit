export type AddressKind = "G" | "M" | "C";

export type Address =
  | {
      kind: "G";
      address: string;
    }
  | {
      kind: "M";
      address: string;
      baseG: string;
      muxedId: bigint;
    }
  | {
      kind: "C";
      address: string;
    };
