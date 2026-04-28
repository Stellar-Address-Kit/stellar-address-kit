import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'safe_bloc.dart';

class SafePanel extends StatelessWidget {
  const SafePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SafeBloc, SafeState>(
      builder: (context, state) {
        return Column(
          children: [
            const Text('BigInt (stellar_address_kit)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Safe Processing...'),
            if (state is SafeAddressState)
              Text(state.address, style: const TextStyle(fontSize: 10)),
          ],
        );
      },
    );
  }
}
