/// Measurement unit system chosen by the user (D-5). `AppSettings.unitSystem`
/// (06_DATA_MODEL.md, section 6.12) maps directly to this enum.
enum UnitSystem { metric, imperial }

/// Converts between metric storage values and the units shown to the user
/// (03_TECHNICAL_SPEC.md, section 6). Storage is always metric: mass in kg,
/// distance in meters, length measurements in cm, duration in seconds.
/// This is the only place in the app that performs unit conversion.
class UnitConverter {
  const UnitConverter();

  static const double kgPerLb = 0.45359237;
  static const double metersPerMile = 1609.344;
  static const double cmPerInch = 2.54;

  // --- Mass (storage: kg) ---

  /// Stored kg to the display unit, rounded to 1 decimal.
  double massToDisplay(double kg, UnitSystem system) {
    final value = system == UnitSystem.imperial ? kg / kgPerLb : kg;
    return _roundTo(value, 1);
  }

  /// Value entered in the display unit to kg for storage. Not rounded:
  /// range validation (06_DATA_MODEL.md) runs against the raw value.
  double massToKg(double value, UnitSystem system) {
    return system == UnitSystem.imperial ? value * kgPerLb : value;
  }

  // --- Distance (storage: meters) ---

  /// Stored meters to km or miles, rounded to 2 decimals.
  double distanceToDisplay(double meters, UnitSystem system) {
    final value = system == UnitSystem.imperial
        ? meters / metersPerMile
        : meters / 1000;
    return _roundTo(value, 2);
  }

  /// Value entered in km (metric) or miles (imperial) to meters for storage.
  double distanceToMeters(double value, UnitSystem system) {
    return system == UnitSystem.imperial ? value * metersPerMile : value * 1000;
  }

  // --- Length measurements (storage: cm) ---

  /// Stored cm to cm or inches, rounded to 1 decimal.
  double lengthToDisplay(double cm, UnitSystem system) {
    final value = system == UnitSystem.imperial ? cm / cmPerInch : cm;
    return _roundTo(value, 1);
  }

  /// Value entered in cm (metric) or inches (imperial) to cm for storage.
  double lengthToCm(double value, UnitSystem system) {
    return system == UnitSystem.imperial ? value * cmPerInch : value;
  }

  // --- Pace (cardio display only; never stored) ---

  /// Seconds per display-unit distance (km or mile); null if [distanceM] is
  /// zero or negative.
  double? paceSecondsPerUnit(
    int durationSec,
    double distanceM,
    UnitSystem system,
  ) {
    if (distanceM <= 0) return null;
    final unitDistance = system == UnitSystem.imperial
        ? distanceM / metersPerMile
        : distanceM / 1000;
    if (unitDistance <= 0) return null;
    return durationSec / unitDistance;
  }

  /// Formats a pace value (seconds per unit distance) as `m:ss`.
  String formatPace(double paceSeconds) {
    final totalSeconds = paceSeconds.round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // --- Input parsing ---

  /// Parses a number typed by the user, accepting both `.` and `,` as the
  /// decimal separator regardless of device locale (03, section 6).
  double? parseDecimal(String input) {
    final normalized = input.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  double _roundTo(double value, int fractionDigits) {
    return double.parse(value.toStringAsFixed(fractionDigits));
  }
}
