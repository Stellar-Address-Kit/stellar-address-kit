import 'package:flutter/material.dart';
import '../../receive/presentation/widgets/receive_panel.dart';
import '../../analyze/presentation/widgets/analyze_panel.dart';
import '../../batch_table.dart';

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
            return SingleChildScrollView(
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(child: ReceivePanel()),
                        VerticalDivider(width: 1),
                        Expanded(child: AnalyzePanel()),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  const BatchComparisonTable(),
                ],
              ),
            );
          } else if (constraints.maxWidth > 600) {
            return const SingleChildScrollView(
              child: Column(
                children: [
                  ReceivePanel(),
                  Divider(height: 1),
                  AnalyzePanel(),
                  Divider(height: 1),
                  BatchComparisonTable(),
                ],
              ),
            );
          } else {
            return const DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Receive', icon: Icon(Icons.download)),
                      Tab(text: 'Analyze', icon: Icon(Icons.search)),
                      Tab(text: 'Batch', icon: Icon(Icons.table_chart)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ReceivePanel(),
                        AnalyzePanel(),
                        SingleChildScrollView(child: BatchComparisonTable()),
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
