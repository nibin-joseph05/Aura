import 'package:hive/hive.dart';

part 'alarm_model.g.dart';

@HiveType(typeId: 30)
class AlarmModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int hour;

  @HiveField(2)
  int minute;

  @HiveField(3)
  String label;

  @HiveField(4)
  List<int> repeatDays;

  @HiveField(5)
  String tone;

  @HiveField(6)
  bool isEnabled;

  @HiveField(7)
  String dismissType;

  @HiveField(8)
  int mathDifficulty;

  @HiveField(9)
  bool vibrate;

  @HiveField(10)
  int snoozeMinutes;

  @HiveField(11)
  DateTime? nextTriggerTime;

  @HiveField(12)
  DateTime createdAt;

  AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = '',
    List<int>? repeatDays,
    this.tone = 'default',
    this.isEnabled = true,
    this.dismissType = 'button',
    this.mathDifficulty = 1,
    this.vibrate = true,
    this.snoozeMinutes = 5,
    this.nextTriggerTime,
    DateTime? createdAt,
  }) : repeatDays = repeatDays ?? [],
       createdAt = createdAt ?? DateTime.now();

  String get timeString {
    final isPm = hour >= 12;
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h12:$m ${isPm ? 'PM' : 'AM'}';
  }

  bool get isOneTime => repeatDays.isEmpty;

  bool get isDaily => repeatDays.length == 7;

  String get repeatLabel {
    if (isOneTime) return 'Once';
    if (isDaily) return 'Daily';
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return repeatDays.map((d) => days[d]).join(', ');
  }

  bool get hasMathDismiss => dismissType == 'math';

  DateTime calculateNextTrigger() {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, hour, minute);

    if (next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }

    if (repeatDays.isNotEmpty) {
      while (!repeatDays.contains(next.weekday - 1)) {
        next = next.add(const Duration(days: 1));
      }
    }

    return next;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'label': label,
      'repeatDays': repeatDays,
      'tone': tone,
      'isEnabled': isEnabled,
      'dismissType': dismissType,
      'mathDifficulty': mathDifficulty,
      'vibrate': vibrate,
      'snoozeMinutes': snoozeMinutes,
      'nextTriggerTime': nextTriggerTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      label: json['label'] as String? ?? '',
      repeatDays: (json['repeatDays'] as List?)?.cast<int>() ?? [],
      tone: json['tone'] as String? ?? 'default',
      isEnabled: json['isEnabled'] as bool? ?? true,
      dismissType: json['dismissType'] as String? ?? 'button',
      mathDifficulty: json['mathDifficulty'] as int? ?? 1,
      vibrate: json['vibrate'] as bool? ?? true,
      snoozeMinutes: json['snoozeMinutes'] as int? ?? 5,
      nextTriggerTime: json['nextTriggerTime'] != null
          ? DateTime.parse(json['nextTriggerTime'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
