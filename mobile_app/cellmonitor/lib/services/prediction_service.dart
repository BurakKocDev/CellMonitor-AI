import 'dart:convert';

import 'package:http/http.dart' as http;

import '../theme/app_theme.dart';

class PredictionResult {
  const PredictionResult({
    required this.viabilityPct,
    required this.status,
  });

  final double viabilityPct;
  final String status;
}

class ForecastResult {
  const ForecastResult({required this.forecastViability});

  final double forecastViability;
}

class PredictionService {
  Future<PredictionResult> predict({
    required double ph,
    required double temperature,
    required double dissolvedOxygen,
    required double glucose,
    required double lactate,
    required double agitation,
  }) {
    return predictCurrent(
      ph: ph,
      temperature: temperature,
      dissolvedOxygen: dissolvedOxygen,
      glucose: glucose,
      lactate: lactate,
      agitation: agitation,
    );
  }

  Future<PredictionResult> predictCurrent({
    required double ph,
    required double temperature,
    required double dissolvedOxygen,
    required double glucose,
    required double lactate,
    required double agitation,
  }) async {
    final response = await http
        .post(
          Uri.parse(apiCurrentUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_sensorPayload(
            ph: ph,
            temperature: temperature,
            dissolvedOxygen: dissolvedOxygen,
            glucose: glucose,
            lactate: lactate,
            agitation: agitation,
          )),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) {
      throw Exception('API hatası: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final viability =
        (data['current_viability'] as num?)?.toDouble() ??
            (data['predicted_viability_pct'] as num?)?.toDouble();

    if (viability == null) {
      throw Exception('Geçersiz API yanıtı');
    }

    return PredictionResult(
      viabilityPct: viability,
      status: data['status'] as String? ?? 'Bilinmiyor',
    );
  }

  Future<ForecastResult> predictForecast(
    List<Map<String, dynamic>> sensorHistory,
  ) async {
    final response = await http
        .post(
          Uri.parse(apiForecastUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'history': sensorHistory}),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw Exception('Forecast API hatası: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final forecast = (data['forecast_viability'] as num?)?.toDouble();
    if (forecast == null) {
      throw Exception('Forecast henüz hazır değil');
    }

    return ForecastResult(forecastViability: forecast);
  }

  Map<String, dynamic> _sensorPayload({
    required double ph,
    required double temperature,
    required double dissolvedOxygen,
    required double glucose,
    required double lactate,
    required double agitation,
  }) {
    return {
      'ph_level': double.parse(ph.toStringAsFixed(2)),
      'temperature_c': double.parse(temperature.toStringAsFixed(2)),
      'dissolved_oxygen_pct': double.parse(dissolvedOxygen.toStringAsFixed(2)),
      'glucose_mm': double.parse(glucose.toStringAsFixed(2)),
      'lactate_mm': double.parse(lactate.toStringAsFixed(2)),
      'agitation_rpm': double.parse(agitation.toStringAsFixed(1)),
    };
  }
}
