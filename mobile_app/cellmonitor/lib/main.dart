import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/simulation_provider.dart';
import 'screens/fleet_dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SimulationProvider(),
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
