import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/receive/domain/usecases/generate_deposit_instruction.dart';
import 'features/receive/presentation/bloc/receive_bloc.dart';
import 'features/analyze/domain/usecases/analyze_address.dart';
import 'package:stellar_address_kit_demo/features/analyze/presentation/bloc/analyze_bloc.dart';
import 'package:stellar_address_kit_demo/features/safe_bloc.dart';
import 'package:stellar_address_kit_demo/features/unsafe_bloc.dart';
import 'package:stellar_address_kit_demo/features/home/presentation/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReceiveBloc(
            generateUseCase: GenerateDepositInstruction(),
          ),
        ),
        BlocProvider(
          create: (context) => AnalyzeBloc(
            analyzeUseCase: AnalyzeAddress(),
          ),
        ),
        BlocProvider(
          create: (context) => SafeBloc(),
        ),
        BlocProvider(
          create: (context) => UnsafeBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Stellar Address Kit Demo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}
