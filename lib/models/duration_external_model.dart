class DurationExternal {
  final int id;
  final int minDurationMonths;
  final int maxDurationMonths;
  final String passType;
  final bool isActive;

  DurationExternal({
    required this.id,
    required this.minDurationMonths,
    required this.maxDurationMonths,
    required this.passType,
    required this.isActive,
  });

  factory DurationExternal.fromJson(Map<String, dynamic> json) {
    return DurationExternal(
      id: json['id'],
      minDurationMonths: json['min_duration_months'],
      maxDurationMonths: json['max_duration_months'],
      passType: json['pass_type'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}
