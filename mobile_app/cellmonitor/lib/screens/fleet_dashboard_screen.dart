import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/simulation_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_widgets.dart';
import 'reactor_detail_screen.dart';

class FleetDashboardScreen extends StatefulWidget {
  const FleetDashboardScreen({super.key});

  @override
  State<FleetDashboardScreen> createState() => _FleetDashboardScreenState();
}

class _FleetDashboardScreenState extends State<FleetDashboardScreen>
    with TickerProviderStateMixin {
  late final List<AnimationController> _pulseControllers;

  @override
  void initState() {
    super.initState();
    _pulseControllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1600 + index * 200),
      )..repeat(reverse: true),
    );
  }

  @override
  void dispose() {
    for (final controller in _pulseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SimulationProvider>();
    final reactors = state.reactors;
    final averageHealth = state.averageSystemHealth;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [neonGreen, neonBlue],
          ).createShader(bounds),
          child: const Text(
            'CellMonitor AI Fleet',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          HeaderIconButton(
            icon: Icons.refresh_rounded,
            accent: neonGreen,
            tooltip: 'Tümünü Yenile',
            onTap: () =>
                context.read<SimulationProvider>().refreshAll(force: true),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: NeonBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.hub_outlined,
                        size: 16, color: neonBlue.withValues(alpha: 0.8)),
                    const SizedBox(width: 8),
                    Text(
                      'FİLO DURUM ÖZETİ',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w600,
                        color: neonBlue.withValues(alpha: 0.8),
                      ),
                    ),
                    const Spacer(),
                    if (state.isRefreshingAll)
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: neonBlue.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.05,
                    ),
                    itemCount: reactors.length,
                    itemBuilder: (context, index) {
                      final reactor = reactors[index];
                      return ReactorSummaryCard(
                        name: reactor.name,
                        viabilityPct: reactor.currentViability,
                        isLoading: reactor.isLoading,
                        pulseAnimation: _pulseControllers[index],
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ReactorDetailScreen(
                                reactorId: reactor.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SystemOverviewCard(
                  activeCount: reactors.length,
                  totalCount: 4,
                  averageHealthPct: averageHealth,
                  isLoading: state.isRefreshingAll &&
                      reactors.every((r) => r.currentViability == null),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
