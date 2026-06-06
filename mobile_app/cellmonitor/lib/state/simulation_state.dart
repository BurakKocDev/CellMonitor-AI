import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/reactor_profile.dart';
import '../theme/app_theme.dart';

class ReactorSimulation {
  ReactorSimulation({
    required this.id,
    required this.name,
    required this.profile,
  }) {
    final seed = ReactorSeed.forProfile(profile);
    ph = seed.ph;
    temperature = seed.temperature;
    oxygen = seed.dissolvedOxygen;
    glucose = seed.glucose;
    lactate = seed.lactate;
    agitation = seed.agitation;
  }

  final String id;
  final String name;
  final ReactorProfile profile;

  double ph = 7.2;
  double temperature = 37.0;
  double oxygen = 55.0;
  double glucose = 6.5;
  double lactate = 1.5;
  double agitation = 120.0;

  final List<double> phHistory = [];
  final List<double> tempHistory = [];
  final List<double> oxHistory = [];
  final List<double> glucoseHistory = [];
  final List<double> lactateHistory = [];
  final List<double> agHistory = [];
  final List<Map<String, dynamic>> apiHistoryBuffer = [];

  double? currentViability;
  String currentStatusMessage = 'Bağlanıyor...';
  double? forecastViability;
  String forecastMessage = 'Veri Toplanıyor...';
  bool isLoading = false;
  bool isAutoPilotEnabled = false;
  String? pendingAutoPilotAlert;

  Color get statusColor {
    final v = currentViability;
    if (v == null) return Colors.grey;
    if (v >= 90) return const Color(0xFF00E676);
    if (v >= 85) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  Map<String, dynamic> toReadingMap() {
    return {
      'ph_level': double.parse(ph.toStringAsFixed(2)),
      'temperature_c': double.parse(temperature.toStringAsFixed(2)),
      'dissolved_oxygen_pct': double.parse(oxygen.toStringAsFixed(2)),
      'glucose_mm': double.parse(glucose.toStringAsFixed(2)),
      'lactate_mm': double.parse(lactate.toStringAsFixed(2)),
      'agitation_rpm': double.parse(agitation.toStringAsFixed(1)),
    };
  }
}

class SimulationState extends ChangeNotifier {
  SimulationState() {
    _reactors = [
      ReactorSimulation(
        id: 'alpha',
        name: 'Reactor Alpha',
        profile: ReactorProfile.healthy,
      ),
      ReactorSimulation(
        id: 'beta',
        name: 'Reactor Beta',
        profile: ReactorProfile.stable,
      ),
      ReactorSimulation(
        id: 'gamma',
        name: 'Reactor Gamma',
        profile: ReactorProfile.warning,
      ),
      ReactorSimulation(
        id: 'delta',
        name: 'Reactor Delta',
        profile: ReactorProfile.critical,
      ),
    ];

    for (final reactor in _reactors) {
      _updateChartHistories(reactor);
      _recordSnapshot(reactor);
    }

    _bootstrap();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _tick());
  }

  static const _currentUrl = 'http://10.0.2.2:8000/predict_current';
  static const _forecastUrl = 'http://10.0.2.2:8000/predict_forecast';

  final Random _rng = Random();
  late final List<ReactorSimulation> _reactors;
  Timer? _timer;
  bool _isRefreshingAll = false;

  List<ReactorSimulation> get reactors => List.unmodifiable(_reactors);
  bool get isRefreshingAll => _isRefreshingAll;

  ReactorSimulation getReactor(String id) =>
      _reactors.firstWhere((r) => r.id == id);

  double? get averageSystemHealth {
    final values = _reactors.map((r) => r.currentViability).whereType<double>();
    final list = values.toList();
    if (list.isEmpty) return null;
    return list.reduce((a, b) => a + b) / list.length;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await refreshAll(force: true);
  }

  Future<void> refreshAll({bool force = false}) async {
    if (_isRefreshingAll && !force) return;
    _isRefreshingAll = true;
    notifyListeners();

    for (final reactor in _reactors) {
      reactor.isLoading = true;
    }
    notifyListeners();

    await Future.wait(_reactors.map(_fetchPredictions));

    _isRefreshingAll = false;
    notifyListeners();
  }

