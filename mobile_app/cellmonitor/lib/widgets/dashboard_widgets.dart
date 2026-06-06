import 'dart:math';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GlowOrb extends StatelessWidget {
  const GlowOrb({super.key, required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 20)],
      ),
    );
  }
}

class NeonBackground extends StatelessWidget {
  const NeonBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgDark, Color(0xFF0D1B2A), bgDark],
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -60,
          child: GlowOrb(color: neonBlue.withValues(alpha: 0.12), size: 260),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: GlowOrb(color: neonGreen.withValues(alpha: 0.10), size: 220),
        ),
        child,
      ],
    );
  }
}

class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.accent,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: accent.withValues(alpha: 0.08),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.12),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
        ),
      ),
    );
  }
}

class DetailHeaderBar extends StatelessWidget {
  const DetailHeaderBar({
    super.key,
    required this.isLoading,
    required this.onRefresh,
    required this.onDownload,
  });

  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: neonGreen.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: neonGreen.withValues(alpha: 0.15),
                blurRadius: 12,
              ),
            ],
          ),
          child: const Icon(Icons.biotech, color: neonGreen, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Canlı sensör izleme ve müdahale',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.45),
              letterSpacing: 0.3,
            ),
          ),
        ),
        HeaderIconButton(
          icon: Icons.download_rounded,
          accent: neonBlue,
          tooltip: 'Rapor Al',
          onTap: onDownload,
        ),
        const SizedBox(width: 8),
        HeaderIconButton(
          icon: Icons.refresh_rounded,
          accent: neonGreen,
          tooltip: 'Yenile',
          onTap: onRefresh,
        ),
        const SizedBox(width: 10),
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: neonBlue.withValues(alpha: 0.7),
            ),
          )
        else
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: neonGreen,
              boxShadow: [
                BoxShadow(
                  color: neonGreen.withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class HybridAiPredictionCard extends StatelessWidget {
  const HybridAiPredictionCard({
    super.key,
    required this.currentViabilityPct,
    required this.forecastViabilityPct,
    required this.status,
    required this.isLoading,
    required this.errorMessage,
    required this.isCollectingForecastData,
    required this.pulseAnimation,
  });

  final double? currentViabilityPct;
  final double? forecastViabilityPct;
  final String status;
  final bool isLoading;
  final String? errorMessage;
  final bool isCollectingForecastData;
  final AnimationController pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final currentAccent = viabilityAccentColor(currentViabilityPct);
    final forecastAccent = viabilityAccentColor(forecastViabilityPct);
    final glowAccent = _blendAccent(currentAccent, forecastAccent);

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        final glowStrength = 0.25 + pulseAnimation.value * 0.35;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: glowAccent.withValues(alpha: glowStrength),
                blurRadius: 32 + pulseAnimation.value * 16,
                spreadRadius: 2 + pulseAnimation.value * 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      glowAccent.withValues(alpha: 0.12),
                      glassFill,
                      glowAccent.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: glowAccent.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology_outlined, color: glowAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                'YAPAY ZEKA TAHMİNİ',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                  color: glowAccent.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _HybridPredictionPanel(
                    title: 'Anlık Durum (XGBoost)',
                    valueText: currentViabilityPct != null
                        ? '${currentViabilityPct!.toStringAsFixed(1)}%'
                        : null,
                    subtitle: 'Hücre Canlılığı',
                    accent: currentAccent,
                    isLoading: isLoading && currentViabilityPct == null,
                    errorMessage:
                        isCollectingForecastData ? null : errorMessage,
                  ),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                Expanded(
                  child: _HybridPredictionPanel(
                    title: '5 Dk Öngörü (LSTM)',
                    valueText: isCollectingForecastData
                        ? null
                        : forecastViabilityPct != null
                            ? '${forecastViabilityPct!.toStringAsFixed(1)}%'
                            : null,
                    placeholder: isCollectingForecastData
                        ? 'Veri Toplanıyor...'
                        : null,
                    subtitle: 'Tahmini Canlılık',
                    accent: forecastAccent,
                    isLoading: !isCollectingForecastData &&
                        isLoading &&
                        forecastViabilityPct == null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: currentAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: currentAccent.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(_statusIcon(status), color: currentAccent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _blendAccent(Color a, Color b) {
    if (currentViabilityPct == null) return b;
    if (forecastViabilityPct == null) return a;
    return Color.lerp(a, b, 0.5) ?? a;
  }

  IconData _statusIcon(String s) {
    if (s.contains('Kritik')) return Icons.warning_amber_rounded;
    if (s.contains('Dikkat')) return Icons.info_outline;
    return Icons.check_circle_outline;
  }
}

class _HybridPredictionPanel extends StatelessWidget {
  const _HybridPredictionPanel({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.isLoading,
    this.valueText,
    this.placeholder,
    this.errorMessage,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final bool isLoading;
  final String? valueText;
  final String? placeholder;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: accent.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 14),
        if (errorMessage != null)
          SizedBox(
            height: 52,
            child: Center(
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: neonRed.withValues(alpha: 0.85),
                ),
              ),
            ),
          )
        else if (isLoading)
          SizedBox(
            height: 52,
            child: Center(
              child: CircularProgressIndicator(
                color: accent.withValues(alpha: 0.6),
                strokeWidth: 2,
              ),
            ),
          )
        else if (placeholder != null)
          SizedBox(
            height: 52,
            child: Center(
              child: Text(
                placeholder!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.45),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          )
        else ...[
          Text(
            valueText ?? '—',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w200,
              height: 1,
              color: accent,
              shadows: [
                Shadow(
                  color: accent.withValues(alpha: 0.55),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ],
      ],
    );
  }
}

class AiPredictionCard extends StatelessWidget {
  const AiPredictionCard({
    super.key,
    required this.viabilityPct,
    required this.status,
    required this.accentColor,
    required this.isLoading,
    required this.errorMessage,
    required this.pulseAnimation,
  });

  final double? viabilityPct;
  final String status;
  final Color accentColor;
  final bool isLoading;
  final String? errorMessage;
  final AnimationController pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        final glowStrength = 0.25 + pulseAnimation.value * 0.35;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: glowStrength),
                blurRadius: 32 + pulseAnimation.value * 16,
                spreadRadius: 2 + pulseAnimation.value * 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withValues(alpha: 0.12),
                      glassFill,
                      accentColor.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology_outlined, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'YAPAY ZEKA TAHMİNİ',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                  color: accentColor.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (errorMessage != null)
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: neonRed.withValues(alpha: 0.85),
                fontSize: 13,
              ),
            )
          else if (viabilityPct != null) ...[
            Text(
              '${viabilityPct!.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w200,
                height: 1,
                color: accentColor,
                shadows: [
                  Shadow(
                    color: accentColor.withValues(alpha: 0.6),
                    blurRadius: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hücre Canlılığı',
              style: TextStyle(
                fontSize: 13,
                letterSpacing: 1.5,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ] else
            SizedBox(
              height: 72,
              child: Center(
                child: CircularProgressIndicator(
                  color: accentColor.withValues(alpha: 0.6),
                  strokeWidth: 2,
                ),
              ),
            ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(_statusIcon(status), color: accentColor, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String s) {
    if (s.contains('Kritik')) return Icons.warning_amber_rounded;
    if (s.contains('Dikkat')) return Icons.info_outline;
    return Icons.check_circle_outline;
  }
}

class SensorCard extends StatelessWidget {
  const SensorCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accent,
    required this.history,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accent;
  final List<double> history;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accent.withValues(alpha: 0.07), glassFill],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: glassBorder),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -4,
                right: -12,
                bottom: -4,
                top: 24,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.2,
                    child: MiniSparkline(history: history, accent: accent),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: accent, size: 18),
                      const Spacer(),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.7),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                          color: accent,
                          height: 1,
                        ),
                      ),
                      if (unit.isNotEmpty) ...[
                        const SizedBox(width: 3),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            unit,
                            style: TextStyle(
                              fontSize: 12,
                              color: accent.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiniSparkline extends StatelessWidget {
  const MiniSparkline({super.key, required this.history, required this.accent});

  final List<double> history;
  final Color accent;

  (double, double) _yBounds() {
    final minVal = history.reduce(min);
    final maxVal = history.reduce(max);
    final range = (maxVal - minVal).abs();
    final pad = range < 0.001 ? maxVal.abs() * 0.05 + 0.01 : range * 0.2;
    return (minVal - pad, maxVal + pad);
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    final (minY, maxY) = _yBounds();
    final spots = history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (historyMax - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        clipData: const FlClipData.all(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: accent,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  accent.withValues(alpha: 0.35),
                  accent.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }
}

class InterventionPanel extends StatelessWidget {
  const InterventionPanel({
    super.key,
    required this.onAddGlucose,
    required this.onClearLactate,
    required this.onPressOxygen,
  });

  final VoidCallback onAddGlucose;
  final VoidCallback onClearLactate;
  final VoidCallback onPressOxygen;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          InterventionButton(
            label: 'Glikoz Ekle',
            icon: Icons.add_circle_outline,
            accent: neonGreen,
            onTap: onAddGlucose,
          ),
          const SizedBox(width: 12),
          InterventionButton(
            label: 'Laktat Temizle',
            icon: Icons.cleaning_services_outlined,
            accent: neonRed,
            onTap: onClearLactate,
          ),
          const SizedBox(width: 12),
          InterventionButton(
            label: 'O2 Bas',
            icon: Icons.compress_outlined,
            accent: neonBlue,
            onTap: onPressOxygen,
          ),
        ],
      ),
    );
  }
}

class InterventionButton extends StatelessWidget {
  const InterventionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent.withValues(alpha: 0.12), glassFill],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.15),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: accent, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReactorSummaryCard extends StatelessWidget {
  const ReactorSummaryCard({
    super.key,
    required this.name,
    required this.viabilityPct,
    required this.isLoading,
    required this.pulseAnimation,
    required this.onTap,
  });

  final String name;
  final double? viabilityPct;
  final bool isLoading;
  final AnimationController pulseAnimation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = viabilityAccentColor(viabilityPct);
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        final pulse = 0.35 + pulseAnimation.value * 0.65;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: 0.10),
                        glassFill,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: accent.withValues(alpha: 0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.18 * pulse),
                        blurRadius: 18 + pulseAnimation.value * 10,
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.precision_manufacturing_outlined,
                  color: accent, size: 18),
              const Spacer(),
              _PulsingStatusDot(accent: accent, animation: pulseAnimation),
            ],
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          if (isLoading)
            SizedBox(
              height: 28,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accent.withValues(alpha: 0.7),
                  ),
                ),
              ),
            )
          else
            Text(
              viabilityPct != null
                  ? '${viabilityPct!.toStringAsFixed(1)}%'
                  : '—',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: accent,
                height: 1,
              ),
            ),
          Text(
            'Canlılık',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class SystemOverviewCard extends StatelessWidget {
  const SystemOverviewCard({
    super.key,
    required this.activeCount,
    required this.totalCount,
    required this.averageHealthPct,
    required this.isLoading,
  });

  final int activeCount;
  final int totalCount;
  final double? averageHealthPct;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final accent = viabilityAccentColor(averageHealthPct);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                neonBlue.withValues(alpha: 0.10),
                glassFill,
                neonGreen.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.14),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.dashboard_customize_outlined,
                      color: neonBlue, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'SİSTEM GENEL DURUMU',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w700,
                      color: neonBlue.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _OverviewMetric(
                      label: 'Aktif Reaktör Sayısı',
                      value: '$activeCount/$totalCount',
                      accent: neonGreen,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 42,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  Expanded(
                    child: _OverviewMetric(
                      label: 'Genel Sistem Sağlığı',
                      value: isLoading
                          ? '…'
                          : averageHealthPct != null
                              ? '%${averageHealthPct!.toStringAsFixed(1)}'
                              : '—',
                      accent: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: neonGreen.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: neonGreen.withValues(alpha: 0.22)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.memory_outlined,
                        size: 16, color: neonGreen.withValues(alpha: 0.85)),
                    const SizedBox(width: 10),
                    Text(
                      'Model Performansı: XGBoost — %98.2 Doğruluk',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
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
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.45),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: accent,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingStatusDot extends StatelessWidget {
  const _PulsingStatusDot({
    required this.accent,
    required this.animation,
  });

  final Color accent;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = 0.85 + animation.value * 0.35;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.5 + animation.value * 0.3),
                  blurRadius: 8 + animation.value * 6,
                  spreadRadius: animation.value * 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
