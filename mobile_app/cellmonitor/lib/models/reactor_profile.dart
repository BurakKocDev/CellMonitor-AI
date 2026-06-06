enum ReactorProfile { healthy, stable, warning, critical }

class ReactorSeed {
  const ReactorSeed({
    required this.ph,
    required this.temperature,
    required this.dissolvedOxygen,
    required this.glucose,
    required this.lactate,
    required this.agitation,
  });

  final double ph;
  final double temperature;
  final double dissolvedOxygen;
  final double glucose;
  final double lactate;
  final double agitation;

  static ReactorSeed forProfile(ReactorProfile profile) {
    return switch (profile) {
      ReactorProfile.healthy => const ReactorSeed(
          ph: 7.32,
          temperature: 37.0,
          dissolvedOxygen: 62.0,
          glucose: 7.2,
          lactate: 0.6,
          agitation: 132.0,
        ),
      ReactorProfile.stable => const ReactorSeed(
          ph: 7.28,
          temperature: 36.9,
          dissolvedOxygen: 59.0,
          glucose: 6.9,
          lactate: 1.0,
          agitation: 128.0,
        ),
      ReactorProfile.warning => const ReactorSeed(
          ph: 7.08,
          temperature: 37.5,
          dissolvedOxygen: 49.0,
          glucose: 4.6,
          lactate: 2.6,
          agitation: 104.0,
        ),
      ReactorProfile.critical => const ReactorSeed(
          ph: 6.72,
          temperature: 38.6,
          dissolvedOxygen: 34.0,
          glucose: 2.2,
          lactate: 4.8,
          agitation: 72.0,
        ),
    };
  }
}

class FleetReactor {
  FleetReactor({
    required this.name,
    required this.profile,
  }) : seed = ReactorSeed.forProfile(profile) {
    ph = seed.ph;
    temperature = seed.temperature;
    dissolvedOxygen = seed.dissolvedOxygen;
    glucose = seed.glucose;
    lactate = seed.lactate;
    agitation = seed.agitation;
  }

  final String name;
  final ReactorProfile profile;
  final ReactorSeed seed;

  late double ph;
  late double temperature;
  late double dissolvedOxygen;
  late double glucose;
  late double lactate;
  late double agitation;

  double? viabilityPct;
  String status = 'Sensör verileri bekleniyor…';
  bool isLoading = false;
}
