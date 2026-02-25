import 'package:meta/meta.dart';

/// Defines the underlying type of a Stellar address.
enum AddressKind {
  /// G... address (Ed25519 Public Key)
  g,

  /// M... address (Muxed Account)
  m,

  /// C... address (Contract ID)
  c,
}

/// Thrown when a string cannot be parsed as a valid Stellar address.
class StellarAddressException implements Exception {
  final String message;
  const StellarAddressException(this.message);

  @override
  String toString() => 'StellarAddressException: $message';
}

/// An immutable representation of a Stellar Address.
@immutable
class StellarAddress {
  /// The specific kind of address (g, m, or c).
  final AddressKind kind;

  /// The original, encoded string representation of the address.
  final String raw;

  /// The base G... address associated with this address.
  /// For G-addresses, it matches [raw]. For M-addresses, it is the underlying account.
  final String? baseG;

  /// The 64-bit unsigned integer ID. Only present for M-addresses (muxedId).
  final BigInt? muxedId;

  /// Private internal constructor to enforce immutability.
  const StellarAddress._({
    required this.kind,
    required this.raw,
    this.baseG,
    this.muxedId,
  });

  /// Factory constructor that parses a Stellar address string.
  ///
  /// Throws [StellarAddressException] for invalid input or length.
  factory StellarAddress.parse(String address) {
    if (address.isEmpty) {
      throw const StellarAddressException('Address cannot be empty.');
    }

    // Basic length validation: G/C addresses are 56, M are 69.
    if (address.length != 56 && address.length != 69) {
      throw StellarAddressException('Invalid address length: ${address.length}');
    }

    final String prefix = address[0].toUpperCase();

    switch (prefix) {
      case 'G':
        return StellarAddress._(
          kind: AddressKind.g,
          raw: address,
          baseG: address,
        );
      case 'M':
        // Integration Note: decoding logic from src/muxed/decode.dart
        // would be used here to populate baseG and muxedId.
        return StellarAddress._(
          kind: AddressKind.m,
          raw: address,
        );
      case 'C':
        return StellarAddress._(
          kind: AddressKind.c,
          raw: address,
          baseG: address,
        );
      default:
        throw StellarAddressException('Unsupported address prefix: $prefix');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StellarAddress &&
          runtimeType == other.runtimeType &&
          raw == other.raw;

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() => raw;
}