import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'unsafe_bloc.dart';

class UnsafePanel extends StatelessWidget {
  const UnsafePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnsafeBloc, UnsafeState>(
      builder: (context, state) {
        return Column(
          children: [
            const Text('Standard int',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Unsafe Processing...'),
            if (state is UnsafeAddressState)
              Text('ID: ${state.id}', style: const TextStyle(fontSize: 14)),

          ],
        );
      },
    );
  }
}
