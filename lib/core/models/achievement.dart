class Achievement {
  String id;
  bool unlocked;
  String unlockedDate;

  Achievement({
    this.id = '',
    this.unlocked = false,
    this.unlockedDate = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'unlocked': unlocked,
        'unlocked_date': unlockedDate,
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String? ?? '',
        unlocked: json['unlocked'] as bool? ?? false,
        unlockedDate: json['unlocked_date'] as String? ?? '',
      );
}
