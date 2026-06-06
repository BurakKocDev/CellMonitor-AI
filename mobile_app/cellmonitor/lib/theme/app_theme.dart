import 'package:flutter/material.dart';

const bgDark = Color(0xFF050810);
const bgMid = Color(0xFF0A1220);
const neonGreen = Color(0xFF00FF88);
const neonBlue = Color(0xFF00D4FF);
const neonOrange = Color(0xFFFF8C00);
const neonRed = Color(0xFFFF3366);
const glassFill = Color(0x18FFFFFF);
const glassBorder = Color(0x33FFFFFF);
const historyMax = 20;
const forecastHistoryMax = 10;

const apiCurrentUrl = 'http://10.0.2.2:8000/predict_current';
const apiForecastUrl = 'http://10.0.2.2:8000/predict_forecast';

Color viabilityAccentColor(double? pct) {
  if (pct == null) return neonBlue;
  if (pct >= 90) return neonGreen;
  if (pct >= 85) return neonOrange;
  return neonRed;
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    fontFamily: 'Roboto',
    appBarTheme: AppBarTheme(
      backgroundColor: bgDark.withValues(alpha: 0.92),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: neonBlue),
    ),
    colorScheme: const ColorScheme.dark(
      primary: neonGreen,
      secondary: neonBlue,
      surface: bgMid,
    ),
  );
}
