import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/unsafe_panel.dart';
import 'features/safe_panel.dart';
import 'features/batch_table.dart';
import 'features/unsafe_bloc.dart' as unsafe;
import 'features/safe_bloc.dart' as safe;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _addressController = TextEditingController(
    text: 'MAYCUYT553C5LHVE2XPW5GMEJT4BXGM7AHMJWLAPZP53KJO7EIQAD7777777777774OFW',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onChanged());
    _addressController.addListener(_onChanged);
  }

  void _onChanged() {
    final address = _addressController.text;
    context.read<unsafe.UnsafeBloc>().add(unsafe.AddressChanged(address));
    context.read<safe.SafeBloc>().add(safe.AddressChanged(address));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Safe BigInt Demo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address Input',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: isWide
                ? Row(
                    children: [
                      Expanded(child: const UnsafePanel()),
                      const VerticalDivider(),
                      Expanded(child: const SafePanel()),
                      const VerticalDivider(),
                      Expanded(child: const BatchTable()),
                    ],

                  )
                : ListView(
                    children: [
                      const UnsafePanel(),
                      const Divider(),
                      const SafePanel(),
                      const Divider(),
                      const BatchTable(),
                    ],
                  ),


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

