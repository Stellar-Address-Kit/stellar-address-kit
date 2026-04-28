import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stellar_address_kit/stellar_address_kit.dart';
import '../../../../core/widgets/address_badge.dart';
import '../bloc/analyze_bloc.dart';

class AnalyzePanel extends StatefulWidget {
  final TextEditingController addressController;
  const AnalyzePanel({super.key, required this.addressController});

  @override
  State<AnalyzePanel> createState() => _AnalyzePanelState();
}

class _AnalyzePanelState extends State<AnalyzePanel> {
  final _memoController = TextEditingController();
  final _sourceController = TextEditingController();
  String _memoType = 'none';

  @override
  void initState() {
    super.initState();
    _memoController.addListener(_onChanged);
    _sourceController.addListener(_onChanged);
  }

  void _onChanged() {
    context.read<AnalyzeBloc>().add(
          AnalyzeInputChanged(
            address: widget.addressController.text,
            memoType: _memoType,
            memoValue: _memoController.text,
            sourceAccount: _sourceController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analyze & Route',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'The address above is being analyzed for routing in a production system.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          BlocBuilder<AnalyzeBloc, AnalyzeState>(
            builder: (context, state) {
              final isMuxed = state is AnalyzeSuccess && state.analysis.addressKind == 'M';
              
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: _memoType,
                          disabledHint: const Text('Disabled for M'),
                          decoration: const InputDecoration(
                            labelText: 'Memo Type',
                            border: OutlineInputBorder(),
                          ),
                          items: ['none', 'id', 'text', 'hash', 'return']
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: isMuxed ? null : (val) {
                            setState(() => _memoType = val!);
                            _onChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _memoController,
                          enabled: !isMuxed,
                          decoration: const InputDecoration(
                            labelText: 'Memo Value',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isMuxed)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Muxed addresses carry their own routing ID. Memo fields are disabled to prevent conflicts.',
                        style: TextStyle(fontSize: 10, color: Colors.blue),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _sourceController,
            decoration: const InputDecoration(
              labelText: 'Source Account (Optional)',
              border: OutlineInputBorder(),
              hintText: 'Simulate contract-sender (C...)',
            ),
          ),
          const SizedBox(height: 32),
          BlocBuilder<AnalyzeBloc, AnalyzeState>(
            builder: (context, state) {
              if (state is AnalyzeSuccess) {
                return _buildAnalysisResult(state.analysis);
              }
              return const Center(child: Text('Enter or paste an address at the top'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult(dynamic analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AddressBadge(kind: analysis.addressKind),
            const SizedBox(width: 12),
            const Text('Routing Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoRow('Base Account', analysis.destinationBaseAccount),
        _buildInfoRow('Routing ID', analysis.routingId?.toString() ?? 'None'),
        _buildInfoRow('Source', analysis.routingSource.toString().split('.').last),
        if (analysis.warnings.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          const Text('Warnings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          ...analysis.warnings.map((w) => _buildWarningTile(w)),
        ],
        if (analysis.error != null)
          _buildErrorTile(analysis.error!),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Flexible(
            child: SelectableText(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontFamily: 'JetBrains Mono'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningTile(RoutingWarning w) {
    final color = w.severity == 'error' ? Colors.red : (w.severity == 'warn' ? Colors.amber : Colors.blue);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${w.code}: ${w.message}',
              style: TextStyle(fontSize: 11, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorTile(DestinationError e) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.code.toString().split('.').last, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text(e.message, style: const TextStyle(fontSize: 12, color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _memoController.dispose();
    _sourceController.dispose();
    super.dispose();
  }
}

