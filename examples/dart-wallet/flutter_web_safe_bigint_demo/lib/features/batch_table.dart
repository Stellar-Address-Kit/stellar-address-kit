import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'safe_bloc.dart';

class BatchTable extends StatelessWidget {
  const BatchTable({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SafeBloc, SafeState>(
      builder: (context, state) {
        return Column(
          children: [
            const Text('Batch Status',
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (state is SafeAddressState)
              const Text('Batch updated for new address')
            else
              const Text('Waiting for input...'),
          ],
        );
      },
    );
  }
}
