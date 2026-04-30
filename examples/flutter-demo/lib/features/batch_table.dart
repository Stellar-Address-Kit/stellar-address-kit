import 'package:flutter/material.dart';
import 'package:stellar_address_kit/stellar_address_kit.dart';

const _kTestAddress = 'GA7QYNF7SOWQ3GLR2B6RS22TBGZAOR6KLYH4PA5ZAM73A3H4K2HZZSQU';

/// IDs to test: [0, 1, 2^53-1, 2^53, 2^53+1, 2^64-1]
final _testIds = [
  BigInt.zero,
  BigInt.one,
  BigInt.from(9007199254740991),  // 2^53 - 1
  BigInt.from(9007199254740992),  // 2^53
  BigInt.parse('9007199254740993'), // 2^53 + 1  (JS canary)
  BigInt.parse('18446744073709551615'), // 2^64 - 1
];

class _RowData {
  final BigInt id;
  final String mAddress;
  final String intResult;
  final String bigIntResult;
  final bool match;

  _RowData({
    required this.id,
    required this.mAddress,
    required this.intResult,
    required this.bigIntResult,
    required this.match,
  });
}

List<_RowData> _buildRows() {
  return _testIds.map((id) {
    final mAddress = MuxedAddress.encode(baseG: _kTestAddress, id: id);
    final decoded = MuxedDecoder.decodeMuxedString(mAddress);

    // BigInt path (correct)
    final bigIntResult = decoded.id.toString();

    // int.parse path (lossy on Web for values > 2^53)
    String intResult;
    try {
      final asInt = int.parse(bigIntResult);
      intResult = asInt.toString();
    } catch (_) {
      intResult = 'overflow';
    }

    return _RowData(
      id: id,
      mAddress: mAddress,
      intResult: intResult,
      bigIntResult: bigIntResult,
      match: intResult == bigIntResult,
    );
  }).toList();
}

class BatchComparisonTable extends StatelessWidget {
  const BatchComparisonTable({super.key});

  @override
  Widget build(BuildContext context) {
    final rows = _buildRows();
    final corrupted = rows.where((r) => !r.match).length;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Batch ID Comparison', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'Encodes each test ID into an M-address, then decodes via int.parse() vs BigInt. '
            'On Flutter Web, rows above 2^53 show mismatches.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              headingRowColor: WidgetStateProperty.all(
                theme.colorScheme.surfaceContainerHighest,
              ),
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('int.parse()')),
                DataColumn(label: Text('BigInt')),
                DataColumn(label: Text('Match')),
              ],
              rows: rows.map((r) => _buildRow(r)).toList(),
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(corrupted: corrupted, total: rows.length),
        ],
      ),
    );
  }

  DataRow _buildRow(_RowData r) {
    final mismatch = !r.match;
    final rowColor = mismatch
        ? WidgetStateProperty.all(Colors.red.withOpacity(0.08))
        : null;

    return DataRow(
      color: rowColor,
      cells: [
        DataCell(Text(r.id.toString(), style: const TextStyle(fontSize: 11))),
        DataCell(Text(
          r.intResult,
          style: TextStyle(
            fontSize: 11,
            color: mismatch ? Colors.red : null,
            fontWeight: mismatch ? FontWeight.bold : null,
          ),
        )),
        DataCell(Text(r.bigIntResult, style: const TextStyle(fontSize: 11))),
        DataCell(
          Icon(
            r.match ? Icons.check_circle : Icons.cancel,
            color: r.match ? Colors.green : Colors.red,
            size: 18,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int corrupted;
  final int total;

  const _SummaryRow({required this.corrupted, required this.total});

  @override
  Widget build(BuildContext context) {
    final allOk = corrupted == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: allOk
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: allOk
              ? Colors.green.withOpacity(0.4)
              : Colors.red.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            allOk ? Icons.verified : Icons.warning_amber_rounded,
            size: 16,
            color: allOk ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            allOk
                ? '0 of $total IDs corrupted on this platform'
                : '$corrupted of $total IDs corrupted on this platform',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: allOk ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
