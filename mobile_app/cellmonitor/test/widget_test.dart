import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:cellmonitor/main.dart';
import 'package:cellmonitor/state/simulation_state.dart';

void main() {
  testWidgets('Fleet dashboard loads reactor cards', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SimulationState(),
        child: const CellMonitorApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('CellMonitor AI Fleet'), findsOneWidget);
    expect(find.text('Reactor Alpha'), findsOneWidget);
    expect(find.text('Reactor Beta'), findsOneWidget);
    expect(find.text('Reactor Gamma'), findsOneWidget);
    expect(find.text('Reactor Delta'), findsOneWidget);
  });
}
