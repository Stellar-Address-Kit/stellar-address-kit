import 'package:flutter/material.dart';
import '../../receive/presentation/widgets/receive_panel.dart';
import '../../analyze/presentation/widgets/analyze_panel.dart';

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
                Expanded(child: ReceivePanel()),
                VerticalDivider(width: 1),
                Expanded(child: AnalyzePanel()),
              ],
            );
          } else if (constraints.maxWidth > 600) {
            return const SingleChildScrollView(
              child: Column(
                children: [
                  ReceivePanel(),
                  Divider(height: 1),
                  AnalyzePanel(),
                ],
              ),
            );
          } else {
            return const DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Receive', icon: Icon(Icons.download)),
                      Tab(text: 'Analyze', icon: Icon(Icons.search)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ReceivePanel(),
                        AnalyzePanel(),
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
