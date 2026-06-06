import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/simulation_provider.dart';
import '../theme/app_theme.dart';

class ReactorDetailScreen extends StatefulWidget {
  const ReactorDetailScreen({
    super.key,
    required this.reactorId,
  });

  final String reactorId;

  @override
  State<ReactorDetailScreen> createState() => _ReactorDetailScreenState();
}

class _ReactorDetailScreenState extends State<ReactorDetailScreen> {
  SimulationProvider? _provider;
  String? _lastShownAlert;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<SimulationProvider>();
    if (_provider != provider) {
      _provider?.removeListener(_onSimulationChanged);
      _provider = provider;
      _provider!.addListener(_onSimulationChanged);
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onSimulationChanged);
    super.dispose();
  }

  void _onSimulationChanged() {
    if (!mounted || _provider == null) return;
    final reactor = _provider!.getReactor(widget.reactorId);
    final alert = reactor.pendingAutoPilotAlert;
    if (alert == null || alert == _lastShownAlert) return;

    _lastShownAlert = alert;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(alert),
        backgroundColor: neonGreen.withValues(alpha: 0.92),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _provider!.clearAutoPilotAlert(widget.reactorId);
    _lastShownAlert = null;
  }

  Future<void> _generatePdf(ReactorSimulation reactor) async {
    try {
      final font = await PdfGoogleFonts.notoSansRegular();
      final fontBold = await PdfGoogleFonts.notoSansBold();
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          theme: pw.ThemeData.withFont(base: font, bold: fontBold),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CellMonitor AI Raporu',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Reaktör: ${reactor.name}'),
              pw.Text('Anlık Canlılık: ${reactor.currentViability ?? '--'}%'),
              pw.Text('Gelecek Öngörü: ${reactor.forecastViability ?? '--'}%'),
              pw.SizedBox(height: 20),
              pw.Text('pH: ${reactor.ph.toStringAsFixed(2)}'),
              pw.Text('Sıcaklık: ${reactor.temperature.toStringAsFixed(2)} °C'),
              pw.Text('Oksijen: ${reactor.oxygen.toStringAsFixed(2)} %'),
              pw.Text('Glikoz: ${reactor.glucose.toStringAsFixed(2)} mM'),
              pw.Text('Laktat: ${reactor.lactate.toStringAsFixed(2)} mM'),
            ],
          ),
        ),
      );

      final bytes = await pdf.save();
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'application/pdf',
              name: '${reactor.name.replaceAll(' ', '_')}_rapor.pdf',
            ),
          ],
          subject: '${reactor.name} — CellMonitor AI Raporu',
        ),
      );
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF paylaşım eklentisi yüklenemedi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SimulationProvider>();
    final reactor = state.getReactor(widget.reactorId);
    final collecting = reactor.apiHistoryBuffer.length < forecastHistoryMax;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          '${reactor.name} Detay',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          _AutoPilotSwitch(
            enabled: reactor.isAutoPilotEnabled,
            onChanged: (value) => context
                .read<SimulationProvider>()
                .toggleAutoPilot(widget.reactorId, value),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF00E676)),
            onPressed: () => _generatePdf(reactor),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHybridAiCard(reactor, collecting),
              const SizedBox(height: 24),
              const Text(
                'CANLI SENSÖR VERİLERİ',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildSensorCard(
                    'pH Seviyesi',
                    reactor.ph,
                    'pH',
                    Icons.water_drop,
                    Colors.blue,
                    reactor.phHistory,
                  ),
                  _buildSensorCard(
                    'Sıcaklık',
                    reactor.temperature,
                    '°C',
                    Icons.thermostat,
                    Colors.orange,
                    reactor.tempHistory,
                  ),
                  _buildSensorCard(
                    'Oksijen (DO)',
                    reactor.oxygen,
                    '%',
                    Icons.air,
                    Colors.lightBlueAccent,
                    reactor.oxHistory,
                  ),
                  _buildSensorCard(
                    'Glikoz',
                    reactor.glucose,
                    'mM',
                    Icons.bubble_chart,
                    Colors.purpleAccent,
                    reactor.glucoseHistory,
                  ),
                  _buildSensorCard(
                    'Laktat',
                    reactor.lactate,
                    'mM',
                    Icons.science,
                    Colors.pinkAccent,
                    reactor.lactateHistory,
                  ),
                  _buildSensorCard(
                    'Karıştırma',
                    reactor.agitation,
                    'rpm',
                    Icons.sync,
                    Colors.teal,
                    reactor.agHistory,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'MÜDAHALE PANELİ',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildControlButton(
                      'Glikoz Ekle',
                      Icons.add_circle_outline,
                      Colors.purpleAccent,
                      () => state.addGlucose(widget.reactorId),
                    ),
                    _buildControlButton(
                      'Laktat Temizle',
                      Icons.cleaning_services,
                      Colors.pinkAccent,
                      () => state.clearLactate(widget.reactorId),
                    ),
                    _buildControlButton(
                      'O2 Bas',
                      Icons.air,
                      Colors.lightBlueAccent,
                      () => state.boostOxygen(widget.reactorId),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHybridAiCard(ReactorSimulation reactor, bool collecting) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: reactor.statusColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: reactor.statusColor.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.psychology, color: Colors.blueAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'HİBRİT YAPAY ZEKA TAHMİNİ',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Anlık (XGBoost)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reactor.currentViability != null
                          ? '%${reactor.currentViability!.toStringAsFixed(1)}'
                          : '--',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: reactor.statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reactor.currentStatusMessage,
                      style: TextStyle(
                        color: reactor.statusColor,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 60, color: Colors.white24),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      '5 Dk Öngörü (LSTM)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    if (collecting)
                      const Text(
                        'Veri Toplanıyor...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      )
                    else if (reactor.forecastViability != null)
                      Text(
                        '%${reactor.forecastViability!.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      )
                    else
                      const SizedBox(
                        height: 38,
                        width: 38,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      collecting
                          ? '${reactor.apiHistoryBuffer.length}/10 ölçüm'
                          : reactor.forecastMessage,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(
    String title,
    double value,
    String unit,
    IconData icon,
    Color color,
    List<double> history,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Stack(
        children: [
          if (history.length > 2)
            Positioned.fill(
              top: 30,
              child: Opacity(
                opacity: 0.3,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: history
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value))
                            .toList(),
                        isCurved: true,
                        color: color,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoPilotSwitch extends StatelessWidget {
  const _AutoPilotSwitch({
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Otonom Kontrol (AI)',
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: neonGreen.withValues(alpha: enabled ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: neonGreen.withValues(alpha: enabled ? 0.45 : 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.smart_toy_outlined,
              size: 16,
              color: enabled ? neonGreen : Colors.white54,
            ),
            const SizedBox(width: 4),
            Text(
              'Otonom',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: enabled ? neonGreen : Colors.white54,
              ),
            ),
            Switch(
              value: enabled,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
