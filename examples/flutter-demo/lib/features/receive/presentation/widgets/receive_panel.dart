import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/widgets/bigint_safe_chip.dart';
import '../bloc/receive_bloc.dart';

class ReceivePanel extends StatefulWidget {
  final TextEditingController addressController;
  const ReceivePanel({super.key, required this.addressController});

  @override
  State<ReceivePanel> createState() => _ReceivePanelState();
}

class _ReceivePanelState extends State<ReceivePanel> {
  final _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _idController.addListener(_onChanged);
  }

  void _onChanged() {
    context.read<ReceiveBloc>().add(
          ReceiveFieldsChanged(
            baseAddress: widget.addressController.text,
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
            'Deposit Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter a User ID if using a G-address, or see the decoded details of an M-address.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
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
                return const Text('Enter details or use address at top');
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
    _idController.dispose();
    super.dispose();
  }
}

