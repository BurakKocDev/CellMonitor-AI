import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/fleet_dashboard_screen.dart';
import 'state/simulation_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SimulationState(),
      child: const CellMonitorApp(),
    ),
  );
}

class CellMonitorApp extends StatelessWidget {
  const CellMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CellMonitor AI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const FleetDashboardScreen(),
    );
  }
}
