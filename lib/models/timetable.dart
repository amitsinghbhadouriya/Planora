class Timetable {
  final int? id;
  final String subject;
  final String day; // 'Monday', 'Tuesday', ..., 'Saturday'
  final String startTime; // '09:30 AM' or '09:30'
  final String endTime;   // '10:30 AM' or '10:30'
  final String? room;

  Timetable({
    this.id,
    required this.subject,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.room,
  });

  // Convert Timetable instance to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
    };
  }

  // Create Timetable instance from SQLite row Map
  factory Timetable.fromMap(Map<String, dynamic> map) {
    return Timetable(
      id: map['id'] as int?,
      subject: map['subject'] as String,
      day: map['day'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      room: map['room'] as String?,
    );
  }

  // CopyWith helper
  Timetable copyWith({
    int? id,
    String? subject,
    String? day,
    String? startTime,
    String? endTime,
    String? room,
  }) {
    return Timetable(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
    );
  }
}