  Future<void> _tick() async {
    for (final reactor in _reactors) {
      _simulateReactor(reactor);
      _updateChartHistories(reactor);
      _recordSnapshot(reactor);
    }
    notifyListeners();

    await Future.wait(_reactors.map(_fetchPredictions));
    notifyListeners();
  }

  void toggleAutoPilot(String id) {
    final reactor = getReactor(id);
    reactor.isAutoPilotEnabled = !reactor.isAutoPilotEnabled;
    notifyListeners();
  }

  void clearAutoPilotAlert(String id) {
    final reactor = getReactor(id);
    if (reactor.pendingAutoPilotAlert == null) return;
    reactor.pendingAutoPilotAlert = null;
    notifyListeners();
  }

  Future<void> addGlucose(String id) async {
    final reactor = getReactor(id);
    reactor.glucose = (reactor.glucose + 5.0).clamp(0.0, 15.0);
    await _afterManualIntervention(reactor);
  }

  Future<void> clearLactate(String id) async {
    final reactor = getReactor(id);
    reactor.lactate = 0.0;
    await _afterManualIntervention(reactor);
  }

  Future<void> boostOxygen(String id) async {
    final reactor = getReactor(id);
    reactor.oxygen = 60.0;
    await _afterManualIntervention(reactor);
  }

  Future<void> _afterManualIntervention(ReactorSimulation reactor) async {
    _updateChartHistories(reactor);
    _recordSnapshot(reactor);
    notifyListeners();
    await _fetchPredictions(reactor);
    notifyListeners();
  }

  void _simulateReactor(ReactorSimulation reactor) {
    switch (reactor.profile) {
      case ReactorProfile.healthy:
        reactor.ph =
            (reactor.ph + _rng.nextDouble() * 0.04 - 0.02).clamp(7.28, 7.36);
        reactor.temperature =
            (reactor.temperature + _rng.nextDouble() * 0.15 - 0.075)
                .clamp(36.8, 37.2);
        reactor.oxygen =
            (reactor.oxygen + (_rng.nextDouble() - 0.5) * 0.5).clamp(59.0, 65.0);
        reactor.glucose =
            (reactor.glucose - _rng.nextDouble() * 0.02).clamp(6.8, 7.6);
        reactor.lactate =
            (reactor.lactate + _rng.nextDouble() * 0.06 - 0.03).clamp(0.4, 1.0);
        reactor.agitation = (reactor.agitation + _rng.nextDouble() * 3 - 1.5)
            .clamp(125.0, 138.0);
      case ReactorProfile.stable:
        reactor.ph =
            (reactor.ph + _rng.nextDouble() * 0.05 - 0.025).clamp(7.24, 7.32);
        reactor.temperature =
            (reactor.temperature + _rng.nextDouble() * 0.18 - 0.09)
                .clamp(36.7, 37.1);
        reactor.oxygen =
            (reactor.oxygen + (_rng.nextDouble() - 0.5) * 0.5).clamp(56.0, 62.0);
        reactor.glucose =
            (reactor.glucose - _rng.nextDouble() * 0.02).clamp(6.4, 7.3);
        reactor.lactate =
            (reactor.lactate + _rng.nextDouble() * 0.08 - 0.04).clamp(0.7, 1.4);
        reactor.agitation = (reactor.agitation + _rng.nextDouble() * 4 - 2)
            .clamp(120.0, 134.0);
      case ReactorProfile.warning:
        reactor.ph =
            (reactor.ph + _rng.nextDouble() * 0.06 - 0.03).clamp(7.02, 7.14);
        reactor.temperature =
            (reactor.temperature + _rng.nextDouble() * 0.22 - 0.08)
                .clamp(37.2, 37.8);
        reactor.oxygen =
            (reactor.oxygen + (_rng.nextDouble() - 0.5) * 0.5).clamp(46.0, 52.0);
        reactor.glucose =
            (reactor.glucose - _rng.nextDouble() * 0.02).clamp(4.2, 5.2);
        reactor.lactate =
            (reactor.lactate + _rng.nextDouble() * 0.10 - 0.03).clamp(2.2, 3.0);
        reactor.agitation = (reactor.agitation + _rng.nextDouble() * 3 - 1.5)
            .clamp(98.0, 110.0);
      case ReactorProfile.critical:
        reactor.ph =
            (reactor.ph + _rng.nextDouble() * 0.05 - 0.03).clamp(6.65, 6.82);
        reactor.temperature =
            (reactor.temperature + _rng.nextDouble() * 0.25 - 0.05)
                .clamp(38.2, 39.0);
        reactor.oxygen =
            (reactor.oxygen + (_rng.nextDouble() - 0.5) * 0.5).clamp(30.0, 38.0);
        reactor.glucose =
            (reactor.glucose - _rng.nextDouble() * 0.02).clamp(1.8, 2.8);
        reactor.lactate =
            (reactor.lactate + _rng.nextDouble() * 0.10 - 0.02).clamp(4.2, 5.2);
        reactor.agitation = (reactor.agitation + _rng.nextDouble() * 2.5 - 1.2)
            .clamp(68.0, 78.0);
    }
  }

