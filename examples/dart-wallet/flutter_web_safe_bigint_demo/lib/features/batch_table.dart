import 'package:flutter/material.dart';
import 'package:stellar_address_kit/stellar_address_kit.dart';

// Fixed test G-address (a well-known Stellar testnet account)
const _testG = 'GAAZI4TCR3TY5OJHCTJC2A4QSY6CJWJH5IAJTGKIN2ER7LBNVKOCCWN';

// The 6 canonical test IDs from the spec
final _testIds = [
  BigInt.zero,
  BigInt.one,
  BigInt.from(2).pow(53) - BigInt.one, // 2^53 - 1
  BigInt.from(2).pow(53), // 2^53
  BigInt.from(2).pow(53) + BigInt.one, // 2^53 + 1 (canary)
  BigInt.parse('18446744073709551615'), // 2^64 - 1
];

final _idLabels = [
  '0',
  '1',
  '2⁵³−1',
  '2⁵³',
  '2⁵³+1',
  '2⁶⁴−1',
];

class _RowData {
  final String label;
  final BigInt id;
  final String intResult;
  final String bigIntResult;
  final bool match;

  _RowData({
    required this.label,
    required this.id,
    required this.intResult,
    required this.bigIntResult,
    required this.match,
  });
}

List<_RowData> _buildRows() {
  return List.generate(_testIds.length, (i) {
    final id = _testIds[i];
    final label = _idLabels[i];

    // Encode the muxed address using BigInt (always correct)
    String mAddress;
    try {
      mAddress = MuxedAddress.encode(baseG: _testG, id: id);
    } catch (e) {
      return _RowData(
        label: label,
        id: id,
        intResult: 'encode error',
        bigIntResult: 'encode error',
        match: false,
      );
    }

    // Decode via BigInt (stellar_address_kit — always correct)
    String bigIntResult;
    try {
      final decoded = MuxedAddress.decode(mAddress);
      bigIntResult = decoded.id.toString();
    } catch (e) {
      bigIntResult = 'error';
    }

    // Decode via int.parse() — loses precision above 2^53 on JS/web
    String intResult;
    try {
      final decoded = MuxedAddress.decode(mAddress);
      // Simulate what int.parse() does: on native Dart this is fine,
      // on Flutter Web (JS) int is a JS Number and silently truncates above 2^53.
      final asInt = int.parse(decoded.id.toString());
      intResult = asInt.toString();
    } catch (e) {
      intResult = 'error';
    }

    final match = intResult == bigIntResult;

    return _RowData(
      label: label,
      id: id,
      intResult: intResult,
      bigIntResult: bigIntResult,
      match: match,
    );
  });
}

class BatchComparisonTable extends StatelessWidget {
  const BatchComparisonTable({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows();
    final corruptedCount = rows.where((r) => !r.match).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Batch ID Comparison: int vs BigInt',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              columns: const [
                DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('int result', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('BigInt result', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Match', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: rows.map((row) {
                final isCorrupted = !row.match;
                return DataRow(
                  color: isCorrupted
                      ? WidgetStateProperty.all(Colors.red.shade50)
                      : null,
                  cells: [
                    DataCell(Text(row.label)),
                    DataCell(Text(
                      row.intResult,
                      style: isCorrupted
                          ? const TextStyle(color: Colors.red)
                          : null,
                    )),
                    DataCell(Text(row.bigIntResult)),
                    DataCell(
                      Icon(
                        row.match ? Icons.check_circle : Icons.cancel,
                        color: row.match ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$corruptedCount of ${rows.length} IDs corrupted on this platform',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: corruptedCount > 0 ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
