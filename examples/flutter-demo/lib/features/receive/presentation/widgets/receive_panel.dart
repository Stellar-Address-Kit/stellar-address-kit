import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/widgets/bigint_safe_chip.dart';
import '../bloc/receive_bloc.dart';

class ReceivePanel extends StatefulWidget {
  const ReceivePanel({super.key});

  @override
  State<ReceivePanel> createState() => _ReceivePanelState();
}

class _ReceivePanelState extends State<ReceivePanel> {
  final _addressController = TextEditingController(
    text: 'GA7QYNF7SOWQ3GLR2B6RS22TBGZAOR6KLYH4PA5ZAM73A3H4K2HZZSQU',
  );
  final _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _idController.addListener(_onChanged);
    _addressController.addListener(_onChanged);
  }

  void _onChanged() {
    context.read<ReceiveBloc>().add(
          ReceiveFieldsChanged(
            baseAddress: _addressController.text,
            id: _idController.text,
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
            'Generate M-Address',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a muxed address for deposits. This combines your G-address with a user ID.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Base G-Address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _idController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'User ID (uint64)',
              border: OutlineInputBorder(),
              hintText: 'e.g. 123456789',
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: BlocBuilder<ReceiveBloc, ReceiveState>(
              builder: (context, state) {
                if (state is ReceiveSuccess) {
                  return _buildResult(state.instruction);
                } else if (state is ReceiveError) {
                  return Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  );
                }
                return const Text('Enter details to generate');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(dynamic instruction) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: QrImageView(
            data: instruction.muxedAddress,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        const SizedBox(height: 16),
        const BigIntSafeChip(),
        const SizedBox(height: 16),
        SelectableText(
          instruction.muxedAddress,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'JetBrains Mono',
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: instruction.muxedAddress));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard')),
            );
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copy M-Address'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _idController.dispose();
    super.dispose();
  }
}