  void _updateChartHistories(ReactorSimulation reactor) {
    _appendHistory(reactor.phHistory, reactor.ph);
    _appendHistory(reactor.tempHistory, reactor.temperature);
    _appendHistory(reactor.oxHistory, reactor.oxygen);
    _appendHistory(reactor.glucoseHistory, reactor.glucose);
    _appendHistory(reactor.lactateHistory, reactor.lactate);
    _appendHistory(reactor.agHistory, reactor.agitation);
  }

  void _appendHistory(List<double> list, double value) {
    list.add(value);
    if (list.length > historyMax) list.removeAt(0);
  }

  void _recordSnapshot(ReactorSimulation reactor) {
    reactor.apiHistoryBuffer.add(reactor.toReadingMap());
    if (reactor.apiHistoryBuffer.length > forecastHistoryMax) {
      reactor.apiHistoryBuffer.removeAt(0);
    }
  }

  Future<void> _fetchPredictions(ReactorSimulation reactor) async {
    reactor.isLoading = true;
    await _fetchCurrent(reactor);
    if (reactor.apiHistoryBuffer.length >= forecastHistoryMax) {
      await _fetchForecast(reactor);
      await _runAutoPilot(reactor);
    } else {
      reactor.forecastViability = null;
      reactor.forecastMessage = 'Veri Toplanıyor...';
    }
    reactor.isLoading = false;
  }

  Future<void> _fetchCurrent(ReactorSimulation reactor) async {
    try {
      final response = await http
          .post(
            Uri.parse(_currentUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(reactor.toReadingMap()),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final viability =
            (data['current_viability'] as num?)?.toDouble() ??
                (data['predicted_viability_pct'] as num?)?.toDouble();
        if (viability != null) {
          reactor.currentViability = viability;
          reactor.currentStatusMessage = data['status'] as String? ?? 'Normal';
        }
      }
    } catch (_) {
      if (reactor.apiHistoryBuffer.length >= forecastHistoryMax) {
        reactor.currentStatusMessage = 'Bağlantı Hatası';
      }
    }
  }

  Future<void> _fetchForecast(ReactorSimulation reactor) async {
    try {
      final response = await http
          .post(
            Uri.parse(_forecastUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'history':
                  List<Map<String, dynamic>>.from(reactor.apiHistoryBuffer),
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final forecast = (data['forecast_viability'] as num?)?.toDouble();
        if (forecast != null) {
          reactor.forecastViability = forecast;
          reactor.forecastMessage =
              data['message'] as String? ?? '5 Dk Sonraki Durum';
        } else {
          reactor.forecastViability = null;
          reactor.forecastMessage = 'Veri Toplanıyor...';
        }
      }
    } catch (_) {
      reactor.forecastMessage = 'Veri Toplanıyor...';
    }
  }

  Future<void> _runAutoPilot(ReactorSimulation reactor) async {
    if (!reactor.isAutoPilotEnabled) return;
    final forecast = reactor.forecastViability;
    if (forecast == null || forecast >= 80) return;

    String? action;

    if (reactor.lactate > 2.5) {
      reactor.lactate = 0.0;
      action = 'Laktat temizlendi!';
    } else if (reactor.oxygen < 45) {
      reactor.oxygen = 60.0;
      action = 'O2 basıldı!';
    } else if (reactor.glucose < 4.0) {
      reactor.glucose = (reactor.glucose + 5.0).clamp(0.0, 15.0);
      action = 'Glikoz eklendi!';
    }

    if (action == null) return;

    reactor.pendingAutoPilotAlert = '🤖 AI Müdahalesi: $action';
    _updateChartHistories(reactor);
    _recordSnapshot(reactor);
    await _fetchPredictions(reactor);
  }
}
