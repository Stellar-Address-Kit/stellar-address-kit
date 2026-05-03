import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stellar_address_kit_demo/features/safe_bloc.dart';
import 'package:stellar_address_kit_demo/features/analyze/presentation/bloc/analyze_bloc.dart';

class SafePanel extends StatelessWidget {
  const SafePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Safe Decode (BigInt)',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'This panel uses the native BigInt path to ensure 100% precision on all platforms.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          BlocBuilder<SafeBloc, SafeState>(
            builder: (context, safeState) {
              if (safeState is SafeDecoded) {
                return BlocBuilder<AnalyzeBloc, AnalyzeState>(
                  builder: (context, analyzeState) {
                    BigInt? otherId;
                    if (analyzeState is AnalyzeSuccess) {
                      otherId = analyzeState.analysis.routingId;
                    }

                    final isCorrupted = otherId != null && otherId != safeState.id;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIdCard(safeState.id, isCorrupted, otherId),
                        const SizedBox(height: 24),
                        if (isCorrupted) _buildCorruptionWarning(safeState.id, otherId!),
                      ],
                    );
                  },
                );
              } else if (safeState is SafeError) {
                return Center(child: Text(safeState.error, style: const TextStyle(color: Colors.red)));
              }
              return const Center(child: Text('Waiting for input...'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIdCard(BigInt id, bool isCorrupted, BigInt? otherId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrupted ? Colors.orange : Colors.green.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'EXTRACTED ID',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CORRECT',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            id.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'JetBrains Mono',
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorruptionWarning(BigInt correctId, BigInt corruptedId) {
    final diff = (correctId - corruptedId).abs();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRECISION LOSS DETECTED',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'The left panel shows a corrupted value. Difference: $diff',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
