class AppointmentSlot {
  String? timing;
  int? maxLimit;
  bool isLimitReached;

  AppointmentSlot({this.timing, this.maxLimit, this.isLimitReached = false});

  factory AppointmentSlot.fromJSON(Map<String, dynamic> data) {
    return AppointmentSlot(
        timing: data['timing'],
        maxLimit: data['maxLimit'],
        isLimitReached: data['isLimitReached']);
  }

  Map<String, dynamic> toJSON() {
    return {
      "timing": timing,
      "maxLimit": maxLimit,
      "isLimitReached": isLimitReached
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentSlot &&
          runtimeType == other.runtimeType &&
          timing == other.timing;

  @override
  int get hashCode => timing.hashCode;

  @override
  String toString() {
    return 'AppointmentSlot{timing: $timing, maxLimit: $maxLimit, isLimitReached: $isLimitReached}';
  }

  AppointmentSlot copyWith(
      {String? timing, int? maxLimit, bool? isLimitReached}) {
    return AppointmentSlot(
      timing: timing ?? this.timing,
      maxLimit: maxLimit ?? this.maxLimit,
      isLimitReached: isLimitReached ?? this.isLimitReached,
    );
  }
}
