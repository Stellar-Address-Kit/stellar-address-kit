import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../receive/presentation/widgets/receive_panel.dart';
import '../../analyze/presentation/widgets/analyze_panel.dart';
import '../../receive/presentation/bloc/receive_bloc.dart' as receive;
import '../../analyze/presentation/bloc/analyze_bloc.dart' as analyze;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _dispatchInitial());
    _addressController.addListener(_onAddressChanged);
  }

  void _dispatchInitial() {
    _onAddressChanged();
  }

  void _onAddressChanged() {
    final address = _addressController.text;
    context.read<receive.ReceiveBloc>().add(receive.AddressChanged(address));
    context.read<analyze.AnalyzeBloc>().add(analyze.AddressChanged(address));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stellar Address Kit'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Shared Address Input (G, M, or C)',
                hintText: 'Paste any Stellar address...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    children: [
                      Expanded(child: ReceivePanel(addressController: _addressController)),
                      const VerticalDivider(width: 1),
                      Expanded(child: AnalyzePanel(addressController: _addressController)),
                    ],
                  );

                } else if (constraints.maxWidth > 600) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ReceivePanel(addressController: _addressController),
                        const Divider(height: 1),
                        AnalyzePanel(addressController: _addressController),
                      ],
                    ),
                  );
                } else {
                  return DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'Receive', icon: Icon(Icons.download)),
                            Tab(text: 'Analyze', icon: Icon(Icons.search)),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              ReceivePanel(addressController: _addressController),
                              AnalyzePanel(addressController: _addressController),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

              },
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

