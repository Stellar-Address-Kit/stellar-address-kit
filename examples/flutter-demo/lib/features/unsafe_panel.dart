import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stellar_address_kit_demo/features/unsafe_bloc.dart';
import 'package:stellar_address_kit_demo/features/analyze/presentation/bloc/analyze_bloc.dart';
import 'package:stellar_address_kit_demo/features/safe_bloc.dart';

class UnsafePanel extends StatefulWidget {
  const UnsafePanel({super.key});

  @override
  State<UnsafePanel> createState() => _UnsafePanelState();
}

class _UnsafePanelState extends State<UnsafePanel> {
  final _addressController = TextEditingController(
    text: 'MAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQADAAAAAAAAAAAAB6AA',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onChanged());
  }

  void _onChanged() {
    final address = _addressController.text;
    context.read<UnsafeBloc>().add(UnsafeAddressChanged(address));
    context.read<AnalyzeBloc>().add(
          AnalyzeInputChanged(
            address: address,
          ),
        );
    context.read<SafeBloc>().add(SafeAddressChanged(address));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.red.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                'Unsafe Decode (int)',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'This panel uses standard int.parse(), which fails on large IDs when running on Flutter Web.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _addressController,
            onChanged: (_) => _onChanged(),
            decoration: const InputDecoration(
              labelText: 'Muxed Address',
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<UnsafeBloc, UnsafeState>(
              builder: (context, state) {
                if (state is UnsafeDecoded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIdCard(state.id, state.corrupted),
                      const SizedBox(height: 24),
                      _buildPlatformNote(),
                    ],
                  );
                } else if (state is UnsafeError) {
                  return Center(child: Text(state.error, style: const TextStyle(color: Colors.red)));
                }
                return const Center(child: Text('Enter address to decode'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdCard(int id, bool corrupted) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: corrupted ? Colors.red : Colors.grey.withOpacity(0.3),
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
                  color: corrupted ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  corrupted ? 'CORRUPTED' : 'OK',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            id.toString(),
            style: TextStyle(
              fontSize: 24,
              fontFamily: 'JetBrains Mono',
              fontWeight: FontWeight.bold,
              color: corrupted ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformNote() {
    final isWeb = kIsWeb;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PLATFORM NOTE',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            isWeb 
              ? 'Running on Web: JavaScript numbers only have 53 bits of precision. This ID exceeds that limit and has been rounded.'
              : 'Running on Native: 64-bit integers are supported natively, so this value is currently correct.',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
