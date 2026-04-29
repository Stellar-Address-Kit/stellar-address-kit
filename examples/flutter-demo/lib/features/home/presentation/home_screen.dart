import 'package:flutter/material.dart';
import '../../receive/presentation/widgets/receive_panel.dart';
import '../../analyze/presentation/widgets/analyze_panel.dart';
import 'package:stellar_address_kit_demo/features/safe_panel.dart';
import 'package:stellar_address_kit_demo/features/unsafe_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stellar Address Kit'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return const Row(
              children: [
                Expanded(child: UnsafePanel()),
                VerticalDivider(width: 1),
                Expanded(child: AnalyzePanel()),
                VerticalDivider(width: 1),
                Expanded(child: SafePanel()),
              ],
            );
          } else if (constraints.maxWidth > 600) {
            return const SingleChildScrollView(
              child: Column(
                children: [
                  UnsafePanel(),
                  Divider(height: 1),
                  AnalyzePanel(),
                  Divider(height: 1),
                  SafePanel(),
                ],
              ),
            );
          } else {
            return const DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Unsafe', icon: Icon(Icons.warning)),
                      Tab(text: 'Analyze', icon: Icon(Icons.search)),
                      Tab(text: 'Safe', icon: Icon(Icons.security)),
                      Tab(text: 'Receive', icon: Icon(Icons.download)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        UnsafePanel(),
                        AnalyzePanel(),
                        SafePanel(),
                        ReceivePanel(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
