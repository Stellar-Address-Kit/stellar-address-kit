# Stellar Address Kit Demo (Flutter)

A production-grade reference implementation of the `stellar_address_kit`, demonstrating best practices for deposit routing in Stellar wallets and exchanges.

## What this demonstrates
This demo highlights the library's ability to ensure **deposit routing correctness** across platforms. It specifically showcases:
- **BigInt Safety**: Reliable handling of 64-bit muxed IDs on **Flutter Web**, bypassing the common JavaScript precision loss at 2^53.
- **Structured Routing Logic**: Using `extractRouting` to reconcile G-addresses, M-addresses, and Memos.
- **Compliance UX**: Real-time warnings for edge cases like contract-senders or non-canonical IDs.

## Live Demo
🚀 [View Live Web Demo](https://boxkit-labs.github.io/stellar-address-kit-demo) *(Placeholder)*

## Prerequisites
- Flutter SDK 3.16+
- Dart SDK 3.2+

## Run Locally

### Web
```bash
flutter run -d chrome
```

### Android / iOS
```bash
flutter run
```

## Architecture
This demo follows **Clean Architecture** with **BLoC** for state management:
- **Domain Layer**: Pure business logic and entities. No dependencies on UI or external libraries.
- **Presentation Layer**: BLoC isolates the UI from logic. Widgets are small, stateless where possible, and use Material 3.
- **Responsive Layout**: Adapts seamlessly from mobile tabs to side-by-side desktop panels.

## What this demonstrates (Value Prop)
1.  **Correctness**: The "BigInt-safe" chip in the Receive panel isn't just a label—it's backed by `stellar_address_kit`'s core implementation that uses `BigInt` for all ID operations, ensuring that a user ID like `9007199254740993` (2^53 + 1) is never corrupted.
2.  **Safety**: The Analyze panel auto-disables memo fields when an M-address is detected, visually demonstrating the library's "Muxed ID takes precedence" policy to prevent user error.
3.  **Auditability**: Structured warnings are mapped to human-readable UI hints, showing how wallet engineers can provide better feedback to users during the payment flow.

## Link to Core Library
[stellar_address_kit on pub.dev](https://pub.dev/packages/stellar_address_kit)

## License
MIT
